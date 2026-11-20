"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import {
  BookOpenCheck,
  ChevronDown,
  ChevronRight,
  Database,
  FileSpreadsheet,
  History,
  LayoutDashboard,
  LogOut,
  Menu as MenuIcon,
  X,
} from "lucide-react";
import { logoutAction } from "@/app/login/actions";

export interface MenuItemRow {
  id: number;
  code: string;
  name: string;
  parent: number | null;
  action: string;
  disable: boolean;
}

interface SidebarProps {
  menuItems: MenuItemRow[];
  userName: string;
  roleName: string;
}

export default function Sidebar({ menuItems, userName, roleName }: SidebarProps) {
  const pathname = usePathname();
  const [mobileOpen, setMobileOpen] = useState(false);

  const parents = menuItems.filter((m) => m.parent === null);
  const childrenByParent = new Map<number, MenuItemRow[]>();
  for (const item of menuItems) {
    if (item.parent !== null) {
      const list = childrenByParent.get(item.parent) ?? [];
      list.push(item);
      childrenByParent.set(item.parent, list);
    }
  }

  const [openGroups, setOpenGroups] = useState<Record<string, boolean>>({
    MAESTROS: pathname.startsWith("/dashboard/masters"),
    TRANSACCIONES: pathname.startsWith("/dashboard/transactions"),
  });

  const toggleGroup = (code: string) => {
    setOpenGroups((prev) => ({ ...prev, [code]: !prev[code] }));
  };

  const getIcon = (code: string) => {
    if (code === "DASHBOARD") return <LayoutDashboard className="w-4 h-4 shrink-0" />;
    if (code === "MAESTROS") return <Database className="w-4 h-4 shrink-0" />;
    if (code === "TRANSACCIONES") return <FileSpreadsheet className="w-4 h-4 shrink-0" />;
    return <History className="w-4 h-4 shrink-0" />;
  };

  const navContent = (
    <div className="flex flex-col h-full bg-slate-900 text-slate-100 w-72 shrink-0">
      <div className="px-5 py-4 border-b border-slate-800 flex items-center justify-between">
        <Link href="/dashboard" className="flex items-center gap-2.5">
          <div className="p-2 bg-indigo-600 rounded-lg">
            <BookOpenCheck className="w-5 h-5 text-white" />
          </div>
          <div>
            <span className="font-bold text-sm tracking-tight block">Contabilidad</span>
            <span className="text-[11px] text-slate-400 block">PostgreSQL + Next.js</span>
          </div>
        </Link>
        <button
          type="button"
          onClick={() => setMobileOpen(false)}
          className="lg:hidden p-1 text-slate-400 hover:text-white"
        >
          <X className="w-5 h-5" />
        </button>
      </div>

      <nav className="flex-1 overflow-y-auto px-3 py-4 space-y-1">
        {parents.map((parent) => {
          const children = childrenByParent.get(parent.id) ?? [];
          const hasChildren = children.length > 0;
          const isOpen = !!openGroups[parent.code];
          const isActive = pathname === parent.action;

          if (!hasChildren) {
            return (
              <Link
                key={parent.id}
                href={parent.action}
                onClick={() => setMobileOpen(false)}
                className={`flex items-center gap-2.5 px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                  isActive
                    ? "bg-indigo-600 text-white"
                    : "text-slate-300 hover:bg-slate-800 hover:text-white"
                }`}
              >
                {getIcon(parent.code)}
                <span>{parent.name}</span>
              </Link>
            );
          }

          return (
            <div key={parent.id} className="space-y-1">
              <button
                type="button"
                onClick={() => toggleGroup(parent.code)}
                className="w-full flex items-center justify-between px-3 py-2 rounded-lg text-sm font-medium text-slate-300 hover:bg-slate-800 hover:text-white transition-colors cursor-pointer"
              >
                <span className="flex items-center gap-2.5">
                  {getIcon(parent.code)}
                  <span>{parent.name}</span>
                </span>
                {isOpen ? <ChevronDown className="w-4 h-4" /> : <ChevronRight className="w-4 h-4" />}
              </button>

              {isOpen && (
                <div className="ml-4 pl-3 border-l border-slate-800 space-y-0.5">
                  {children.map((child) => {
                    const childActive = pathname === child.action;
                    return (
                      <Link
                        key={child.id}
                        href={child.action}
                        onClick={() => setMobileOpen(false)}
                        className={`block px-3 py-1.5 rounded-md text-xs font-medium transition-colors ${
                          childActive
                            ? "bg-indigo-600 text-white"
                            : "text-slate-400 hover:bg-slate-800 hover:text-white"
                        }`}
                      >
                        {child.name}
                      </Link>
                    );
                  })}
                </div>
              )}
            </div>
          );
        })}
      </nav>

      <div className="p-4 border-t border-slate-800 bg-slate-950/50">
        <div className="flex items-center justify-between gap-2">
          <div className="min-w-0">
            <p className="text-xs font-semibold text-white truncate">{userName}</p>
            <p className="text-[11px] text-slate-400 truncate">{roleName}</p>
          </div>
          <form action={logoutAction}>
            <button
              type="submit"
              title="Cerrar sesión"
              className="p-2 rounded-lg text-slate-400 hover:text-white hover:bg-slate-800 transition-colors cursor-pointer"
            >
              <LogOut className="w-4 h-4" />
            </button>
          </form>
        </div>
      </div>
    </div>
  );

  return (
    <>
      <div className="hidden lg:flex">{navContent}</div>

      <div className="lg:hidden fixed top-0 left-0 right-0 z-30 bg-slate-900 text-white px-4 py-3 flex items-center justify-between border-b border-slate-800">
        <button
          type="button"
          onClick={() => setMobileOpen(true)}
          className="p-1.5 rounded-md hover:bg-slate-800"
        >
          <MenuIcon className="w-5 h-5" />
        </button>
        <span className="font-semibold text-sm">Contabilidad</span>
        <div className="w-8" />
      </div>

      {mobileOpen && (
        <div className="lg:hidden fixed inset-0 z-40 flex">
          <div className="fixed inset-0 bg-black/50" onClick={() => setMobileOpen(false)} />
          <div className="relative z-50 flex">{navContent}</div>
        </div>
      )}
    </>
  );
}
