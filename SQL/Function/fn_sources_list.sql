DROP FUNCTION IF EXISTS public.fn_sources_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_sources_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code text, name text, description text, report text, enable boolean, "documentTypeId" integer, document_type_name text, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT s.id, s.code, s.name, s.description, s.report, s.enable, s."documentTypeId", dt.name AS document_type_name,
        COUNT(*) OVER() AS total_count
    FROM public."Sources" s
    LEFT JOIN public."DocumentType" dt ON dt.id = s."documentTypeId"
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR s.code ILIKE '%' || TRIM(p_search) || '%' OR s.name ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY s.id ASC LIMIT p_limit OFFSET p_offset;
$$;


