"use server";

import { revalidatePath } from "next/cache";
import { z } from "zod";
import { requireSession } from "@/lib/auth";
import { callProcedure, query } from "@/lib/db";

const lineSchema = z.object({
  accountId: z.number().int().positive("Seleccione una cuenta en cada línea"),
  thirdId: z.number().int().positive().nullable().optional(),
  costcenterId: z.number().int().positive().nullable().optional(),
  description: z.string().optional().default(""),
  value: z.number().refine((v) => v !== 0, "El valor de la línea no puede ser 0"),
});

const noteSchema = z.object({
  sourcesId: z.number().int().positive("Seleccione una fuente"),
  code: z.string().trim().min(1, "El consecutivo es obligatorio"),
  name: z.string().trim().min(1, "El concepto es obligatorio"),
  description: z.string().optional().default(""),
  thirdId: z.number().int().positive("Seleccione un tercero"),
  datedoc: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, "Fecha inválida"),
  lines: z.array(lineSchema).min(2, "Debe ingresar al menos 2 líneas de detalle"),
});

export async function getNextConsecutiveAction(
  sourceId: number
): Promise<{ ok: boolean; code?: string; error?: string }> {
  await requireSession();
  try {
    const res = await query<{ code: string }>(
      "SELECT public.fn_accounting_note_next_code($1) AS code",
      [sourceId]
    );
    return { ok: true, code: res.rows[0]?.code ?? "" };
  } catch (err) {
    return { ok: false, error: err instanceof Error ? err.message : "Error obteniendo consecutivo" };
  }
}

export async function createAccountingNoteAction(
  raw: z.infer<typeof noteSchema>
): Promise<{ ok: boolean; error?: string }> {
  const session = await requireSession();
  const parsed = noteSchema.safeParse(raw);
  if (!parsed.success) {
    return { ok: false, error: parsed.error.issues[0]?.message || "Datos inválidos" };
  }

  const total = parsed.data.lines.reduce((acc, l) => acc + l.value, 0);
  if (Math.abs(total) > 0.001) {
    return {
      ok: false,
      error: `La nota contable está descuadrada. Diferencia: ${total.toFixed(2)}`,
    };
  }

  try {
    await callProcedure("public.sp_accounting_note_create", [
      session.id,
      parsed.data.sourcesId,
      parsed.data.code,
      parsed.data.name,
      parsed.data.description,
      parsed.data.thirdId,
      parsed.data.datedoc,
      JSON.stringify(parsed.data.lines),
    ]);
    revalidatePath("/dashboard/transactions/accounting-note");
    revalidatePath("/dashboard/logs");
    return { ok: true };
  } catch (err) {
    return {
      ok: false,
      error: err instanceof Error ? err.message : "Error al guardar la nota contable",
    };
  }
}

export async function getAccountingNoteDetailAction(documentId: number) {
  await requireSession();
  const res = await query<{
    id: number;
    code: string;
    accountId: number;
    account_code: string;
    account_name: string;
    thirdId: number;
    third_name: string;
    costcenterId: number | null;
    costcenter_code: string | null;
    description: string;
    values: string;
    datetra: Date | string;
  }>("SELECT * FROM public.fn_accounting_note_detail($1)", [documentId]);

  return res.rows.map((r) => ({
    ...r,
    values: Number(r.values),
    datetra: r.datetra instanceof Date ? r.datetra.toISOString().slice(0, 10) : String(r.datetra).slice(0, 10),
  }));
}
