DROP FUNCTION IF EXISTS public.fn_accounting_note_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_accounting_note_list(
    p_search text DEFAULT NULL,
    p_limit integer DEFAULT 50,
    p_offset integer DEFAULT 0
)
RETURNS TABLE (
    id integer,
    "sourcesId" integer,
    source_code text,
    source_name text,
    code text,
    name text,
    description text,
    "thirdId" integer,
    third_name text,
    "values" numeric(18, 2),
    debit numeric(18, 2),
    credit numeric(18, 2),
    "datedoc" date,
    "date" timestamp without time zone
, total_count bigint)
LANGUAGE sql
STABLE
AS $$
    SELECT
        d.id,
        d."sourcesId",
        s.code AS source_code,
        s.name AS source_name,
        d.code,
        d.name,
        d.description,
        d."thirdId",
        th.name AS third_name,
        d."values",
        d.debit,
        d.credit,
        d."datedoc",
        d."date",
        COUNT(*) OVER() AS total_count
    FROM public."Document" d
    INNER JOIN public."Sources" s ON s.id = d."sourcesId"
    INNER JOIN public."Third" th ON th.id = d."thirdId"
    WHERE (
        p_search IS NULL OR TRIM(p_search) = ''
        OR d.code ILIKE '%' || TRIM(p_search) || '%'
        OR d.name ILIKE '%' || TRIM(p_search) || '%'
        OR d.description ILIKE '%' || TRIM(p_search) || '%'
        OR th.name ILIKE '%' || TRIM(p_search) || '%'
    )
    ORDER BY d."datedoc" DESC, d.id DESC
    LIMIT p_limit OFFSET p_offset;
$$;


