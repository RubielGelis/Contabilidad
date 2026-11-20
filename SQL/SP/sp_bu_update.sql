CREATE OR REPLACE PROCEDURE public.sp_bu_update(
    p_user_id integer, p_id integer, p_code text, p_name text, p_enable boolean DEFAULT true, p_books_id integer DEFAULT 1
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."BU" SET code = p_code, name = p_name, enable = COALESCE(p_enable, true), "booksId" = p_books_id WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'BU % no encontrada', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'UPDATE', 'BU', 'Unidad de negocio actualizada: ' || p_code, jsonb_build_object('id', p_id, 'code', p_code));
END;
$$;

