import Link from "next/link";
import { requireSession } from "@/lib/auth";
import { MASTER_LIST } from "@/lib/masters-config";
import { Database, ArrowRight } from "lucide-react";

export default async function MastersIndexPage() {
  await requireSession();

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Maestros del Sistema</h1>
        <p className="text-sm text-slate-600 mt-1">
          Selecciona un maestro para listar, crear, modificar o eliminar registros mediante Stored Procedures.
        </p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {MASTER_LIST.map((m) => (
          <Link
            key={m.slug}
            href={`/dashboard/masters/${m.slug}`}
            className="group bg-white p-5 rounded-xl border border-slate-200 shadow-sm hover:border-indigo-300 hover:shadow-md transition-all flex items-start justify-between gap-3"
          >
            <div className="min-w-0">
              <div className="flex items-center gap-2">
                <Database className="w-4 h-4 text-indigo-600 shrink-0" />
                <h2 className="font-semibold text-sm text-slate-900 truncate">{m.title}</h2>
              </div>
              <p className="text-xs text-slate-500 mt-1 line-clamp-2">{m.description}</p>
            </div>
            <ArrowRight className="w-4 h-4 text-slate-400 group-hover:text-indigo-600 shrink-0 mt-0.5" />
          </Link>
        ))}
      </div>
    </div>
  );
}
