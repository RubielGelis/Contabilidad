CREATE OR REPLACE PROCEDURE public.sp_system_parameter_update(
    p_user_id integer, p_id integer, p_code text, p_order integer, p_name text, p_value text, p_description text
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."SystemParameter"
    SET code = p_code, "order" = COALESCE(p_order, 1), name = p_name, value = p_value, description = COALESCE(p_description, '')
    WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Parámetro % no encontrado', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'UPDATE', 'SystemParameter', 'Parámetro actualizado: ' || p_code, jsonb_build_object('id', p_id, 'code', p_code));
END;
$$;

