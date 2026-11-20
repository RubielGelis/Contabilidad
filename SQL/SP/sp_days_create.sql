CREATE OR REPLACE PROCEDURE public.sp_days_create(
    p_user_id integer, p_date date, p_enable boolean DEFAULT true
) LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    INSERT INTO public."Days" ("date", enable)
    VALUES (p_date, COALESCE(p_enable, true))
    RETURNING id INTO v_id;

    CALL public.sp_system_log_create(p_user_id, 'CREATE', 'Days', 'Día contable creado: ' || p_date::text, jsonb_build_object('id', v_id, 'date', p_date));
END;
$$;

