CREATE OR REPLACE PROCEDURE public.sp_days_delete(p_user_id integer, p_id integer)
LANGUAGE plpgsql AS $$
DECLARE v_date date;
BEGIN
    DELETE FROM public."Days" WHERE id = p_id RETURNING "date" INTO v_date;
    IF NOT FOUND THEN RAISE EXCEPTION 'Día % no encontrado', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'DELETE', 'Days', 'Día contable eliminado: ' || COALESCE(v_date::text, p_id::text), jsonb_build_object('id', p_id));
END;
$$;

