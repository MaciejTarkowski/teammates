CREATE OR REPLACE FUNCTION update_event_status()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.events
  SET status = 'held'
  WHERE status = 'active'
    AND event_time + INTERVAL '3 hours' < now();
END;
$$;