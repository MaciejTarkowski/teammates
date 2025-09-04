CREATE OR REPLACE FUNCTION public.get_events_in_radius(
    user_lat float8,
    user_lng float8,
    radius_km float8
)
RETURNS TABLE (
    id UUID,
    created_at TIMESTAMP WITH TIME ZONE,
    organizer_id UUID,
    name CHARACTER VARYING,
    description CHARACTER VARYING,
    location_text CHARACTER VARYING,
    event_time TIMESTAMP WITH TIME ZONE,
    max_participants INTEGER,
    category TEXT,
    location_lat DOUBLE PRECISION,
    location_lng DOUBLE PRECISION,
    distance_meters DOUBLE PRECISION -- Nowa kolumna do debugowania
)
LANGUAGE plpgsql
AS $$
DECLARE
    user_point geometry;
BEGIN
    user_point := ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326); -- 4326 is SRID for WGS 84 (lat/lng)

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
        ST_Distance(
            ST_SetSRID(ST_MakePoint(e.location_lng, e.location_lat), 4326)::geography,
            user_point::geography
        ) AS distance_meters -- Oblicz i zwróć odległość w metrach
    FROM public.events e
    WHERE
        e.location_lat IS NOT NULL AND e.location_lng IS NOT NULL AND
        ST_DWithin(
            ST_SetSRID(ST_MakePoint(e.location_lng, e.location_lat), 4326)::geography,
            user_point::geography,
            radius_km * 1000 -- Konwertuj km na metry
        )
    ORDER BY e.event_time ASC;
END;
$$;