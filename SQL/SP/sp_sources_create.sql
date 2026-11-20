CREATE OR REPLACE PROCEDURE public.sp_sources_create(
    p_user_id integer, p_code text, p_name text, p_description text DEFAULT '', p_report text DEFAULT '',
    p_enable boolean DEFAULT true, p_document_type_id integer DEFAULT 1
) LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    INSERT INTO public."Sources" (code, name, description, report, enable, "documentTypeId")
    VALUES (p_code, p_name, COALESCE(p_description, ''), COALESCE(p_report, ''), COALESCE(p_enable, true), p_document_type_id)
    RETURNING id INTO v_id;

    CALL public.sp_system_log_create(p_user_id, 'CREATE', 'Sources', 'Fuente creada: ' || p_code, jsonb_build_object('id', v_id, 'code', p_code));
END;
$$;

