CREATE TABLE public.events (
    id UUID DEFAULT gen_random_uuid() NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    organizer_id UUID DEFAULT auth.uid() NOT NULL,
    name CHARACTER VARYING(100) NOT NULL,
    description CHARACTER VARYING(500),
    location_text CHARACTER VARYING,
    event_time TIMESTAMP WITH TIME ZONE NOT NULL,
    max_participants INTEGER DEFAULT 1 NOT NULL,
    category TEXT NOT NULL,
    CONSTRAINT events_pkey PRIMARY KEY (id),
    CONSTRAINT events_organizer_id_fkey FOREIGN KEY (organizer_id) REFERENCES auth.users (id) ON DELETE CASCADE,
    CONSTRAINT events_max_participants_check CHECK (((max_participants > 0) AND (max_participants <= 50))),
    CONSTRAINT events_category_check CHECK ((category = ANY (ARRAY['piłka nożna'::text, 'koszykówka'::text, 'tenis'::text, 'wyprawa motocyklowa'::text])))
);

ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Użytkownicy mogą widzieć wszystkie wydarzenia" ON public.events
    FOR SELECT USING (true);

CREATE POLICY "Użytkownicy mogą dodawać własne wydarzenia" ON public.events
    FOR INSERT WITH CHECK (auth.uid() = organizer_id);
    
CREATE POLICY "Organizatorzy mogą aktualizować swoje wydarzenia" ON public.events
    FOR UPDATE USING (auth.uid() = organizer_id);
    
CREATE POLICY "Organizatorzy mogą usuwać swoje wydarzenia" ON public.events
    FOR DELETE USING (auth.uid() = organizer_id);