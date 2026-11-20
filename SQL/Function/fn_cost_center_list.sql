DROP FUNCTION IF EXISTS public.fn_cost_center_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_cost_center_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 25, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, code text, name text, description text, type text, level integer, parent text, enable boolean, total_count bigint)
LANGUAGE plpgsql STABLE AS $$
BEGIN
    IF p_search IS NULL OR TRIM(p_search) = '' THEN
        RETURN QUERY
        WITH RECURSIVE paged_roots AS (
            SELECT cc.*, COUNT(*) OVER() AS root_total
            FROM public."CostCenter" cc
            WHERE COALESCE(TRIM(cc.parent), '') = ''
            ORDER BY cc.code ASC
            LIMIT p_limit OFFSET p_offset
        ),
        tree AS (
            SELECT pr.id, pr.code, pr.name, pr.description, pr.type, pr.level, pr.parent, pr.enable, pr.root_total, 1 AS depth
            FROM paged_roots pr
            UNION ALL
            SELECT c.id, c.code, c.name, c.description, c.type, c.level, c.parent, c.enable, t.root_total, t.depth + 1
            FROM public."CostCenter" c
            INNER JOIN tree t ON TRIM(c.parent) = TRIM(t.code)
            WHERE TRIM(c.code) <> TRIM(t.code) AND t.depth < 20
        )
        SELECT t.id, t.code, t.name, t.description, t.type, t.level, t.parent, t.enable, t.root_total AS total_count
        FROM tree t
        ORDER BY t.code ASC;
    ELSE
        RETURN QUERY
        SELECT cc.id, cc.code, cc.name, cc.description, cc.type, cc.level, cc.parent, cc.enable,
            COUNT(*) OVER() AS total_count
        FROM public."CostCenter" cc
        WHERE (
            CASE
                WHEN TRIM(p_search) ~ '^[0-9]+$' THEN cc.code ILIKE TRIM(p_search) || '%'
                ELSE cc.code ILIKE TRIM(p_search) || '%' OR cc.name ILIKE '%' || TRIM(p_search) || '%'
            END
        )
        ORDER BY cc.code ASC
        LIMIT p_limit OFFSET p_offset;
    END IF;
END;
$$;
