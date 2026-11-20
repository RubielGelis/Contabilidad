DROP FUNCTION IF EXISTS public.fn_books_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_books_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code text, name text, enable boolean, "currencyId" integer, currency_code text, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT b.id, b.code, b.name, b.enable, b."currencyId", c.code AS currency_code,
        COUNT(*) OVER() AS total_count
    FROM public."Books" b
    LEFT JOIN public."Currency" c ON c.id = b."currencyId"
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR b.code ILIKE '%' || TRIM(p_search) || '%' OR b.name ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY b.id ASC LIMIT p_limit OFFSET p_offset;
$$;


