CREATE OR REPLACE PROCEDURE public.sp_master_variable_create(
    p_user_id integer, p_code text, p_name text
) LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    INSERT INTO public."MasterVariable" (code, name)
    VALUES (p_code, p_name)
    RETURNING id INTO v_id;

    CALL public.sp_system_log_create(p_user_id, 'CREATE', 'MasterVariable', 'Variable maestra creada: ' || p_code, jsonb_build_object('id', v_id, 'code', p_code));
END;
$$;

