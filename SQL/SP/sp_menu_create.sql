CREATE OR REPLACE PROCEDURE public.sp_menu_create(
    p_user_id integer, p_code text, p_name text, p_parent integer DEFAULT NULL, p_action text DEFAULT '/dashboard', p_disable boolean DEFAULT false
) LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    INSERT INTO public."Menu" (code, name, parent, action, disable)
    VALUES (p_code, p_name, p_parent, p_action, COALESCE(p_disable, false))
    RETURNING id INTO v_id;

    CALL public.sp_system_log_create(p_user_id, 'CREATE', 'Menu', 'Menú creado: ' || p_code, jsonb_build_object('id', v_id, 'code', p_code));
END;
$$;

