CREATE TABLE public.event_participants (
    event_id UUID NOT NULL,
    user_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    CONSTRAINT event_participants_pkey PRIMARY KEY (event_id, user_id),
    CONSTRAINT event_participants_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events (id) ON DELETE CASCADE,
    CONSTRAINT event_participants_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users (id) ON DELETE CASCADE
);

ALTER TABLE public.event_participants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Użytkownicy mogą widzieć, kto jest zapisany na wydarzenie." ON public.event_participants
    FOR SELECT USING (true);

CREATE POLICY "Użytkownicy mogą zapisywać się na wydarzenia." ON public.event_participants
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Użytkownicy mogą wypisywać się z wydarzeń." ON public.event_participants
    FOR DELETE USING (auth.uid() = user_id);