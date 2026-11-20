CREATE OR REPLACE PROCEDURE public.sp_books_create(
    p_user_id integer, p_code text, p_name text, p_enable boolean DEFAULT true, p_currency_id integer DEFAULT 1
) LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    INSERT INTO public."Books" (code, name, enable, "currencyId")
    VALUES (p_code, p_name, COALESCE(p_enable, true), p_currency_id)
    RETURNING id INTO v_id;

    CALL public.sp_system_log_create(p_user_id, 'CREATE', 'Books', 'Libro creado: ' || p_code, jsonb_build_object('id', v_id, 'code', p_code));
END;
$$;

