CREATE OR REPLACE PROCEDURE public.sp_menu_update(
    p_user_id integer, p_id integer, p_code text, p_name text, p_parent integer DEFAULT NULL, p_action text DEFAULT '/dashboard', p_disable boolean DEFAULT false
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."Menu"
    SET code = p_code, name = p_name, parent = p_parent, action = p_action, disable = COALESCE(p_disable, false)
    WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Menú % no encontrado', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'UPDATE', 'Menu', 'Menú actualizado: ' || p_code, jsonb_build_object('id', p_id, 'code', p_code));
END;
$$;

