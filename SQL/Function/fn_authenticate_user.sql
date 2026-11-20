CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION public.fn_authenticate_user(
    p_username text,
    p_password text
)
RETURNS TABLE (
    id integer,
    name text,
    email text,
    role_id integer,
    role_code text,
    role_name text
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.id,
        u.name,
        u.email,
        u."roleId" AS role_id,
        r.code AS role_code,
        r.name AS role_name
    FROM public."User" u
    INNER JOIN public."Roles" r ON r.id = u."roleId"
    WHERE (LOWER(u.name) = LOWER(TRIM(p_username)) OR LOWER(u.email) = LOWER(TRIM(p_username)))
      AND r.enable = true
      AND u."passwordHash" = crypt(p_password, u."passwordHash");
END;
$$;

