DROP FUNCTION IF EXISTS public.fn_countries_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_countries_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code character varying(10), name character varying(100), dane character varying(25), region character varying(50), prefix character varying(10), "curencyId" integer, currency_code text, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT co.id, co.code, co.name, co.dane, co.region, co.prefix, co."curencyId", cu.code AS currency_code,
        COUNT(*) OVER() AS total_count
    FROM public."Countries" co
    LEFT JOIN public."Currency" cu ON cu.id = co."curencyId"
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR co.code ILIKE '%' || TRIM(p_search) || '%' OR co.name ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY co.name ASC LIMIT p_limit OFFSET p_offset;
$$;


