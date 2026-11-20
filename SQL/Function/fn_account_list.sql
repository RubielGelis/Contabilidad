DROP FUNCTION IF EXISTS public.fn_account_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_account_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 25, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code text, name text, level integer, type text, nature text, disable boolean, date timestamp without time zone, parentcode text, category integer, total_count bigint)
LANGUAGE plpgsql STABLE AS $$
BEGIN
    IF p_search IS NULL OR TRIM(p_search) = '' THEN
        RETURN QUERY
        WITH RECURSIVE paged_roots AS (
            SELECT a.*, COUNT(*) OVER() AS root_total
            FROM public."Account" a
            WHERE COALESCE(TRIM(a.parentcode), '') = ''
            ORDER BY a.code ASC
            LIMIT p_limit OFFSET p_offset
        ),
        tree AS (
            SELECT pr.id, pr.code, pr.name, pr.level, pr.type, pr.nature, pr.disable, pr.date, pr.parentcode, pr.category, pr.root_total, 1 AS depth
            FROM paged_roots pr
            UNION ALL
            SELECT c.id, c.code, c.name, c.level, c.type, c.nature, c.disable, c.date, c.parentcode, c.category, t.root_total, t.depth + 1
            FROM public."Account" c
            INNER JOIN tree t ON TRIM(c.parentcode) = TRIM(t.code)
            WHERE TRIM(c.code) <> TRIM(t.code) AND t.depth < 20
        )
        SELECT t.id, t.code, t.name, t.level, t.type, t.nature, t.disable, t.date, t.parentcode, t.category, t.root_total AS total_count
        FROM tree t
        ORDER BY t.code ASC;
    ELSE
        RETURN QUERY
        SELECT a.id, a.code, a.name, a.level, a.type, a.nature, a.disable, a.date, a.parentcode, a.category,
            COUNT(*) OVER() AS total_count
        FROM public."Account" a
        WHERE (
            CASE
                WHEN TRIM(p_search) ~ '^[0-9]+$' THEN a.code ILIKE TRIM(p_search) || '%'
                ELSE a.code ILIKE TRIM(p_search) || '%' OR a.name ILIKE '%' || TRIM(p_search) || '%'
            END
        )
        ORDER BY a.code ASC
        LIMIT p_limit OFFSET p_offset;
    END IF;
END;
$$;
