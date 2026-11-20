DROP FUNCTION IF EXISTS public.fn_payment_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_payment_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code text, name text, inactive boolean, iscash boolean, iscredit boolean, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT p.id, p.code, p.name, p.inactive, p.iscash, p.iscredit,
        COUNT(*) OVER() AS total_count
    FROM public."Payment" p
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR p.code ILIKE '%' || TRIM(p_search) || '%' OR p.name ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY p.id ASC LIMIT p_limit OFFSET p_offset;
$$;


