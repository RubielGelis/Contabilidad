CREATE OR REPLACE PROCEDURE public.sp_cities_update(
    p_user_id integer, p_id integer, p_code text, p_name text, p_countries_id integer, p_statecode text DEFAULT NULL, p_iata text DEFAULT NULL
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."Cities" SET code = p_code, name = p_name, "countriesId" = p_countries_id, statecode = p_statecode, iata = p_iata WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Ciudad % no encontrada', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'UPDATE', 'Cities', 'Ciudad actualizada: ' || p_code, jsonb_build_object('id', p_id, 'code', p_code));
END;
$$;

