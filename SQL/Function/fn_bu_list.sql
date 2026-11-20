DROP FUNCTION IF EXISTS public.fn_bu_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_bu_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code text, name text, enable boolean, "booksId" integer, books_name text, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT bu.id, bu.code, bu.name, bu.enable, bu."booksId", b.name AS books_name,
        COUNT(*) OVER() AS total_count
    FROM public."BU" bu
    LEFT JOIN public."Books" b ON b.id = bu."booksId"
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR bu.code ILIKE '%' || TRIM(p_search) || '%' OR bu.name ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY bu.id ASC LIMIT p_limit OFFSET p_offset;
$$;


