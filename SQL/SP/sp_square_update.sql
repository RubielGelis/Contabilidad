CREATE OR REPLACE PROCEDURE public.sp_square_update(
    p_user_id integer, p_id integer, p_code text, p_name text, p_description text DEFAULT '', p_type text DEFAULT 'G',
    p_level integer DEFAULT 1, p_parent text DEFAULT '', p_enable boolean DEFAULT true
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."Square"
    SET code = p_code, name = p_name, description = COALESCE(p_description, ''), type = COALESCE(p_type, 'G'),
        level = COALESCE(p_level, 1), parent = COALESCE(p_parent, ''), enable = COALESCE(p_enable, true)
    WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Plaza % no encontrada', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'UPDATE', 'Square', 'Plaza actualizada: ' || p_code, jsonb_build_object('id', p_id, 'code', p_code));
END;
$$;

