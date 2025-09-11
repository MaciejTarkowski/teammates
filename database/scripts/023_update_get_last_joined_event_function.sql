CREATE OR REPLACE FUNCTION public.get_last_joined_event(user_id_param uuid)
RETURNS TABLE(
    id uuid,
    name character varying,
    event_time timestamp with time zone
)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.name,
        e.event_time
    FROM
        public.events e
    JOIN
        public.event_attendance ea ON e.id = ea.event_id
    WHERE
        ea.user_id = user_id_param
    ORDER BY
        e.event_time DESC
    LIMIT 1;
END;
$function$;