CREATE OR REPLACE FUNCTION public.fn_accounting_note_detail(p_document_id integer)
RETURNS TABLE (
    id integer,
    code text,
    "accountId" integer,
    account_code text,
    account_name text,
    "thirdId" integer,
    third_name text,
    "costcenterId" integer,
    costcenter_code text,
    description text,
    "values" numeric(18, 2),
    "datetra" date
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        t.id,
        t.code,
        t."accountId",
        a.code AS account_code,
        a.name AS account_name,
        t."thirdId",
        th.name AS third_name,
        t."costcenterId",
        cc.code AS costcenter_code,
        t.description,
        t."values",
        t."datetra"
    FROM public."Document" d
    INNER JOIN public."Transaction" t ON t."sourcesId" = d."sourcesId" AND t.reference = d.code
    LEFT JOIN public."Account" a ON a.id = t."accountId"
    LEFT JOIN public."Third" th ON th.id = t."thirdId"
    LEFT JOIN public."CostCenter" cc ON cc.id = t."costcenterId"
    WHERE d.id = p_document_id
    ORDER BY t.id ASC;
$$;

