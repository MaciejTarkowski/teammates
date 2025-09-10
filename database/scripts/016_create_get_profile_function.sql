CREATE OR REPLACE FUNCTION public.get_profile(p_user_id uuid)
RETURNS TABLE(id uuid, reputation_score integer, username text, avatar_url text)
LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT
    p.id,
    p.reputation_score,
    p.username,
    p.avatar_url
  FROM
    public.profiles p
  WHERE
    p.id = p_user_id;
END;
$function$;