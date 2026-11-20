CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE PROCEDURE public.sp_user_update(
    p_user_id integer, p_id integer, p_name text, p_email text, p_password text, p_role_id integer
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."User"
    SET name = TRIM(p_name),
        email = TRIM(p_email),
        "roleId" = p_role_id,
        "passwordHash" = CASE
            WHEN p_password IS NOT NULL AND TRIM(p_password) <> '' THEN crypt(p_password, gen_salt('bf'))
            ELSE "passwordHash"
        END
    WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Usuario % no encontrado', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'UPDATE', 'User', 'Usuario actualizado: ' || p_name, jsonb_build_object('id', p_id, 'name', p_name, 'email', p_email, 'roleId', p_role_id));
END;
$$;

