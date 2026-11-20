DROP FUNCTION IF EXISTS public.fn_invoice_type_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_invoice_type_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code text, name text, description text, enable boolean, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT it.id, it.code, it.name, it.description, it.enable,
        COUNT(*) OVER() AS total_count
    FROM public."InvoiceType" it
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR it.code ILIKE '%' || TRIM(p_search) || '%' OR it.name ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY it.id ASC LIMIT p_limit OFFSET p_offset;
$$;


