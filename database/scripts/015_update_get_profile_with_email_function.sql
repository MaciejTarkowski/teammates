CREATE OR REPLACE FUNCTION public.get_profile_with_email(p_user_id uuid)
RETURNS TABLE(id uuid, email text, user_metadata jsonb, reputation_score integer, username text, avatar_url text)
LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT
    p.id,
    u.email,
    p.user_metadata,
    p.reputation_score,
    p.username,
    p.avatar_url
  FROM
    public.profiles p
  JOIN
    auth.users u ON p.id = u.id
  WHERE
    p.id = p_user_id;
END;
$function$;