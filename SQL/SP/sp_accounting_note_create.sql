CREATE OR REPLACE PROCEDURE public.sp_accounting_note_create(
    p_user_id integer,
    p_sources_id integer,
    p_code text,
    p_name text,
    p_description text,
    p_third_id integer,
    p_datedoc date,
    p_lines jsonb
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_doc_id integer;
    v_debit numeric(18, 2) := 0;
    v_credit numeric(18, 2) := 0;
    v_balance numeric(18, 2) := 0;
    v_line jsonb;
    v_idx integer := 0;
    v_val numeric(18, 2);
    v_line_account_id integer;
    v_line_third_id integer;
    v_line_cc_id integer;
    v_line_desc text;
BEGIN
    IF p_lines IS NULL OR jsonb_typeof(p_lines) <> 'array' OR jsonb_array_length(p_lines) < 2 THEN
        RAISE EXCEPTION 'La nota contable debe tener al menos 2 líneas de detalle';
    END IF;

    -- Validar balance (suma de valores positivos y negativos debe ser 0)
    SELECT
        COALESCE(SUM(CASE WHEN (elem->>'value')::numeric(18, 2) > 0 THEN (elem->>'value')::numeric(18, 2) ELSE 0 END), 0),
        COALESCE(SUM(CASE WHEN (elem->>'value')::numeric(18, 2) < 0 THEN ABS((elem->>'value')::numeric(18, 2)) ELSE 0 END), 0),
        COALESCE(SUM((elem->>'value')::numeric(18, 2)), 0)
    INTO v_debit, v_credit, v_balance
    FROM jsonb_array_elements(p_lines) AS elem;

    IF v_debit = 0 AND v_credit = 0 THEN
        RAISE EXCEPTION 'La nota contable debe tener valores distintos de cero';
    END IF;

    IF v_balance <> 0 THEN
        RAISE EXCEPTION 'La nota contable está descuadrada (Débito: %, Crédito: %, Diferencia: %)', v_debit, v_credit, v_balance;
    END IF;

    -- Insertar cabecera en Document
    INSERT INTO public."Document" (
        "sourcesId", code, name, description, "thirdId",
        "values", debit, credit, exchangerate, "datedoc"
    )
    VALUES (
        p_sources_id, TRIM(p_code), TRIM(p_name), COALESCE(p_description, ''), p_third_id,
        v_debit, v_debit, v_credit, 1.0, p_datedoc
    )
    RETURNING id INTO v_doc_id;

    -- Insertar líneas de detalle en Transaction
    FOR v_line IN SELECT * FROM jsonb_array_elements(p_lines)
    LOOP
        v_idx := v_idx + 1;
        v_val := (v_line->>'value')::numeric(18, 2);
        v_line_account_id := (v_line->>'accountId')::integer;
        v_line_third_id := COALESCE(NULLIF(v_line->>'thirdId', '')::integer, p_third_id);
        v_line_cc_id := NULLIF(v_line->>'costcenterId', '')::integer;
        v_line_desc := COALESCE(NULLIF(v_line->>'description', ''), p_description, p_name);

        IF v_line_account_id IS NULL THEN
            RAISE EXCEPTION 'La línea % no tiene cuenta contable seleccionada', v_idx;
        END IF;

        IF v_val = 0 THEN
            RAISE EXCEPTION 'La línea % no puede tener valor 0', v_idx;
        END IF;

        INSERT INTO public."Transaction" (
            "sourcesId", code, name, description, "accountId", "thirdId", "costcenterId",
            "values", "valuescurrency", exchangerate, reference, "datetra"
        )
        VALUES (
            p_sources_id,
            TRIM(p_code) || '-' || LPAD(v_idx::text, 3, '0'),
            TRIM(p_name),
            v_line_desc,
            v_line_account_id,
            v_line_third_id,
            v_line_cc_id,
            v_val,
            v_val,
            1.0,
            TRIM(p_code),
            p_datedoc
        );
    END LOOP;

    CALL public.sp_system_log_create(
        p_user_id,
        'CREATE',
        'AccountingNote',
        'Nota contable creada: ' || TRIM(p_code) || ' (' || v_idx || ' líneas, valor: ' || v_debit || ')',
        jsonb_build_object('documentId', v_doc_id, 'code', TRIM(p_code), 'sourcesId', p_sources_id, 'debit', v_debit, 'credit', v_credit, 'linesCount', v_idx)
    );
END;
$$;

