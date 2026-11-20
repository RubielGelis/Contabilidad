CREATE OR REPLACE PROCEDURE public.sp_seller_create(
    p_user_id integer, p_code text, p_name text, p_address text DEFAULT NULL, p_email text DEFAULT NULL, p_phone text DEFAULT NULL
) LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    INSERT INTO public."Seller" (code, name, address, email, phone)
    VALUES (p_code, p_name, p_address, p_email, p_phone)
    RETURNING id INTO v_id;

    CALL public.sp_system_log_create(p_user_id, 'CREATE', 'Seller', 'Vendedor creado: ' || p_code, jsonb_build_object('id', v_id, 'code', p_code));
END;
$$;

