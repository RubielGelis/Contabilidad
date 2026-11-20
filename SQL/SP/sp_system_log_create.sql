CREATE OR REPLACE PROCEDURE public.sp_system_log_create(
    p_user_id integer,
    p_action text,
    p_module text,
    p_description text,
    p_metadata jsonb DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."SystemLog" ("userId", action, module, description, metadata)
    VALUES (p_user_id, p_action, p_module, p_description, p_metadata);
END;
$$;

