DROP FUNCTION IF EXISTS public.fn_system_parameter_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_system_parameter_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code text, "order" integer, name text, value text, description text, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT sp.id, sp.code, sp."order", sp.name, sp.value, sp.description,
        COUNT(*) OVER() AS total_count
    FROM public."SystemParameter" sp
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR sp.code ILIKE '%' || TRIM(p_search) || '%' OR sp.name ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY sp."order" ASC, sp.id ASC LIMIT p_limit OFFSET p_offset;
$$;


