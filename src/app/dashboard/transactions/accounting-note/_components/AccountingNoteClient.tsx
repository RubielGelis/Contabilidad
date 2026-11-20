"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import {
  createAccountingNoteAction,
  getAccountingNoteDetailAction,
  getNextConsecutiveAction,
} from "../actions";
import { Eye, Plus, Save, Trash2, X } from "lucide-react";
import PaginationBar from "@/app/dashboard/_components/PaginationBar";

interface OptionItem {
  id: number;
  code: string;
  name: string;
  type?: string;
}

interface NoteHeaderRow {
  id: number;
  source_code: string;
  source_name: string;
  code: string;
  name: string;
  description: string;
  third_name: string;
  values: number;
  debit: number;
  credit: number;
  datedoc: string;
}

interface NoteLine {
  accountId: string;
  thirdId: string;
  costcenterId: string;
  description: string;
  value: string;
}

interface DetailRow {
  id: number;
  code: string;
  account_code: string;
  account_name: string;
  third_name: string;
  costcenter_code: string | null;
  description: string;
  values: number;
}

interface Props {
  sources: OptionItem[];
  accounts: OptionItem[];
  thirds: OptionItem[];
  costCenters: OptionItem[];
  initialNotes: NoteHeaderRow[];
  initialConsecutive: string;
  todayStr: string;
  page: number;
  pageSize: number;
  totalCount: number;
  initialSearch: string;
}

export default function AccountingNoteClient({
  sources,
  accounts,
  thirds,
  costCenters,
  initialNotes,
  initialConsecutive,
  todayStr,
  page,
  pageSize,
  totalCount,
  initialSearch,
}: Props) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();

  const [sourcesId, setSourcesId] = useState<string>(sources[0] ? String(sources[0].id) : "");
  const [code, setCode] = useState<string>(initialConsecutive);
  const [datedoc, setDatedoc] = useState<string>(todayStr);
  const [thirdId, setThirdId] = useState<string>(thirds[0] ? String(thirds[0].id) : "");
  const [name, setName] = useState<string>("");
  const [description, setDescription] = useState<string>("");
  const [lines, setLines] = useState<NoteLine[]>([
    { accountId: "", thirdId: "", costcenterId: "", description: "", value: "" },
    { accountId: "", thirdId: "", costcenterId: "", description: "", value: "" },
  ]);

  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);

  const [detailModal, setDetailModal] = useState<{
    header: NoteHeaderRow;
    rows: DetailRow[];
  } | null>(null);

  const handleSourceChange = (newSourceId: string) => {
    setSourcesId(newSourceId);
    if (!newSourceId) {
      setCode("");
      return;
    }
    startTransition(async () => {
      const res = await getNextConsecutiveAction(Number(newSourceId));
      if (res.ok && res.code) {
        setCode(res.code);
      }
    });
  };

  const addLine = () => {
    setLines((prev) => [
      ...prev,
      { accountId: "", thirdId: "", costcenterId: "", description: "", value: "" },
    ]);
  };

  const removeLine = (idx: number) => {
    if (lines.length <= 2) return;
    setLines((prev) => prev.filter((_, i) => i !== idx));
  };

  const updateLine = (idx: number, field: keyof NoteLine, value: string) => {
    setLines((prev) => prev.map((l, i) => (i === idx ? { ...l, [field]: value } : l)));
  };

  const parsedValues = lines.map((l) => {
    const n = Number(l.value);
    return Number.isFinite(n) ? n : 0;
  });
  const totalDebit = parsedValues.filter((v) => v > 0).reduce((a, b) => a + b, 0);
  const totalCredit = parsedValues.filter((v) => v < 0).reduce((a, b) => a + Math.abs(b), 0);
  const balance = parsedValues.reduce((a, b) => a + b, 0);
  const isBalanced = Math.abs(balance) < 0.001 && totalDebit > 0;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMsg(null);
    setSuccessMsg(null);

    startTransition(async () => {
      const res = await createAccountingNoteAction({
        sourcesId: Number(sourcesId),
        code,
        name,
        description,
        thirdId: Number(thirdId),
        datedoc,
        lines: lines.map((l) => ({
          accountId: Number(l.accountId),
          thirdId: l.thirdId ? Number(l.thirdId) : null,
          costcenterId: l.costcenterId ? Number(l.costcenterId) : null,
          description: l.description,
          value: Number(l.value),
        })),
      });

      if (!res.ok) {
        setErrorMsg(res.error || "Error al guardar la nota contable");
        return;
      }

      setSuccessMsg(`Nota contable ${code} creada correctamente.`);
      setName("");
      setDescription("");
      setLines([
        { accountId: "", thirdId: "", costcenterId: "", description: "", value: "" },
        { accountId: "", thirdId: "", costcenterId: "", description: "", value: "" },
      ]);
      if (sourcesId) {
        const nextRes = await getNextConsecutiveAction(Number(sourcesId));
        if (nextRes.ok && nextRes.code) setCode(nextRes.code);
      }
      router.refresh();
    });
  };

  const openDetail = (header: NoteHeaderRow) => {
    startTransition(async () => {
      const rows = await getAccountingNoteDetailAction(header.id);
      setDetailModal({ header, rows });
    });
  };

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Nota Contable</h1>
        <p className="text-sm text-slate-500 mt-0.5">
          Registra documentos contables (cabecera en <code className="text-xs bg-slate-200 px-1 rounded">Document</code> y detalle en <code className="text-xs bg-slate-200 px-1 rounded">Transaction</code>) mediante Stored Procedure.
        </p>
      </div>

      <form onSubmit={handleSubmit} className="bg-white rounded-xl border border-slate-200 shadow-sm p-6 space-y-6">
        {errorMsg && (
          <div className="p-3 rounded-lg bg-red-50 border border-red-200 text-sm text-red-700">
            {errorMsg}
          </div>
        )}
        {successMsg && (
          <div className="p-3 rounded-lg bg-emerald-50 border border-emerald-200 text-sm text-emerald-700">
            {successMsg}
          </div>
        )}

        {/* Cabecera */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">
              Fuente <span className="text-red-500">*</span>
            </label>
            <select
              required
              value={sourcesId}
              onChange={(e) => handleSourceChange(e.target.value)}
              className="w-full px-3 py-2 bg-white border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="">-- Seleccione --</option>
              {sources.map((s) => (
                <option key={s.id} value={s.id}>
                  {s.code} - {s.name}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">
              Consecutivo <span className="text-red-500">*</span>
            </label>
            <input
              type="text"
              required
              value={code}
              onChange={(e) => setCode(e.target.value)}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm font-mono focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">
              Fecha Documento <span className="text-red-500">*</span>
            </label>
            <input
              type="date"
              required
              value={datedoc}
              onChange={(e) => setDatedoc(e.target.value)}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">
              Tercero Principal <span className="text-red-500">*</span>
            </label>
            <select
              required
              value={thirdId}
              onChange={(e) => setThirdId(e.target.value)}
              className="w-full px-3 py-2 bg-white border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="">-- Seleccione --</option>
              {thirds.map((t) => (
                <option key={t.id} value={t.id}>
                  {t.code} - {t.name}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">
              Concepto / Título <span className="text-red-500">*</span>
            </label>
            <input
              type="text"
              required
              placeholder="Ej: Ajuste contable cierre de mes"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">
              Observación / Descripción
            </label>
            <input
              type="text"
              placeholder="Detalle general del comprobante"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
        </div>

        {/* Líneas de detalle */}
        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-bold text-slate-800">
              Detalle de Cuentas (Positivo = Débito, Negativo = Crédito)
            </h2>
            <button
              type="button"
              onClick={addLine}
              className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-800 text-xs font-semibold rounded-lg cursor-pointer"
            >
              <Plus className="w-3.5 h-3.5" />
              Agregar Línea
            </button>
          </div>

          <div className="overflow-x-auto border border-slate-200 rounded-lg">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600">
                  <th className="px-3 py-2 w-72">Cuenta (Account)</th>
                  <th className="px-3 py-2 w-48">Tercero (Opcional)</th>
                  <th className="px-3 py-2 w-40">C. Costo</th>
                  <th className="px-3 py-2">Descripción Línea</th>
                  <th className="px-3 py-2 w-40 text-right">Valor (+/-)</th>
                  <th className="px-3 py-2 w-12"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-sm">
                {lines.map((line, idx) => (
                  <tr key={idx}>
                    <td className="p-2">
                      <select
                        required
                        value={line.accountId}
                        onChange={(e) => updateLine(idx, "accountId", e.target.value)}
                        className="w-full px-2 py-1.5 bg-white border border-slate-300 rounded text-xs focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      >
                        <option value="">-- Cuenta --</option>
                        {accounts.map((a) => (
                          <option key={a.id} value={a.id}>
                            {a.code} - {a.name}
                          </option>
                        ))}
                      </select>
                    </td>
                    <td className="p-2">
                      <select
                        value={line.thirdId}
                        onChange={(e) => updateLine(idx, "thirdId", e.target.value)}
                        className="w-full px-2 py-1.5 bg-white border border-slate-300 rounded text-xs focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      >
                        <option value="">(Tercero cabecera)</option>
                        {thirds.map((t) => (
                          <option key={t.id} value={t.id}>
                            {t.code} - {t.name}
                          </option>
                        ))}
                      </select>
                    </td>
                    <td className="p-2">
                      <select
                        value={line.costcenterId}
                        onChange={(e) => updateLine(idx, "costcenterId", e.target.value)}
                        className="w-full px-2 py-1.5 bg-white border border-slate-300 rounded text-xs focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      >
                        <option value="">(Ninguno)</option>
                        {costCenters.map((c) => (
                          <option key={c.id} value={c.id}>
                            {c.code} - {c.name}
                          </option>
                        ))}
                      </select>
                    </td>
                    <td className="p-2">
                      <input
                        type="text"
                        placeholder="Detalle de la línea"
                        value={line.description}
                        onChange={(e) => updateLine(idx, "description", e.target.value)}
                        className="w-full px-2 py-1.5 border border-slate-300 rounded text-xs focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      />
                    </td>
                    <td className="p-2">
                      <input
                        type="number"
                        step="0.01"
                        required
                        placeholder="0.00"
                        value={line.value}
                        onChange={(e) => updateLine(idx, "value", e.target.value)}
                        className="w-full px-2 py-1.5 border border-slate-300 rounded text-xs text-right font-mono focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      />
                    </td>
                    <td className="p-2 text-center">
                      <button
                        type="button"
                        onClick={() => removeLine(idx)}
                        disabled={lines.length <= 2}
                        className="p-1 text-slate-400 hover:text-red-600 disabled:opacity-30 cursor-pointer"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Totales y Guardar */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pt-3 border-t border-slate-200">
          <div className="flex flex-wrap items-center gap-6 text-sm">
            <div>
              <span className="text-slate-500">Débitos: </span>
              <span className="font-mono font-bold text-slate-900">
                {totalDebit.toLocaleString("es-CO", { minimumFractionDigits: 2 })}
              </span>
            </div>
            <div>
              <span className="text-slate-500">Créditos: </span>
              <span className="font-mono font-bold text-slate-900">
                {totalCredit.toLocaleString("es-CO", { minimumFractionDigits: 2 })}
              </span>
            </div>
            <div>
              <span className="text-slate-500">Diferencia: </span>
              <span
                className={`font-mono font-bold ${
                  isBalanced ? "text-emerald-600" : "text-red-600"
                }`}
              >
                {balance.toLocaleString("es-CO", { minimumFractionDigits: 2 })}
              </span>
            </div>
          </div>

          <button
            type="submit"
            disabled={isPending || !isBalanced}
            className="inline-flex items-center gap-2 px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 disabled:opacity-50 text-white text-sm font-semibold rounded-lg shadow-sm transition-colors cursor-pointer"
          >
            <Save className="w-4 h-4" />
            {isPending ? "Guardando..." : "Crear Nota Contable"}
          </button>
        </div>
      </form>

      {/* Historial de Notas Contables */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="px-6 py-4 border-b border-slate-200">
          <h2 className="font-bold text-slate-900">Notas Contables Registradas</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600 uppercase">
                <th className="px-4 py-3">Consecutivo</th>
                <th className="px-4 py-3">Fuente</th>
                <th className="px-4 py-3">Fecha</th>
                <th className="px-4 py-3">Tercero</th>
                <th className="px-4 py-3">Concepto</th>
                <th className="px-4 py-3 text-right">Débito</th>
                <th className="px-4 py-3 text-right">Crédito</th>
                <th className="px-4 py-3 text-right">Detalle</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-sm text-slate-700">
              {initialNotes.length === 0 ? (
                <tr>
                  <td colSpan={8} className="px-4 py-8 text-center text-slate-400">
                    Aún no hay notas contables registradas.
                  </td>
                </tr>
              ) : (
                initialNotes.map((n) => (
                  <tr key={n.id} className="hover:bg-slate-50">
                    <td className="px-4 py-2.5 font-mono font-semibold text-indigo-700">{n.code}</td>
                    <td className="px-4 py-2.5">{n.source_code}</td>
                    <td className="px-4 py-2.5">{n.datedoc}</td>
                    <td className="px-4 py-2.5">{n.third_name}</td>
                    <td className="px-4 py-2.5">{n.name}</td>
                    <td className="px-4 py-2.5 text-right font-mono">
                      {n.debit.toLocaleString("es-CO", { minimumFractionDigits: 2 })}
                    </td>
                    <td className="px-4 py-2.5 text-right font-mono">
                      {n.credit.toLocaleString("es-CO", { minimumFractionDigits: 2 })}
                    </td>
                    <td className="px-4 py-2.5 text-right">
                      <button
                        type="button"
                        onClick={() => openDetail(n)}
                        className="p-1.5 text-slate-500 hover:text-indigo-600 hover:bg-indigo-50 rounded-md cursor-pointer"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
        <PaginationBar
          basePath="/dashboard/transactions/accounting-note"
          page={page}
          pageSize={pageSize}
          totalCount={totalCount}
          search={initialSearch}
        />
      </div>

      {detailModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-white rounded-2xl shadow-xl border border-slate-200 w-full max-w-3xl max-h-[90vh] flex flex-col">
            <div className="px-6 py-4 border-b border-slate-200 flex items-center justify-between">
              <div>
                <h3 className="font-bold text-slate-900">
                  Detalle Nota Contable: {detailModal.header.code}
                </h3>
                <p className="text-xs text-slate-500">
                  {detailModal.header.name} · {detailModal.header.datedoc}
                </p>
              </div>
              <button
                type="button"
                onClick={() => setDetailModal(null)}
                className="p-1 text-slate-400 hover:text-slate-600 cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            <div className="p-6 overflow-y-auto">
              <table className="w-full text-left border-collapse text-sm">
                <thead>
                  <tr className="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600">
                    <th className="px-3 py-2">Cuenta</th>
                    <th className="px-3 py-2">Tercero</th>
                    <th className="px-3 py-2">C. Costo</th>
                    <th className="px-3 py-2">Descripción</th>
                    <th className="px-3 py-2 text-right">Valor</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {detailModal.rows.map((r) => (
                    <tr key={r.id}>
                      <td className="px-3 py-2">
                        <span className="font-mono font-semibold">{r.account_code}</span>{" "}
                        <span className="text-slate-600">{r.account_name}</span>
                      </td>
                      <td className="px-3 py-2">{r.third_name}</td>
                      <td className="px-3 py-2">{r.costcenter_code ?? "—"}</td>
                      <td className="px-3 py-2">{r.description}</td>
                      <td
                        className={`px-3 py-2 text-right font-mono font-semibold ${
                          r.values >= 0 ? "text-emerald-700" : "text-red-700"
                        }`}
                      >
                        {r.values.toLocaleString("es-CO", { minimumFractionDigits: 2 })}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
