CREATE OR REPLACE PROCEDURE public.sp_days_update(
    p_user_id integer, p_id integer, p_date date, p_enable boolean DEFAULT true
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."Days" SET "date" = p_date, enable = COALESCE(p_enable, true) WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Día % no encontrado', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'UPDATE', 'Days', 'Día contable actualizado: ' || p_date::text, jsonb_build_object('id', p_id, 'date', p_date));
END;
$$;

