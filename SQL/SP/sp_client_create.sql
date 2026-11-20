CREATE OR REPLACE PROCEDURE public.sp_client_create(
    p_user_id integer, p_code text, p_name text, p_contact_info text DEFAULT NULL,
    p_address text DEFAULT NULL, p_email text DEFAULT '', p_phone text DEFAULT NULL,
    p_mandatory_variables jsonb DEFAULT NULL, p_third_id integer DEFAULT 1
) LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    INSERT INTO public."Client" (code, name, "contactInfo", address, email, phone, "mandatoryVariables", "ThirdId")
    VALUES (p_code, p_name, p_contact_info, p_address, p_email, p_phone, p_mandatory_variables, p_third_id)
    RETURNING id INTO v_id;

    CALL public.sp_system_log_create(p_user_id, 'CREATE', 'Client', 'Cliente creado: ' || p_code || ' - ' || p_name, jsonb_build_object('id', v_id, 'code', p_code));
END;
$$;

