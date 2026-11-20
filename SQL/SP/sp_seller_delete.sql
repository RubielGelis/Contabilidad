CREATE OR REPLACE PROCEDURE public.sp_seller_delete(p_user_id integer, p_id integer)
LANGUAGE plpgsql AS $$
DECLARE v_code text;
BEGIN
    DELETE FROM public."Seller" WHERE id = p_id RETURNING code INTO v_code;
    IF NOT FOUND THEN RAISE EXCEPTION 'Vendedor % no encontrado', p_id; END IF;

    CALL public.sp_system_log_create(p_user_id, 'DELETE', 'Seller', 'Vendedor eliminado: ' || COALESCE(v_code, p_id::text), jsonb_build_object('id', p_id));
END;
$$;

