DROP FUNCTION IF EXISTS public.fn_menu_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_menu_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code character varying(100), name character varying(255), parent integer, action character varying(500), disable boolean, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT m.id, m.code, m.name, m.parent, m.action, m.disable,
        COUNT(*) OVER() AS total_count
    FROM public."Menu" m
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR m.code ILIKE '%' || TRIM(p_search) || '%' OR m.name ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY m.id ASC LIMIT p_limit OFFSET p_offset;
$$;


