DROP FUNCTION IF EXISTS public.fn_auxiliary_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_auxiliary_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code text, name text, description text, enable boolean, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT x.id, x.code, x.name, x.description, x.enable,
        COUNT(*) OVER() AS total_count
    FROM public."Auxiliary" x
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR x.code ILIKE '%' || TRIM(p_search) || '%' OR x.name ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY x.id ASC LIMIT p_limit OFFSET p_offset;
$$;


