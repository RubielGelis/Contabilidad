CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE PROCEDURE public.sp_user_create(
    p_user_id integer, p_name text, p_email text, p_password text, p_role_id integer
) LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    IF p_password IS NULL OR LENGTH(TRIM(p_password)) < 4 THEN
        RAISE EXCEPTION 'La contraseña debe tener al menos 4 caracteres';
    END IF;

    INSERT INTO public."User" (name, email, "passwordHash", "roleId")
    VALUES (TRIM(p_name), TRIM(p_email), crypt(p_password, gen_salt('bf')), p_role_id)
    RETURNING id INTO v_id;

    CALL public.sp_system_log_create(p_user_id, 'CREATE', 'User', 'Usuario creado: ' || p_name, jsonb_build_object('id', v_id, 'name', p_name, 'email', p_email, 'roleId', p_role_id));
END;
$$;

