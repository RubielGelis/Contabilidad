CREATE OR REPLACE PROCEDURE public.sp_banks_update(
    p_user_id integer, p_id integer, p_code text, p_name text, p_enable boolean DEFAULT true, p_currency_id integer DEFAULT 1
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."Banks" SET code = p_code, name = p_name, enable = COALESCE(p_enable, true), "currencyId" = p_currency_id WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Banco % no encontrado', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'UPDATE', 'Banks', 'Banco actualizado: ' || p_code, jsonb_build_object('id', p_id, 'code', p_code));
END;
$$;

