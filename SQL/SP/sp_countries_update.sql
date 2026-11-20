CREATE OR REPLACE PROCEDURE public.sp_countries_update(
    p_user_id integer, p_id integer, p_code text, p_name text, p_dane text DEFAULT NULL, p_region text DEFAULT NULL, p_prefix text DEFAULT NULL, p_currency_id integer DEFAULT NULL
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."Countries" SET code = p_code, name = p_name, dane = p_dane, region = p_region, prefix = p_prefix, "curencyId" = p_currency_id WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'País % no encontrado', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'UPDATE', 'Countries', 'País actualizado: ' || p_code, jsonb_build_object('id', p_id, 'code', p_code));
END;
$$;

