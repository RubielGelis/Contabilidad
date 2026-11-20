CREATE OR REPLACE FUNCTION public.fn_accounting_note_next_code(p_source_id integer)
RETURNS text
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_source_code text;
    v_next_num integer;
BEGIN
    SELECT s.code INTO v_source_code
    FROM public."Sources" s
    WHERE s.id = p_source_id;

    IF v_source_code IS NULL THEN
        RAISE EXCEPTION 'Fuente % no encontrada', p_source_id;
    END IF;

    SELECT COALESCE(MAX(
        CASE
            WHEN d.code ~ ('^' || v_source_code || '-[0-9]+$')
            THEN CAST(SPLIT_PART(d.code, '-', 2) AS integer)
            ELSE 0
        END
    ), 0) + 1
    INTO v_next_num
    FROM public."Document" d
    WHERE d."sourcesId" = p_source_id;

    RETURN v_source_code || '-' || LPAD(v_next_num::text, 6, '0');
END;
$$;

