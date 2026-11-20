DROP FUNCTION IF EXISTS public.fn_currency_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_currency_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code text, name text, "exchangeRate" double precision, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT c.id, c.code, c.name, c."exchangeRate",
        COUNT(*) OVER() AS total_count
    FROM public."Currency" c
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR c.code ILIKE '%' || TRIM(p_search) || '%' OR c.name ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY c.code ASC LIMIT p_limit OFFSET p_offset;
$$;


