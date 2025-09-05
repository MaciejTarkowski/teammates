CREATE OR REPLACE FUNCTION get_profile_with_email(p_user_id uuid)
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
    WHERE
        p.id = p_user_id;
END;
$$;