CREATE OR REPLACE PROCEDURE public.sp_user_delete(p_user_id integer, p_id integer)
LANGUAGE plpgsql AS $$
DECLARE v_name text;
BEGIN
    DELETE FROM public."User" WHERE id = p_id RETURNING name INTO v_name;
    IF NOT FOUND THEN RAISE EXCEPTION 'Usuario % no encontrado', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'DELETE', 'User', 'Usuario eliminado: ' || COALESCE(v_name, p_id::text), jsonb_build_object('id', p_id));
END;
$$;

