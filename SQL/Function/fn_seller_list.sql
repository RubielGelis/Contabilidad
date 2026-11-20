DROP FUNCTION IF EXISTS public.fn_seller_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_seller_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code text, name text, address text, email text, phone text, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT sl.id, sl.code, sl.name, sl.address, sl.email, sl.phone,
        COUNT(*) OVER() AS total_count
    FROM public."Seller" sl
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR sl.code ILIKE '%' || TRIM(p_search) || '%' OR sl.name ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY sl.id ASC LIMIT p_limit OFFSET p_offset;
$$;


