CREATE OR REPLACE PROCEDURE public.sp_third_create(
    p_user_id integer, p_code text, p_name text, p_contact_info text DEFAULT NULL,
    p_address text DEFAULT NULL, p_phone text DEFAULT NULL, p_mandatory_variables jsonb DEFAULT NULL
) LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    INSERT INTO public."Third" (code, name, "contactInfo", address, phone, "mandatoryVariables")
    VALUES (p_code, p_name, p_contact_info, p_address, p_phone, p_mandatory_variables)
    RETURNING id INTO v_id;

    CALL public.sp_system_log_create(p_user_id, 'CREATE', 'Third', 'Tercero creado: ' || p_code || ' - ' || p_name, jsonb_build_object('id', v_id, 'code', p_code));
END;
$$;

