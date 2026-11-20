CREATE OR REPLACE PROCEDURE public.sp_bu_delete(p_user_id integer, p_id integer)
LANGUAGE plpgsql AS $$
DECLARE v_code text;
BEGIN
    DELETE FROM public."BU" WHERE id = p_id RETURNING code INTO v_code;
    IF NOT FOUND THEN RAISE EXCEPTION 'BU % no encontrada', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'DELETE', 'BU', 'Unidad de negocio eliminada: ' || COALESCE(v_code, p_id::text), jsonb_build_object('id', p_id));
END;
$$;

