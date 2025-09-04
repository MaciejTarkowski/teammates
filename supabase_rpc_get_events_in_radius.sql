CREATE OR REPLACE FUNCTION public.get_events_in_radius(
    user_lat float8,
    user_lng float8,
    radius_km float8
)
RETURNS SETOF public.events
LANGUAGE plpgsql
AS $$
DECLARE
    user_point geometry;
BEGIN
    user_point := ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326); -- 4326 is SRID for WGS 84 (lat/lng)

    RETURN QUERY
    SELECT e.*
    FROM public.events e
    WHERE
        e.location_lat IS NOT NULL AND e.location_lng IS NOT NULL AND
        ST_DWithin(
            ST_SetSRID(ST_MakePoint(e.location_lng, e.location_lat), 4326),
            user_point,
            radius_km * 1000 -- Convert km to meters
        )
    ORDER BY e.event_time ASC;
END;
$$;