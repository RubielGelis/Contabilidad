import { requireSession } from "@/lib/auth";
import { query } from "@/lib/db";
import AccountingNoteClient from "./_components/AccountingNoteClient";

interface PageProps {
  searchParams: Promise<{ q?: string; page?: string; pageSize?: string }>;
}

export default async function AccountingNotePage({ searchParams }: PageProps) {
  await requireSession();
  const { q = "", page: pageParam, pageSize: pageSizeParam } = await searchParams;
  const page = Math.max(1, Number(pageParam) || 1);
  const pageSize = Math.min(100, Math.max(5, Number(pageSizeParam) || 15));
  const offset = (page - 1) * pageSize;

  const [sourcesRes, accountsRes, thirdsRes, ccRes, notesRes] = await Promise.all([
    query<{ id: number; code: string; name: string }>(
      "SELECT id, code, name FROM public.fn_sources_list(NULL, 200, 0) WHERE enable = true"
    ),
    query<{ id: number; code: string; name: string; type: string }>(
      "SELECT id, code, name, type FROM public.fn_account_list(NULL, 1500, 0) WHERE COALESCE(disable, false) = false"
    ),
    query<{ id: number; code: string; name: string }>(
      "SELECT id, code, name FROM public.fn_third_list(NULL, 500, 0)"
    ),
    query<{ id: number; code: string; name: string }>(
      "SELECT id, code, name FROM public.fn_cost_center_list(NULL, 500, 0) WHERE enable = true"
    ),
    query<{
      id: number;
      source_code: string;
      source_name: string;
      code: string;
      name: string;
      description: string;
      third_name: string;
      values: string;
      debit: string;
      credit: string;
      datedoc: Date | string;
      total_count: string;
    }>("SELECT * FROM public.fn_accounting_note_list($1, $2, $3)", [q || null, pageSize, offset]),
  ]);

  const totalCount = Number(notesRes.rows[0]?.total_count ?? 0);

  let initialConsecutive = "";
  if (sourcesRes.rows[0]) {
    const nextRes = await query<{ code: string }>(
      "SELECT public.fn_accounting_note_next_code($1) AS code",
      [sourcesRes.rows[0].id]
    );
    initialConsecutive = nextRes.rows[0]?.code ?? "";
  }

  const initialNotes = notesRes.rows.map((n) => ({
    ...n,
    values: Number(n.values),
    debit: Number(n.debit),
    credit: Number(n.credit),
    datedoc:
      n.datedoc instanceof Date
        ? n.datedoc.toISOString().slice(0, 10)
        : String(n.datedoc).slice(0, 10),
  }));

  const todayStr = new Date().toISOString().slice(0, 10);

  return (
    <AccountingNoteClient
      sources={sourcesRes.rows}
      accounts={accountsRes.rows}
      thirds={thirdsRes.rows}
      costCenters={ccRes.rows}
      initialNotes={initialNotes}
      initialConsecutive={initialConsecutive}
      todayStr={todayStr}
      page={page}
      pageSize={pageSize}
      totalCount={totalCount}
      initialSearch={q}
    />
  );
}
