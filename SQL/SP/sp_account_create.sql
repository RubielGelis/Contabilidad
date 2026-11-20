CREATE OR REPLACE PROCEDURE public.sp_account_create(
    p_user_id integer, p_code text, p_name text, p_level integer, p_type text, p_nature text,
    p_disable boolean DEFAULT false, p_parentcode text DEFAULT '', p_category integer DEFAULT 1
) LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    INSERT INTO public."Account" (code, name, level, type, nature, disable, parentcode, category)
    VALUES (p_code, p_name, p_level, p_type, COALESCE(p_nature, ''), COALESCE(p_disable, false), COALESCE(p_parentcode, ''), COALESCE(p_category, 1))
    RETURNING id INTO v_id;

    CALL public.sp_system_log_create(p_user_id, 'CREATE', 'Account', 'Cuenta creada: ' || p_code || ' - ' || p_name, jsonb_build_object('id', v_id, 'code', p_code));
END;
$$;

