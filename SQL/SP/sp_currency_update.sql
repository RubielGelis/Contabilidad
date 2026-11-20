CREATE OR REPLACE PROCEDURE public.sp_currency_update(
    p_user_id integer, p_id integer, p_code text, p_name text, p_exchange_rate double precision DEFAULT 1.0
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."Currency" SET code = p_code, name = p_name, "exchangeRate" = COALESCE(p_exchange_rate, 1.0) WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Moneda % no encontrada', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'UPDATE', 'Currency', 'Moneda actualizada: ' || p_code, jsonb_build_object('id', p_id, 'code', p_code));
END;
$$;

