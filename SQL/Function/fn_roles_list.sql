DROP FUNCTION IF EXISTS public.fn_roles_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_roles_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code text, name text, description text, enable boolean, date timestamptz, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT r.id, r.code, r.name, r.description, r.enable, r.date,
        COUNT(*) OVER() AS total_count
    FROM public."Roles" r
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR r.code ILIKE '%' || TRIM(p_search) || '%' OR r.name ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY r.id ASC LIMIT p_limit OFFSET p_offset;
$$;


