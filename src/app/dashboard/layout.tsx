import { redirect } from "next/navigation";
import { getSession } from "@/lib/auth";
import { query } from "@/lib/db";
import Sidebar, { type MenuItemRow } from "./_components/Sidebar";

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const session = await getSession();
  if (!session) {
    redirect("/login");
  }

  let menuItems: MenuItemRow[] = [];
  try {
    const res = await query<MenuItemRow>(
      "SELECT id, code, name, parent, action, disable FROM public.fn_get_menu_tree()"
    );
    menuItems = res.rows;
  } catch {
    menuItems = [];
  }

  return (
    <div className="min-h-screen flex bg-slate-50">
      <Sidebar
        menuItems={menuItems}
        userName={session.name}
        roleName={session.roleName}
      />
      <main className="flex-1 min-w-0 pt-14 lg:pt-0">
        <div className="p-6 lg:p-8 max-w-7xl mx-auto">{children}</div>
      </main>
    </div>
  );
}
