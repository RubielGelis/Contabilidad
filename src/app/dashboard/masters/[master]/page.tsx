import { notFound } from "next/navigation";
import { requireSession } from "@/lib/auth";
import { query } from "@/lib/db";
import { MASTERS_CONFIG } from "@/lib/masters-config";
import MasterCrudClient from "./_components/MasterCrudClient";

interface PageProps {
  params: Promise<{ master: string }>;
  searchParams: Promise<{ q?: string; page?: string; pageSize?: string }>;
}

function serializeRows(rows: Record<string, unknown>[]): Record<string, unknown>[] {
  return rows.map((row) => {
    const out: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(row)) {
      if (v instanceof Date) {
        out[k] = v.toISOString();
      } else {
        out[k] = v;
      }
    }
    return out;
  });
}

export default async function MasterPage({ params, searchParams }: PageProps) {
  await requireSession();
  const { master } = await params;
  const { q = "", page: pageParam, pageSize: pageSizeParam } = await searchParams;
  const page = Math.max(1, Number(pageParam) || 1);
  const pageSize = Math.min(100, Math.max(5, Number(pageSizeParam) || 25));
  const offset = (page - 1) * pageSize;

  const config = MASTERS_CONFIG[master];
  if (!config) {
    notFound();
  }

  const res = await query<Record<string, unknown>>(
    `SELECT * FROM ${config.listFn}($1, $2, $3)`,
    [q || null, pageSize, offset]
  );
  const totalCount = Number(res.rows[0]?.total_count ?? 0);

  const selectOptions: Record<string, { value: string; label: string }[]> = {};
  for (const field of config.fields) {
    if (field.type === "select" && field.optionsFn) {
      const optRes = await query<{ id: number; code?: string; name: string }>(
        `SELECT * FROM ${field.optionsFn}(NULL, 500, 0)`
      );
      selectOptions[field.name] = optRes.rows.map((r) => ({
        value: String(r.id),
        label: r.code ? `${r.code} - ${r.name}` : r.name,
      }));
    }
  }

  return (
    <MasterCrudClient
      config={config}
      initialRows={serializeRows(res.rows)}
      initialSearch={q}
      page={page}
      pageSize={pageSize}
      totalCount={totalCount}
      selectOptions={selectOptions}
    />
  );
}
