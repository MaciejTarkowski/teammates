-- Add status to events table
ALTER TABLE public.events
ADD COLUMN status text NOT NULL DEFAULT 'active' CHECK (status = ANY (ARRAY['active'::text, 'held'::text, 'cancelled'::text]));

-- Add username and avatar_url to profiles table
ALTER TABLE public.profiles
ADD COLUMN username text UNIQUE,
ADD COLUMN avatar_url text;

-- Update the handle_new_user function to set a default username from the email
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
BEGIN
  INSERT INTO public.profiles (id, username)
  VALUES (new.id, split_part(new.email, '@', 1));
  RETURN new;
END;
$function$;
