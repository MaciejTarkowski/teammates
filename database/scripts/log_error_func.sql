CREATE OR REPLACE FUNCTION public.log_error_func(
    p_event_id uuid,
    p_error_message text,
    p_operation_type text,
    p_event_data_snapshot jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.error_logs (
        user_id,
        event_id,
        error_message,
        operation_type,
        event_data_snapshot
    )
    VALUES (
        auth.uid(),
        p_event_id,
        p_error_message,
        p_operation_type,
        p_event_data_snapshot
    );
END;
$$;