CREATE OR REPLACE PROCEDURE public.sp_sources_update(
    p_user_id integer, p_id integer, p_code text, p_name text, p_description text DEFAULT '', p_report text DEFAULT '',
    p_enable boolean DEFAULT true, p_document_type_id integer DEFAULT 1
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."Sources"
    SET code = p_code, name = p_name, description = COALESCE(p_description, ''), report = COALESCE(p_report, ''),
        enable = COALESCE(p_enable, true), "documentTypeId" = p_document_type_id
    WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Fuente % no encontrada', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'UPDATE', 'Sources', 'Fuente actualizada: ' || p_code, jsonb_build_object('id', p_id, 'code', p_code));
END;
$$;

