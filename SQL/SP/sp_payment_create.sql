CREATE OR REPLACE PROCEDURE public.sp_payment_create(
    p_user_id integer, p_code text, p_name text, p_inactive boolean DEFAULT false, p_iscash boolean DEFAULT false, p_iscredit boolean DEFAULT false
) LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    INSERT INTO public."Payment" (code, name, inactive, iscash, iscredit)
    VALUES (p_code, p_name, COALESCE(p_inactive, false), COALESCE(p_iscash, false), COALESCE(p_iscredit, false))
    RETURNING id INTO v_id;

    CALL public.sp_system_log_create(p_user_id, 'CREATE', 'Payment', 'Forma de pago creada: ' || p_code, jsonb_build_object('id', v_id, 'code', p_code));
END;
$$;

