CREATE OR REPLACE PROCEDURE public.sp_seller_update(
    p_user_id integer, p_id integer, p_code text, p_name text, p_address text DEFAULT NULL, p_email text DEFAULT NULL, p_phone text DEFAULT NULL
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."Seller" SET code = p_code, name = p_name, address = p_address, email = p_email, phone = p_phone WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Vendedor % no encontrado', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'UPDATE', 'Seller', 'Vendedor actualizado: ' || p_code, jsonb_build_object('id', p_id, 'code', p_code));
END;
$$;

