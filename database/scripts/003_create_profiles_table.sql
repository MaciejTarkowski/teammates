CREATE TABLE public.profiles (
  id uuid NOT NULL,
  user_metadata jsonb,
  reputation_score integer NOT NULL DEFAULT 10, -- Start with a neutral score
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE
);
