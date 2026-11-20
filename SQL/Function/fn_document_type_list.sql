DROP FUNCTION IF EXISTS public.fn_document_type_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_document_type_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code text, name text, description text, enable boolean, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT dt.id, dt.code, dt.name, dt.description, dt.enable,
        COUNT(*) OVER() AS total_count
    FROM public."DocumentType" dt
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR dt.code ILIKE '%' || TRIM(p_search) || '%' OR dt.name ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY dt.id ASC LIMIT p_limit OFFSET p_offset;
$$;


