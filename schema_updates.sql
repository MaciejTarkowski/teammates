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

ALTER TABLE public.events
ADD COLUMN cancellation_reason TEXT;

CREATE OR REPLACE FUNCTION public.add_organizer_as_participant()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.event_participants (event_id, user_id)
    VALUES (NEW.id, NEW.organizer_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER add_organizer_trigger
AFTER INSERT ON public.events
FOR EACH ROW EXECUTE FUNCTION public.add_organizer_as_participant();

CREATE TABLE public.error_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    user_id UUID REFERENCES auth.users(id),
    event_id UUID REFERENCES public.events(id),
    error_message TEXT NOT NULL,
    operation_type TEXT NOT NULL,
    event_data_snapshot JSONB
);

ALTER TABLE public.error_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated users to insert error logs" ON public.error_logs
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Allow service role to read error logs" ON public.error_logs
    FOR SELECT USING (auth.role() = 'service_role');