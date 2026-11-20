DROP FUNCTION IF EXISTS public.fn_third_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_third_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code text, name text, "contactInfo" text, address text, phone text, "mandatoryVariables" jsonb, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT t.id, t.code, t.name, t."contactInfo", t.address, t.phone, t."mandatoryVariables",
        COUNT(*) OVER() AS total_count
    FROM public."Third" t
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR t.code ILIKE '%' || TRIM(p_search) || '%' OR t.name ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY t.id ASC LIMIT p_limit OFFSET p_offset;
$$;


