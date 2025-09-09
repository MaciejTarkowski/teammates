CREATE OR REPLACE FUNCTION search_events(
    p_lat double precision,
    p_lng double precision,
    p_radius_meters double precision,
    p_category text DEFAULT NULL,
    p_start_date timestamptz DEFAULT NULL,
    p_end_date timestamptz DEFAULT NULL,
    p_page_size integer DEFAULT 20,
    p_page_number integer DEFAULT 1
)
RETURNS TABLE(
    id uuid,
    created_at timestamp with time zone,
    organizer_id uuid,
    name character varying,
    description character varying,
    location_text character varying,
    event_time timestamp with time zone,
    max_participants integer,
    category text,
    location_lat double precision,
    location_lng double precision,
    cancellation_reason text,
    status text,
    distance_meters double precision
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    e.id,
    e.created_at,
    e.organizer_id,
    e.name,
    e.description,
    e.location_text,
    e.event_time,
    e.max_participants,
    e.category,
    e.location_lat,
    e.location_lng,
    e.cancellation_reason,
    e.status,
    ST_Distance(
      ST_MakePoint(e.location_lng, e.location_lat)::geography,
      ST_MakePoint(p_lng, p_lat)::geography
    ) AS distance_meters
  FROM
    public.events e
  WHERE
    -- Location filter (mandatory)
    ST_DWithin(
      ST_MakePoint(e.location_lng, e.location_lat)::geography,
      ST_MakePoint(p_lng, p_lat)::geography,
      p_radius_meters
    )
    -- Category filter (optional)
    AND (p_category IS NULL OR e.category = p_category)
    -- Date range filter (optional)
    AND (p_start_date IS NULL OR e.event_time >= p_start_date)
    AND (p_end_date IS NULL OR e.event_time <= p_end_date)
    AND e.status IN ('active', 'held') -- Allow searching for active and held events
  ORDER BY
    distance_meters ASC
  LIMIT p_page_size
  OFFSET (p_page_number - 1) * p_page_size;
END;
$$;