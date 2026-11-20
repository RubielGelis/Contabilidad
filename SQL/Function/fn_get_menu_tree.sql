CREATE OR REPLACE FUNCTION public.fn_get_menu_tree()
RETURNS TABLE (
    id integer,
    code character varying(100),
    name character varying(255),
    parent integer,
    action character varying(500),
    disable boolean
)
LANGUAGE sql
STABLE
AS $$
    SELECT m.id, m.code, m.name, m.parent, m.action, m.disable
    FROM public."Menu" m
    WHERE COALESCE(m.disable, false) = false
    ORDER BY m.parent NULLS FIRST, m.id ASC;
$$;

