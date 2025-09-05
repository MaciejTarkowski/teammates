CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  _user_metadata jsonb;
BEGIN
  -- Start with an empty JSONB object if raw_user_meta_data is null
  _user_metadata := COALESCE(new.raw_user_meta_data, '{}'::jsonb);

  -- Add or overwrite the email field
  _user_metadata := jsonb_set(_user_metadata, '{email}', to_jsonb(new.email), true);

  INSERT INTO public.profiles (id, user_metadata)
  VALUES (new.id, _user_metadata);
  RETURN new;
END;
$$;

-- Trigger to call the function
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();