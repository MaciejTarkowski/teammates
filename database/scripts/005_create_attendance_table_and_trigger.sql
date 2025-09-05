-- Create the attendance table
CREATE TABLE public.event_attendance (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  event_id uuid NOT NULL,
  user_id uuid NOT NULL,
  status text NOT NULL CHECK (status IN ('attended', 'unjustified_absence', 'justified_absence')),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT event_attendance_pkey PRIMARY KEY (id),
  CONSTRAINT event_attendance_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE,
  CONSTRAINT event_attendance_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE,
  CONSTRAINT event_attendance_unique UNIQUE (event_id, user_id)
);

-- Function to update reputation score
CREATE OR REPLACE FUNCTION public.update_reputation_score()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  score_change integer;
BEGIN
  IF new.status = 'attended' THEN
    score_change := 1;
  ELSIF new.status = 'unjustified_absence' THEN
    score_change := -1;
  ELSE -- 'justified_absence'
    score_change := 0;
  END IF;

  UPDATE public.profiles
  SET reputation_score = GREATEST(1, reputation_score + score_change) -- Ensure score doesn't drop below 1
  WHERE id = new.user_id;

  RETURN new;
END;
$$;

-- Trigger to call the function
CREATE TRIGGER on_attendance_insert
  AFTER INSERT ON public.event_attendance
  FOR EACH ROW EXECUTE PROCEDURE public.update_reputation_score();
