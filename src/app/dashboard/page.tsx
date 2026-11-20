import Link from "next/link";
import { requireSession } from "@/lib/auth";
import { MASTER_LIST } from "@/lib/masters-config";
import { Database, FileSpreadsheet, History, ArrowRight } from "lucide-react";

export default async function DashboardPage() {
  const session = await requireSession();

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">
          Bienvenido, {session.name}
        </h1>
        <p className="text-sm text-slate-600 mt-1">
          Rol activo: <span className="font-medium text-slate-800">{session.roleName}</span> · Todas las operaciones se ejecutan mediante Stored Procedures y quedan registradas en <code className="text-xs bg-slate-200 px-1.5 py-0.5 rounded">SystemLog</code>.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
        <Link
          href="/dashboard/masters"
          className="group bg-white p-6 rounded-xl border border-slate-200 shadow-sm hover:border-indigo-300 hover:shadow-md transition-all"
        >
          <div className="flex items-center justify-between">
            <div className="p-2.5 bg-indigo-50 text-indigo-600 rounded-lg">
              <Database className="w-6 h-6" />
            </div>
            <ArrowRight className="w-4 h-4 text-slate-400 group-hover:text-indigo-600 transition-colors" />
          </div>
          <h2 className="mt-4 font-semibold text-slate-900">Maestros ({MASTER_LIST.length})</h2>
          <p className="mt-1 text-xs text-slate-500">
            Listar, crear, modificar y eliminar todos los catálogos del sistema vía Stored Procedures.
          </p>
        </Link>

        <Link
          href="/dashboard/transactions/accounting-note"
          className="group bg-white p-6 rounded-xl border border-slate-200 shadow-sm hover:border-emerald-300 hover:shadow-md transition-all"
        >
          <div className="flex items-center justify-between">
            <div className="p-2.5 bg-emerald-50 text-emerald-600 rounded-lg">
              <FileSpreadsheet className="w-6 h-6" />
            </div>
            <ArrowRight className="w-4 h-4 text-slate-400 group-hover:text-emerald-600 transition-colors" />
          </div>
          <h2 className="mt-4 font-semibold text-slate-900">Nota Contable</h2>
          <p className="mt-1 text-xs text-slate-500">
            Registro de documentos contables con fuente, consecutivo y múltiples cuentas (débito/crédito).
          </p>
        </Link>

        <Link
          href="/dashboard/logs"
          className="group bg-white p-6 rounded-xl border border-slate-200 shadow-sm hover:border-amber-300 hover:shadow-md transition-all"
        >
          <div className="flex items-center justify-between">
            <div className="p-2.5 bg-amber-50 text-amber-600 rounded-lg">
              <History className="w-6 h-6" />
            </div>
            <ArrowRight className="w-4 h-4 text-slate-400 group-hover:text-amber-600 transition-colors" />
          </div>
          <h2 className="mt-4 font-semibold text-slate-900">Auditoría (SystemLog)</h2>
          <p className="mt-1 text-xs text-slate-500">
            Trazabilidad completa de inicios de sesión, maestros y notas contables.
          </p>
        </Link>
      </div>
    </div>
  );
}
