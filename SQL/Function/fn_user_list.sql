DROP FUNCTION IF EXISTS public.fn_user_list(text, integer, integer);

CREATE OR REPLACE FUNCTION public.fn_user_list(p_search text DEFAULT NULL, p_limit integer DEFAULT 200, p_offset integer DEFAULT 0)
RETURNS TABLE (id integer, name text, email text, "roleId" integer, role_name text, "resetPasswordExpires" timestamp(3) without time zone, total_count bigint)
LANGUAGE sql STABLE AS $$
    SELECT u.id, u.name, u.email, u."roleId", r.name AS role_name, u."resetPasswordExpires",
        COUNT(*) OVER() AS total_count
    FROM public."User" u
    LEFT JOIN public."Roles" r ON r.id = u."roleId"
    WHERE (p_search IS NULL OR TRIM(p_search) = '' OR u.name ILIKE '%' || TRIM(p_search) || '%' OR u.email ILIKE '%' || TRIM(p_search) || '%')
    ORDER BY u.id ASC LIMIT p_limit OFFSET p_offset;
$$;


