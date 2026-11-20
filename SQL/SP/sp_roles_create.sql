CREATE OR REPLACE PROCEDURE public.sp_roles_create(
    p_user_id integer, p_code text, p_name text, p_description text DEFAULT NULL, p_enable boolean DEFAULT true
) LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    INSERT INTO public."Roles" (code, name, description, enable)
    VALUES (p_code, p_name, p_description, COALESCE(p_enable, true))
    RETURNING id INTO v_id;

    CALL public.sp_system_log_create(p_user_id, 'CREATE', 'Roles', 'Rol creado: ' || p_code, jsonb_build_object('id', v_id, 'code', p_code, 'name', p_name));
END;
$$;

