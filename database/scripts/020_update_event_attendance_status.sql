-- Add 'signed_up' to the check constraint
ALTER TABLE public.event_attendance
DROP CONSTRAINT event_attendance_status_check,
ADD CONSTRAINT event_attendance_status_check
CHECK (status IN ('attended', 'unjustified_absence', 'justified_absence', 'signed_up'));

-- Set the default value for the status column
ALTER TABLE public.event_attendance
ALTER COLUMN status SET DEFAULT 'signed_up';

-- Update the trigger function to ignore 'signed_up'
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
  ELSE -- 'justified_absence' or 'signed_up'
    score_change := 0;
  END IF;

  IF score_change != 0 THEN
    UPDATE public.profiles
    SET reputation_score = GREATEST(1, reputation_score + score_change) -- Ensure score doesn't drop below 1
    WHERE id = new.user_id;
  END IF;

  RETURN new;
END;
$$;
