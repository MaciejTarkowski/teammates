-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

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
  CONSTRAINT events_pkey PRIMARY KEY (id),
  CONSTRAINT events_organizer_id_fkey FOREIGN KEY (organizer_id) REFERENCES auth.users(id)
);