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
    user_role text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (e.id)
        e.*,
        CASE
            WHEN e.organizer_id = auth.uid() THEN 'organizer'
            ELSE 'participant'
        END AS user_role
    FROM
        events e
    LEFT JOIN
        event_participants ep ON e.id = ep.event_id
    WHERE
        e.organizer_id = auth.uid() OR ep.user_id = auth.uid()
    ORDER BY e.id, e.event_time;
END;
$$;
