DROP FUNCTION IF EXISTS public.fn_banks_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_banks_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code text, name text, enable boolean, "currencyId" integer, currency_code text, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT bk.id, bk.code, bk.name, bk.enable, bk."currencyId", c.code AS currency_code,
        COUNT(*) OVER() AS total_count
    FROM public."Banks" bk
    LEFT JOIN public."Currency" c ON c.id = bk."currencyId"
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR bk.code ILIKE '%' || TRIM(p_search) || '%' OR bk.name ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY bk.id ASC LIMIT p_limit OFFSET p_offset;
$$;


