"use client";

import { useEffect, useMemo, useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { MasterConfig } from "@/lib/masters-config";
import { saveMasterAction, deleteMasterAction } from "../actions";
import { ChevronDown, ChevronRight, FolderTree, Pencil, Plus, Search, Trash2, X } from "lucide-react";
import PaginationBar from "@/app/dashboard/_components/PaginationBar";

interface SelectOption {
  value: string;
  label: string;
}

interface MasterCrudClientProps {
  config: MasterConfig;
  initialRows: Record<string, unknown>[];
  initialSearch: string;
  page: number;
  pageSize: number;
  totalCount: number;
  selectOptions: Record<string, SelectOption[]>;
}

interface TreeNode {
  row: Record<string, unknown>;
  code: string;
  children: TreeNode[];
}

interface FlatTreeRow {
  row: Record<string, unknown>;
  code: string;
  depth: number;
  hasChildren: boolean;
}

export default function MasterCrudClient({
  config,
  initialRows,
  initialSearch,
  page,
  pageSize,
  totalCount,
  selectOptions,
}: MasterCrudClientProps) {
  const router = useRouter();
  const [search, setSearch] = useState(initialSearch);
  const [modalOpen, setModalOpen] = useState(false);
  const [editId, setEditId] = useState<number | null>(null);
  const [formValues, setFormValues] = useState<Record<string, unknown>>({});
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [isPending, startTransition] = useTransition();

  const isTree = Boolean(config.treeParentKey);

  // Construir árbol jerárquico cuando el maestro tiene columna padre/level
  const { roots, allParentCodes } = useMemo(() => {
    if (!config.treeParentKey) {
      return { roots: [] as TreeNode[], allParentCodes: [] as string[] };
    }
    const parentKey = config.treeParentKey;
    const nodeMap = new Map<string, TreeNode>();
    const orderedNodes: TreeNode[] = [];

    for (const row of initialRows) {
      const code = String(row.code ?? row.id ?? "").trim();
      const node: TreeNode = { row, code, children: [] };
      nodeMap.set(code, node);
      orderedNodes.push(node);
    }

    const rootList: TreeNode[] = [];
    for (const node of orderedNodes) {
      const pCode = String(node.row[parentKey] ?? "").trim();
      if (pCode && pCode !== node.code && nodeMap.has(pCode)) {
        nodeMap.get(pCode)!.children.push(node);
      } else {
        rootList.push(node);
      }
    }

    const parentsWithChildren = orderedNodes
      .filter((n) => n.children.length > 0)
      .map((n) => n.code);

    return { roots: rootList, allParentCodes: parentsWithChildren };
  }, [config.treeParentKey, initialRows]);

  const [expandedCodes, setExpandedCodes] = useState<Set<string>>(() => {
    if (!isTree) return new Set();
    if (initialSearch.trim()) return new Set(allParentCodes);
    return new Set();
  });

  useEffect(() => {
    if (!isTree) return;
    if (initialSearch.trim()) {
      setExpandedCodes(new Set(allParentCodes));
    }
  }, [isTree, initialSearch, allParentCodes]);

  const visibleRows: FlatTreeRow[] = useMemo(() => {
    if (!isTree) {
      return initialRows.map((row) => ({
        row,
        code: String(row.id ?? ""),
        depth: 0,
        hasChildren: false,
      }));
    }

    const flat: FlatTreeRow[] = [];
    const walk = (nodes: TreeNode[], depth: number) => {
      for (const n of nodes) {
        const hasChildren = n.children.length > 0;
        flat.push({ row: n.row, code: n.code, depth, hasChildren });
        if (hasChildren && expandedCodes.has(n.code)) {
          walk(n.children, depth + 1);
        }
      }
    };
    walk(roots, 0);
    return flat;
  }, [isTree, initialRows, roots, expandedCodes]);

  const toggleNode = (code: string) => {
    setExpandedCodes((prev) => {
      const next = new Set(prev);
      if (next.has(code)) next.delete(code);
      else next.add(code);
      return next;
    });
  };

  const expandAll = () => setExpandedCodes(new Set(allParentCodes));
  const collapseAll = () => setExpandedCodes(new Set());

  const openCreate = (parentRow?: Record<string, unknown>) => {
    const defaults: Record<string, unknown> = {};
    for (const f of config.fields) {
      defaults[f.name] = f.defaultValue ?? (f.type === "boolean" ? false : "");
    }
    if (parentRow && config.treeParentKey) {
      defaults[config.treeParentKey] = String(parentRow.code ?? "");
      defaults.level = Number(parentRow.level ?? 0) + 1;
      if ("category" in parentRow && parentRow.category !== undefined) {
        defaults.category = parentRow.category;
      }
    }
    setEditId(null);
    setFormValues(defaults);
    setErrorMsg(null);
    setModalOpen(true);
  };

  const openEdit = (row: Record<string, unknown>) => {
    const values: Record<string, unknown> = {};
    for (const f of config.fields) {
      if (f.type === "password") {
        values[f.name] = "";
      } else if (f.type === "json" && row[f.name] !== null && row[f.name] !== undefined) {
        values[f.name] = typeof row[f.name] === "string" ? row[f.name] : JSON.stringify(row[f.name]);
      } else if (f.type === "date" && typeof row[f.name] === "string") {
        values[f.name] = String(row[f.name]).slice(0, 10);
      } else {
        values[f.name] = row[f.name] ?? (f.type === "boolean" ? false : "");
      }
    }
    setEditId(Number(row.id));
    setFormValues(values);
    setErrorMsg(null);
    setModalOpen(true);
  };

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    const q = search.trim();
    router.push(
      q
        ? `/dashboard/masters/${config.slug}?q=${encodeURIComponent(q)}`
        : `/dashboard/masters/${config.slug}`
    );
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMsg(null);
    startTransition(async () => {
      const res = await saveMasterAction(config.slug, editId, formValues);
      if (!res.ok) {
        setErrorMsg(res.error || "Error al guardar");
        return;
      }
      setModalOpen(false);
      router.refresh();
    });
  };

  const handleDelete = (id: number) => {
    if (!confirm(`¿Seguro que desea eliminar el registro #${id}?`)) return;
    startTransition(async () => {
      const res = await deleteMasterAction(config.slug, id);
      if (!res.ok) {
        alert(res.error || "No se pudo eliminar");
        return;
      }
      router.refresh();
    });
  };

  const renderCell = (row: Record<string, unknown>, key: string, type?: string) => {
    const val = row[key];
    if (val === null || val === undefined) return <span className="text-slate-400">—</span>;
    if (type === "boolean") {
      return val ? (
        <span className="inline-flex px-2 py-0.5 rounded-full text-xs font-medium bg-emerald-50 text-emerald-700 border border-emerald-200">
          Sí
        </span>
      ) : (
        <span className="inline-flex px-2 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-600 border border-slate-200">
          No
        </span>
      );
    }
    if (type === "date") {
      return String(val).slice(0, 10);
    }
    return String(val);
  };

  return (
    <div className="space-y-5">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-2xl font-bold text-slate-900">{config.title}</h1>
            {isTree && (
              <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium bg-indigo-50 text-indigo-700 border border-indigo-200">
                <FolderTree className="w-3 h-3" />
                Vista Árbol
              </span>
            )}
          </div>
          <p className="text-sm text-slate-500 mt-0.5">{config.description}</p>
        </div>
        <button
          type="button"
          onClick={() => openCreate()}
          className="inline-flex items-center gap-2 px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium rounded-lg shadow-sm transition-colors cursor-pointer self-start"
        >
          <Plus className="w-4 h-4" />
          Nuevo Registro
        </button>
      </div>

      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <form onSubmit={handleSearch} className="flex gap-2 max-w-md flex-1">
          <div className="relative flex-1">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Buscar por código o nombre..."
              className="w-full pl-9 pr-3 py-2 bg-white border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          <button
            type="submit"
            className="px-4 py-2 bg-slate-800 hover:bg-slate-900 text-white text-sm font-medium rounded-lg cursor-pointer"
          >
            Buscar
          </button>
        </form>

        {isTree && allParentCodes.length > 0 && (
          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={expandAll}
              className="px-3 py-1.5 text-xs font-medium bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 rounded-lg cursor-pointer"
            >
              Expandir todo
            </button>
            <button
              type="button"
              onClick={collapseAll}
              className="px-3 py-1.5 text-xs font-medium bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 rounded-lg cursor-pointer"
            >
              Colapsar todo
            </button>
          </div>
        )}
      </div>

      <div className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600 uppercase tracking-wider">
                {config.columns.map((col) => (
                  <th key={col.key} className="px-4 py-3 whitespace-nowrap">
                    {col.label}
                  </th>
                ))}
                <th className="px-4 py-3 text-right whitespace-nowrap">Acciones</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-sm text-slate-700">
              {visibleRows.length === 0 ? (
                <tr>
                  <td
                    colSpan={config.columns.length + 1}
                    className="px-4 py-8 text-center text-slate-400"
                  >
                    No se encontraron registros.
                  </td>
                </tr>
              ) : (
                visibleRows.map(({ row, code, depth, hasChildren }) => {
                  const isExpanded = expandedCodes.has(code);
                  const isGroup = hasChildren || row.type === "G";
                  return (
                    <tr
                      key={String(row.id)}
                      className={`hover:bg-slate-50/80 ${isGroup && isTree ? "bg-slate-50/40 font-medium" : ""}`}
                    >
                      {config.columns.map((col, colIdx) => (
                        <td key={col.key} className="px-4 py-2.5 whitespace-nowrap max-w-xs truncate">
                          {isTree && colIdx === 0 ? (
                            <div
                              className="flex items-center gap-1.5"
                              style={{ paddingLeft: `${depth * 20}px` }}
                            >
                              {hasChildren ? (
                                <button
                                  type="button"
                                  onClick={() => toggleNode(code)}
                                  className="p-0.5 rounded hover:bg-slate-200 text-slate-600 cursor-pointer"
                                  title={isExpanded ? "Colapsar" : "Desplegar"}
                                >
                                  {isExpanded ? (
                                    <ChevronDown className="w-4 h-4" />
                                  ) : (
                                    <ChevronRight className="w-4 h-4" />
                                  )}
                                </button>
                              ) : (
                                <span className="w-5 inline-block text-center text-slate-300">
                                  {depth > 0 ? "└" : ""}
                                </span>
                              )}
                              <span className="font-mono">{renderCell(row, col.key, col.type)}</span>
                            </div>
                          ) : (
                            renderCell(row, col.key, col.type)
                          )}
                        </td>
                      ))}
                      <td className="px-4 py-2.5 text-right whitespace-nowrap space-x-1">
                        {isTree && (
                          <button
                            type="button"
                            onClick={() => openCreate(row)}
                            title="Agregar hijo"
                            className="p-1.5 text-slate-500 hover:text-emerald-600 hover:bg-emerald-50 rounded-md transition-colors cursor-pointer"
                          >
                            <Plus className="w-4 h-4" />
                          </button>
                        )}
                        <button
                          type="button"
                          onClick={() => openEdit(row)}
                          title="Modificar"
                          className="p-1.5 text-slate-500 hover:text-indigo-600 hover:bg-indigo-50 rounded-md transition-colors cursor-pointer"
                        >
                          <Pencil className="w-4 h-4" />
                        </button>
                        <button
                          type="button"
                          onClick={() => handleDelete(Number(row.id))}
                          disabled={isPending}
                          title="Eliminar"
                          className="p-1.5 text-slate-500 hover:text-red-600 hover:bg-red-50 rounded-md transition-colors cursor-pointer"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
        <PaginationBar
          basePath={`/dashboard/masters/${config.slug}`}
          page={page}
          pageSize={pageSize}
          totalCount={totalCount}
          search={initialSearch}
        />
      </div>

      {modalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-white rounded-2xl shadow-xl border border-slate-200 w-full max-w-lg max-h-[90vh] flex flex-col">
            <div className="px-6 py-4 border-b border-slate-200 flex items-center justify-between">
              <h2 className="font-bold text-slate-900">
                {editId !== null ? `Editar ${config.title}` : `Nuevo ${config.title}`}
              </h2>
              <button
                type="button"
                onClick={() => setModalOpen(false)}
                className="p-1 text-slate-400 hover:text-slate-600 cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="p-6 overflow-y-auto space-y-4">
              {errorMsg && (
                <div className="p-3 rounded-lg bg-red-50 border border-red-200 text-xs text-red-700">
                  {errorMsg}
                </div>
              )}

              {config.fields.map((field) => {
                const val = formValues[field.name];
                const isReq = field.required && !(editId !== null && field.optionalOnEdit);

                if (field.type === "boolean") {
                  return (
                    <label key={field.name} className="flex items-center gap-2.5 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={Boolean(val)}
                        onChange={(e) =>
                          setFormValues((prev) => ({ ...prev, [field.name]: e.target.checked }))
                        }
                        className="w-4 h-4 rounded border-slate-300 text-indigo-600 focus:ring-indigo-500"
                      />
                      <span className="text-sm font-medium text-slate-700">{field.label}</span>
                    </label>
                  );
                }

                if (field.type === "select") {
                  const opts = field.optionsStatic ?? selectOptions[field.name] ?? [];
                  return (
                    <div key={field.name}>
                      <label className="block text-xs font-semibold text-slate-700 mb-1">
                        {field.label} {isReq && <span className="text-red-500">*</span>}
                      </label>
                      <select
                        required={isReq}
                        value={val === null || val === undefined ? "" : String(val)}
                        onChange={(e) =>
                          setFormValues((prev) => ({ ...prev, [field.name]: e.target.value }))
                        }
                        className="w-full px-3 py-2 bg-white border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      >
                        <option value="">-- Seleccione --</option>
                        {opts.map((o) => (
                          <option key={o.value} value={o.value}>
                            {o.label}
                          </option>
                        ))}
                      </select>
                    </div>
                  );
                }

                return (
                  <div key={field.name}>
                    <label className="block text-xs font-semibold text-slate-700 mb-1">
                      {field.label} {isReq && <span className="text-red-500">*</span>}
                    </label>
                    <input
                      type={field.type === "json" ? "text" : field.type}
                      step={field.type === "number" ? "any" : undefined}
                      required={isReq}
                      placeholder={field.placeholder}
                      value={val === null || val === undefined ? "" : String(val)}
                      onChange={(e) =>
                        setFormValues((prev) => ({ ...prev, [field.name]: e.target.value }))
                      }
                      className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                    />
                  </div>
                );
              })}

              <div className="pt-3 border-t border-slate-200 flex justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setModalOpen(false)}
                  className="px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-100 rounded-lg cursor-pointer"
                >
                  Cancelar
                </button>
                <button
                  type="submit"
                  disabled={isPending}
                  className="px-4 py-2 text-sm font-medium bg-indigo-600 hover:bg-indigo-700 disabled:opacity-60 text-white rounded-lg cursor-pointer"
                >
                  {isPending ? "Guardando..." : "Guardar"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
