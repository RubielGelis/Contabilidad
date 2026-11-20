"use server";

import { z } from "zod";
import { redirect } from "next/navigation";
import { query } from "@/lib/db";
import { setSessionCookie, clearSessionCookie, getSession } from "@/lib/auth";
import { logSystemMovement } from "@/lib/audit";

const loginSchema = z.object({
  username: z.string().trim().min(1, "Ingrese su usuario o correo"),
  password: z.string().min(1, "Ingrese su contraseña"),
});

export interface LoginState {
  error?: string;
}

export async function loginAction(
  _prevState: LoginState,
  formData: FormData
): Promise<LoginState> {
  const parsed = loginSchema.safeParse({
    username: formData.get("username"),
    password: formData.get("password"),
  });

  if (!parsed.success) {
    return { error: parsed.error.issues[0]?.message || "Datos inválidos" };
  }

  try {
    const res = await query<{
      id: number;
      name: string;
      email: string;
      role_id: number;
      role_code: string;
      role_name: string;
    }>("SELECT id, name, email, role_id, role_code, role_name FROM public.fn_authenticate_user($1, $2)", [
      parsed.data.username,
      parsed.data.password,
    ]);

    const user = res.rows[0];
    if (!user) {
      await logSystemMovement(
        null,
        "LOGIN_FAILED",
        "Auth",
        `Intento de inicio de sesión fallido para: ${parsed.data.username}`,
        { username: parsed.data.username }
      );
      return { error: "Usuario o contraseña incorrectos" };
    }

    await setSessionCookie({
      id: user.id,
      name: user.name,
      email: user.email,
      roleId: user.role_id,
      roleCode: user.role_code,
      roleName: user.role_name,
    });

    await logSystemMovement(
      user.id,
      "LOGIN",
      "Auth",
      `Inicio de sesión exitoso: ${user.name}`,
      { role: user.role_code }
    );
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Error de conexión con la base de datos";
    return { error: msg };
  }

  redirect("/dashboard");
}

export async function logoutAction(): Promise<void> {
  const session = await getSession();
  if (session) {
    try {
      await logSystemMovement(
        session.id,
        "LOGOUT",
        "Auth",
        `Cierre de sesión: ${session.name}`,
        null
      );
    } catch {
      // No bloquear el cierre de sesión si falla el log
    }
  }
  await clearSessionCookie();
  redirect("/login");
}
