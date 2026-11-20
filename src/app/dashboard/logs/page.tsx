import { requireSession } from "@/lib/auth";
import { query } from "@/lib/db";
import PaginationBar from "@/app/dashboard/_components/PaginationBar";

interface PageProps {
  searchParams: Promise<{ q?: string; page?: string; pageSize?: string }>;
}

export default async function SystemLogsPage({ searchParams }: PageProps) {
  await requireSession();
  const { q = "", page: pageParam, pageSize: pageSizeParam } = await searchParams;
  const page = Math.max(1, Number(pageParam) || 1);
  const pageSize = Math.min(100, Math.max(5, Number(pageSizeParam) || 25));
  const offset = (page - 1) * pageSize;

  const res = await query<{
    id: number;
    user_name: string;
    action: string;
    module: string;
    description: string;
    metadata: Record<string, unknown> | null;
    createdAt: Date | string;
    total_count: string;
  }>("SELECT * FROM public.fn_system_log_list($1, $2, $3)", [q || null, pageSize, offset]);

  const totalCount = Number(res.rows[0]?.total_count ?? 0);

  return (
    <div className="space-y-5">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Auditoría del Sistema (SystemLog)</h1>
        <p className="text-sm text-slate-500 mt-0.5">
          Registro de todos los movimientos realizados en el aplicativo a través de Stored Procedures.
        </p>
      </div>

      <form method="GET" className="flex gap-2 max-w-md">
        <input
          type="text"
          name="q"
          defaultValue={q}
          placeholder="Filtrar por usuario, acción o módulo..."
          className="flex-1 px-3 py-2 bg-white border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
        />
        <button
          type="submit"
          className="px-4 py-2 bg-slate-800 hover:bg-slate-900 text-white text-sm font-medium rounded-lg cursor-pointer"
        >
          Filtrar
        </button>
      </form>

      <div className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600 uppercase">
                <th className="px-4 py-3">Fecha</th>
                <th className="px-4 py-3">Usuario</th>
                <th className="px-4 py-3">Acción</th>
                <th className="px-4 py-3">Módulo</th>
                <th className="px-4 py-3">Descripción</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-sm text-slate-700">
              {res.rows.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-4 py-8 text-center text-slate-400">
                    No hay registros de auditoría.
                  </td>
                </tr>
              ) : (
                res.rows.map((log) => (
                  <tr key={log.id} className="hover:bg-slate-50">
                    <td className="px-4 py-2.5 whitespace-nowrap text-xs font-mono text-slate-500">
                      {log.createdAt instanceof Date
                        ? log.createdAt.toISOString().replace("T", " ").slice(0, 19)
                        : String(log.createdAt).slice(0, 19)}
                    </td>
                    <td className="px-4 py-2.5 font-medium">{log.user_name}</td>
                    <td className="px-4 py-2.5">
                      <span className="inline-flex px-2 py-0.5 rounded text-xs font-semibold bg-indigo-50 text-indigo-700">
                        {log.action}
                      </span>
                    </td>
                    <td className="px-4 py-2.5">{log.module}</td>
                    <td className="px-4 py-2.5">{log.description}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
        <PaginationBar
          basePath="/dashboard/logs"
          page={page}
          pageSize={pageSize}
          totalCount={totalCount}
          search={q}
        />
      </div>
    </div>
  );
}
