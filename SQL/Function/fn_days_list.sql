DROP FUNCTION IF EXISTS public.fn_days_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_days_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, "date" date, enable boolean, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT d.id, d."date", d.enable,
        COUNT(*) OVER() AS total_count
    FROM public."Days" d
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR d."date"::text ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY d."date" DESC LIMIT p_limit OFFSET p_offset;
$$;


