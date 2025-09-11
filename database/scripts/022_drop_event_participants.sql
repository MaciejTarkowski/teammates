-- This script drops the get_event_participants_with_profiles function and the event_participants table.
-- If event_participants is a view, you will need to manually drop it with 'DROP VIEW IF EXISTS public.event_participants;'

DROP FUNCTION IF EXISTS public.get_event_participants_with_profiles(uuid);
DROP TABLE IF EXISTS public.event_participants;
