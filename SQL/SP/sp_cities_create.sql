CREATE OR REPLACE PROCEDURE public.sp_cities_create(
    p_user_id integer, p_code text, p_name text, p_countries_id integer, p_statecode text DEFAULT NULL, p_iata text DEFAULT NULL
) LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata)
    VALUES (p_code, p_name, p_countries_id, p_statecode, p_iata)
    RETURNING id INTO v_id;

    CALL public.sp_system_log_create(p_user_id, 'CREATE', 'Cities', 'Ciudad creada: ' || p_code, jsonb_build_object('id', v_id, 'code', p_code));
END;
$$;

