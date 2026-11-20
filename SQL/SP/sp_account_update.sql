CREATE OR REPLACE PROCEDURE public.sp_account_update(
    p_user_id integer, p_id integer, p_code text, p_name text, p_level integer, p_type text, p_nature text,
    p_disable boolean DEFAULT false, p_parentcode text DEFAULT '', p_category integer DEFAULT 1
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."Account"
    SET code = p_code, name = p_name, level = p_level, type = p_type, nature = COALESCE(p_nature, ''),
        disable = COALESCE(p_disable, false), parentcode = COALESCE(p_parentcode, ''), category = COALESCE(p_category, 1)
    WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Cuenta % no encontrada', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'UPDATE', 'Account', 'Cuenta actualizada: ' || p_code || ' - ' || p_name, jsonb_build_object('id', p_id, 'code', p_code));
END;
$$;

