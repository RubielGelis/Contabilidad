CREATE OR REPLACE PROCEDURE public.sp_third_update(
    p_user_id integer, p_id integer, p_code text, p_name text, p_contact_info text DEFAULT NULL,
    p_address text DEFAULT NULL, p_phone text DEFAULT NULL, p_mandatory_variables jsonb DEFAULT NULL
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."Third"
    SET code = p_code, name = p_name, "contactInfo" = p_contact_info, address = p_address, phone = p_phone, "mandatoryVariables" = p_mandatory_variables
    WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Tercero % no encontrado', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'UPDATE', 'Third', 'Tercero actualizado: ' || p_code || ' - ' || p_name, jsonb_build_object('id', p_id, 'code', p_code));
END;
$$;

