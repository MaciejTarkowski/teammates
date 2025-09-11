CREATE OR REPLACE FUNCTION public.add_organizer_to_attendance()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.event_attendance (event_id, user_id, status)
  VALUES (NEW.id, NEW.organizer_id, 'signed_up');
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_event_created
  AFTER INSERT ON public.events
  FOR EACH ROW EXECUTE PROCEDURE public.add_organizer_to_attendance();
