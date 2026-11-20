CREATE OR REPLACE PROCEDURE public.sp_square_create(
    p_user_id integer, p_code text, p_name text, p_description text DEFAULT '', p_type text DEFAULT 'G',
    p_level integer DEFAULT 1, p_parent text DEFAULT '', p_enable boolean DEFAULT true
) LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    INSERT INTO public."Square" (code, name, description, type, level, parent, enable)
    VALUES (p_code, p_name, COALESCE(p_description, ''), COALESCE(p_type, 'G'), COALESCE(p_level, 1), COALESCE(p_parent, ''), COALESCE(p_enable, true))
    RETURNING id INTO v_id;

    CALL public.sp_system_log_create(p_user_id, 'CREATE', 'Square', 'Plaza creada: ' || p_code, jsonb_build_object('id', v_id, 'code', p_code));
END;
$$;

