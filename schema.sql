-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.error_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  user_id uuid,
  event_id uuid,
  error_message text NOT NULL,
  operation_type text NOT NULL,
  event_data_snapshot jsonb,
  CONSTRAINT error_logs_pkey PRIMARY KEY (id),
  CONSTRAINT error_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id),
  CONSTRAINT error_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.event_attendance (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  event_id uuid NOT NULL,
  user_id uuid NOT NULL,
  status text NOT NULL CHECK (status = ANY (ARRAY['attended'::text, 'unjustified_absence'::text, 'justified_absence'::text])),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT event_attendance_pkey PRIMARY KEY (id),
  CONSTRAINT event_attendance_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT event_attendance_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id)
);
CREATE TABLE public.event_participants (
  event_id uuid NOT NULL,
  user_id uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT event_participants_pkey PRIMARY KEY (event_id, user_id),
  CONSTRAINT event_participants_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id),
  CONSTRAINT event_participants_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  organizer_id uuid NOT NULL DEFAULT auth.uid(),
  name character varying NOT NULL,
  description character varying,
  location_text character varying,
  event_time timestamp with time zone NOT NULL,
  max_participants integer NOT NULL DEFAULT 1 CHECK (max_participants > 0 AND max_participants <= 50),
  category text NOT NULL CHECK (category = ANY (ARRAY['piłka nożna'::text, 'koszykówka'::text, 'tenis'::text, 'wyprawa motocyklowa'::text])),
  location_lat double precision,
  location_lng double precision,
  cancellation_reason text,
  status text NOT NULL DEFAULT 'active'::text CHECK (status = ANY (ARRAY['active'::text, 'held'::text, 'cancelled'::text])),
  CONSTRAINT events_pkey PRIMARY KEY (id),
  CONSTRAINT events_organizer_id_fkey FOREIGN KEY (organizer_id) REFERENCES auth.users(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  user_metadata jsonb,
  reputation_score integer NOT NULL DEFAULT 10,
  username text UNIQUE,
  avatar_url text,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);