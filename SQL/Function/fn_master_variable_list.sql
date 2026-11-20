DROP FUNCTION IF EXISTS public.fn_master_variable_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_master_variable_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code text, name text, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT mv.id, mv.code, mv.name,
        COUNT(*) OVER() AS total_count
    FROM public."MasterVariable" mv
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR mv.code ILIKE '%' || TRIM(p_search) || '%' OR mv.name ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY mv.id ASC LIMIT p_limit OFFSET p_offset;
$$;


