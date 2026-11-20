DROP FUNCTION IF EXISTS public.fn_supplier_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_supplier_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code text, name text, "contactInfo" text, address text, email text, phone text, "mandatoryVariables" jsonb, "ThirdId" integer, third_name text, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT s.id, s.code, s.name, s."contactInfo", s.address, s.email, s.phone, s."mandatoryVariables", s."ThirdId", t.name AS third_name,
        COUNT(*) OVER() AS total_count
    FROM public."Supplier" s
    LEFT JOIN public."Third" t ON t.id = s."ThirdId"
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR s.code ILIKE '%' || TRIM(p_search) || '%' OR s.name ILIKE '%' || TRIM(p_search) || '%' OR s.email ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY s.id ASC LIMIT p_limit OFFSET p_offset;
$$;


