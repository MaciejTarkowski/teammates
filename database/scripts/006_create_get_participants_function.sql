CREATE OR REPLACE FUNCTION get_event_participants_with_profiles(p_event_id uuid)
RETURNS TABLE(
    id uuid,
    user_metadata jsonb
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.user_metadata
    FROM
        profiles p
    JOIN
        event_participants ep ON p.id = ep.user_id
    WHERE
        ep.event_id = p_event_id;
END;
$$;