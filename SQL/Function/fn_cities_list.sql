DROP FUNCTION IF EXISTS public.fn_cities_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_cities_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code character varying(10), name character varying(100), "countriesId" integer, country_name character varying(100), statecode character varying(25), iata character varying(10), total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT ci.id, ci.code, ci.name, ci."countriesId", co.name AS country_name, ci.statecode, ci.iata,
        COUNT(*) OVER() AS total_count
    FROM public."Cities" ci
    LEFT JOIN public."Countries" co ON co.id = ci."countriesId"
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR ci.code ILIKE '%' || TRIM(p_search) || '%' OR ci.name ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY ci.name ASC LIMIT p_limit OFFSET p_offset;
$$;


