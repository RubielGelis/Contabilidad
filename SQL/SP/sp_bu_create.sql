CREATE OR REPLACE PROCEDURE public.sp_bu_create(
    p_user_id integer, p_code text, p_name text, p_enable boolean DEFAULT true, p_books_id integer DEFAULT 1
) LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    INSERT INTO public."BU" (code, name, enable, "booksId")
    VALUES (p_code, p_name, COALESCE(p_enable, true), p_books_id)
    RETURNING id INTO v_id;

    CALL public.sp_system_log_create(p_user_id, 'CREATE', 'BU', 'Unidad de negocio creada: ' || p_code, jsonb_build_object('id', v_id, 'code', p_code));
END;
$$;

