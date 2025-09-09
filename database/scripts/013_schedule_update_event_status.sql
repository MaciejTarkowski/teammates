SELECT cron.schedule(
    'update-event-status-hourly', -- A unique name for your job
    '0 * * * *',                  -- Cron schedule: every hour (at minute 0)
    'SELECT public.update_event_status();' -- The SQL command to execute, explicitly qualified
);