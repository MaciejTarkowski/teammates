CREATE OR REPLACE FUNCTION get_my_events()
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
    user_role text
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
        CASE
            WHEN e.organizer_id = auth.uid() THEN 'organizer'
            ELSE 'participant'
        END AS user_role
    FROM
        events e
    LEFT JOIN
        event_attendance ea ON e.id = ea.event_id
    WHERE
        e.organizer_id = auth.uid() OR ea.user_id = auth.uid()
    ORDER BY e.event_time;
END;
$$;
