CREATE OR REPLACE PROCEDURE public.sp_master_variable_update(
    p_user_id integer, p_id integer, p_code text, p_name text
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."MasterVariable" SET code = p_code, name = p_name WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Variable maestra % no encontrada', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'UPDATE', 'MasterVariable', 'Variable maestra actualizada: ' || p_code, jsonb_build_object('id', p_id, 'code', p_code));
END;
$$;

