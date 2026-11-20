CREATE OR REPLACE PROCEDURE public.sp_system_parameter_create(
    p_user_id integer, p_code text, p_order integer, p_name text, p_value text, p_description text
) LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    INSERT INTO public."SystemParameter" (code, "order", name, value, description)
    VALUES (p_code, COALESCE(p_order, 1), p_name, p_value, COALESCE(p_description, ''))
    RETURNING id INTO v_id;

    CALL public.sp_system_log_create(p_user_id, 'CREATE', 'SystemParameter', 'Parámetro creado: ' || p_code, jsonb_build_object('id', v_id, 'code', p_code));
END;
$$;

