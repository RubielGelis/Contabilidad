CREATE OR REPLACE PROCEDURE public.sp_countries_create(
    p_user_id integer, p_code text, p_name text, p_dane text DEFAULT NULL, p_region text DEFAULT NULL, p_prefix text DEFAULT NULL, p_currency_id integer DEFAULT NULL
) LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId")
    VALUES (p_code, p_name, p_dane, p_region, p_prefix, p_currency_id)
    RETURNING id INTO v_id;

    CALL public.sp_system_log_create(p_user_id, 'CREATE', 'Countries', 'País creado: ' || p_code, jsonb_build_object('id', v_id, 'code', p_code));
END;
$$;

