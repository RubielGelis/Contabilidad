CREATE OR REPLACE PROCEDURE public.sp_currency_create(
    p_user_id integer, p_code text, p_name text, p_exchange_rate double precision DEFAULT 1.0
) LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    INSERT INTO public."Currency" (code, name, "exchangeRate")
    VALUES (p_code, p_name, COALESCE(p_exchange_rate, 1.0))
    RETURNING id INTO v_id;

    CALL public.sp_system_log_create(p_user_id, 'CREATE', 'Currency', 'Moneda creada: ' || p_code, jsonb_build_object('id', v_id, 'code', p_code));
END;
$$;

