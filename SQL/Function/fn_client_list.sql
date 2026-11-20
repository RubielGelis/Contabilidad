DROP FUNCTION IF EXISTS public.fn_client_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_client_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code text, name text, "contactInfo" text, address text, email text, phone text, "mandatoryVariables" jsonb, "ThirdId" integer, third_name text, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT c.id, c.code, c.name, c."contactInfo", c.address, c.email, c.phone, c."mandatoryVariables", c."ThirdId", t.name AS third_name,
        COUNT(*) OVER() AS total_count
    FROM public."Client" c
    LEFT JOIN public."Third" t ON t.id = c."ThirdId"
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR c.code ILIKE '%' || TRIM(p_search) || '%' OR c.name ILIKE '%' || TRIM(p_search) || '%' OR c.email ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY c.id ASC LIMIT p_limit OFFSET p_offset;
$$;


