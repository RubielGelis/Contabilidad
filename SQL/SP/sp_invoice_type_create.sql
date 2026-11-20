CREATE OR REPLACE PROCEDURE public.sp_invoice_type_create(
    p_user_id integer, p_code text, p_name text, p_description text DEFAULT '', p_enable boolean DEFAULT true
) LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    INSERT INTO public."InvoiceType" (code, name, description, enable)
    VALUES (p_code, p_name, COALESCE(p_description, ''), COALESCE(p_enable, true))
    RETURNING id INTO v_id;

    CALL public.sp_system_log_create(p_user_id, 'CREATE', 'InvoiceType', 'Tipo de factura creado: ' || p_code, jsonb_build_object('id', v_id, 'code', p_code));
END;
$$;

