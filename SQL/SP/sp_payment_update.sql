CREATE OR REPLACE PROCEDURE public.sp_payment_update(
    p_user_id integer, p_id integer, p_code text, p_name text, p_inactive boolean DEFAULT false, p_iscash boolean DEFAULT false, p_iscredit boolean DEFAULT false
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."Payment"
    SET code = p_code, name = p_name, inactive = COALESCE(p_inactive, false), iscash = COALESCE(p_iscash, false), iscredit = COALESCE(p_iscredit, false)
    WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Forma de pago % no encontrada', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'UPDATE', 'Payment', 'Forma de pago actualizada: ' || p_code, jsonb_build_object('id', p_id, 'code', p_code));
END;
$$;

