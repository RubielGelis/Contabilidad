CREATE OR REPLACE PROCEDURE public.sp_roles_update(
    p_user_id integer, p_id integer, p_code text, p_name text, p_description text DEFAULT NULL, p_enable boolean DEFAULT true
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."Roles"
    SET code = p_code, name = p_name, description = p_description, enable = COALESCE(p_enable, true)
    WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Rol % no encontrado', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'UPDATE', 'Roles', 'Rol actualizado: ' || p_code, jsonb_build_object('id', p_id, 'code', p_code, 'name', p_name));
END;
$$;

