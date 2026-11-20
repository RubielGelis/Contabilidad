DROP FUNCTION IF EXISTS public.fn_system_log_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_system_log_list(
    p_search text DEFAULT NULL,
    p_limit integer DEFAULT 100,
    p_offset integer DEFAULT 0
)
RETURNS TABLE (
    id integer,
    "userId" integer,
    user_name text,
    action text,
    module text,
    description text,
    metadata jsonb,
    "createdAt" timestamp(3) without time zone
, total_count bigint)
LANGUAGE sql
STABLE
AS $$
    SELECT
        l.id,
        l."userId",
        COALESCE(u.name, 'Sistema') AS user_name,
        l.action,
        l.module,
        l.description,
        l.metadata,
        l."createdAt",
        COUNT(*) OVER() AS total_count
    FROM public."SystemLog" l
    LEFT JOIN public."User" u ON u.id = l."userId"
    WHERE (
        p_search IS NULL OR TRIM(p_search) = ''
        OR l.action ILIKE '%' || TRIM(p_search) || '%'
        OR l.module ILIKE '%' || TRIM(p_search) || '%'
        OR l.description ILIKE '%' || TRIM(p_search) || '%'
        OR COALESCE(u.name, '') ILIKE '%' || TRIM(p_search) || '%'
    )
    ORDER BY l."createdAt" DESC, l.id DESC
    LIMIT p_limit OFFSET p_offset;
$$;


