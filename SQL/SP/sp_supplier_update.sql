CREATE OR REPLACE PROCEDURE public.sp_supplier_update(
    p_user_id integer, p_id integer, p_code text, p_name text, p_contact_info text DEFAULT NULL,
    p_address text DEFAULT NULL, p_email text DEFAULT '', p_phone text DEFAULT NULL,
    p_mandatory_variables jsonb DEFAULT NULL, p_third_id integer DEFAULT 1
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."Supplier"
    SET code = p_code, name = p_name, "contactInfo" = p_contact_info, address = p_address, email = p_email,
        phone = p_phone, "mandatoryVariables" = p_mandatory_variables, "ThirdId" = p_third_id
    WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Proveedor % no encontrado', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'UPDATE', 'Supplier', 'Proveedor actualizado: ' || p_code || ' - ' || p_name, jsonb_build_object('id', p_id, 'code', p_code));
END;
$$;

