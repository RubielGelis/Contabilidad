CREATE OR REPLACE PROCEDURE public.sp_document_type_update(
    p_user_id integer, p_id integer, p_code text, p_name text, p_description text DEFAULT '', p_enable boolean DEFAULT true
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."DocumentType" SET code = p_code, name = p_name, description = COALESCE(p_description, ''), enable = COALESCE(p_enable, true) WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Tipo de documento % no encontrado', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'UPDATE', 'DocumentType', 'Tipo de documento actualizado: ' || p_code, jsonb_build_object('id', p_id, 'code', p_code));
END;
$$;

