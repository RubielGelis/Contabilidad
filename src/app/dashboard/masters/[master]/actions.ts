"use server";

import { revalidatePath } from "next/cache";
import { z } from "zod";
import { requireSession } from "@/lib/auth";
import { callProcedure } from "@/lib/db";
import { MASTERS_CONFIG } from "@/lib/masters-config";

export interface ActionResult {
  ok: boolean;
  error?: string;
}

function toNullableInt(val: unknown): number | null {
  if (val === undefined || val === null || String(val).trim() === "") return null;
  const n = Number(val);
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

function toInt(val: unknown, fallback = 0): number {
  const n = toNullableInt(val);
  return n === null ? fallback : n;
}

function toFloat(val: unknown, fallback = 1): number {
  if (val === undefined || val === null || String(val).trim() === "") return fallback;
  const n = Number(val);
  return Number.isFinite(n) ? n : fallback;
}

function toBool(val: unknown): boolean {
  if (typeof val === "boolean") return val;
  return val === "true" || val === "on" || val === "1";
}

function toNullableStr(val: unknown): string | null {
  if (val === undefined || val === null) return null;
  const s = String(val).trim();
  return s === "" ? null : s;
}

function toStr(val: unknown, fallback = ""): string {
  if (val === undefined || val === null) return fallback;
  return String(val).trim();
}

function toNullableJson(val: unknown): string | null {
  const s = toNullableStr(val);
  if (!s) return null;
  JSON.parse(s); // valida JSON
  return s;
}

const idSchema = z.number().int().positive();

export async function saveMasterAction(
  slug: string,
  editId: number | null,
  raw: Record<string, unknown>
): Promise<ActionResult> {
  const session = await requireSession();
  const config = MASTERS_CONFIG[slug];
  if (!config) {
    return { ok: false, error: "Maestro no encontrado" };
  }

  const isEdit = editId !== null;
  const spName = isEdit ? config.updateSp : config.createSp;
  const prefix: unknown[] = isEdit ? [session.id, editId] : [session.id];

  try {
    let args: unknown[] = [];

    switch (slug) {
      case "roles":
        args = [toStr(raw.code), toStr(raw.name), toNullableStr(raw.description), toBool(raw.enable)];
        break;
      case "users":
        if (!isEdit && (!raw.password || toStr(raw.password).length < 4)) {
          return { ok: false, error: "La contraseña debe tener al menos 4 caracteres" };
        }
        args = [toStr(raw.name), toStr(raw.email), toStr(raw.password), toInt(raw.roleId)];
        break;
      case "menus":
        args = [toStr(raw.code), toStr(raw.name), toNullableInt(raw.parent), toStr(raw.action, "/dashboard"), toBool(raw.disable)];
        break;
      case "system-parameters":
        args = [toStr(raw.code), toInt(raw.order, 1), toStr(raw.name), toStr(raw.value), toStr(raw.description)];
        break;
      case "master-variables":
        args = [toStr(raw.code), toStr(raw.name)];
        break;
      case "accounts":
        args = [
          toStr(raw.code),
          toStr(raw.name),
          toInt(raw.level, 1),
          toStr(raw.type, "D"),
          toStr(raw.nature, ""),
          toBool(raw.disable),
          toStr(raw.parentcode, ""),
          toInt(raw.category, 1),
        ];
        break;
      case "currencies":
        args = [toStr(raw.code), toStr(raw.name), toFloat(raw.exchangeRate, 1)];
        break;
      case "books":
        args = [toStr(raw.code), toStr(raw.name), toBool(raw.enable), toInt(raw.currencyId)];
        break;
      case "bu":
        args = [toStr(raw.code), toStr(raw.name), toBool(raw.enable), toInt(raw.booksId)];
        break;
      case "auxiliaries":
      case "invoice-types":
      case "document-types":
        args = [toStr(raw.code), toStr(raw.name), toStr(raw.description), toBool(raw.enable)];
        break;
      case "cost-centers":
      case "items":
      case "squares":
        args = [
          toStr(raw.code),
          toStr(raw.name),
          toStr(raw.description),
          toStr(raw.type, "D"),
          toInt(raw.level, 1),
          toStr(raw.parent, ""),
          toBool(raw.enable),
        ];
        break;
      case "banks":
        args = [toStr(raw.code), toStr(raw.name), toBool(raw.enable), toInt(raw.currencyId)];
        break;
      case "sources":
        args = [
          toStr(raw.code),
          toStr(raw.name),
          toStr(raw.description),
          toStr(raw.report),
          toBool(raw.enable),
          toInt(raw.documentTypeId),
        ];
        break;
      case "days":
        args = [toStr(raw.date), toBool(raw.enable)];
        break;
      case "thirds":
        args = [
          toStr(raw.code),
          toStr(raw.name),
          toNullableStr(raw.contactInfo),
          toNullableStr(raw.address),
          toNullableStr(raw.phone),
          toNullableJson(raw.mandatoryVariables),
        ];
        break;
      case "clients":
      case "suppliers":
        args = [
          toStr(raw.code),
          toStr(raw.name),
          toNullableStr(raw.contactInfo),
          toNullableStr(raw.address),
          toStr(raw.email),
          toNullableStr(raw.phone),
          toNullableJson(raw.mandatoryVariables),
          toInt(raw.ThirdId),
        ];
        break;
      case "sellers":
        args = [toStr(raw.code), toStr(raw.name), toNullableStr(raw.address), toNullableStr(raw.email), toNullableStr(raw.phone)];
        break;
      case "countries":
        args = [
          toStr(raw.code),
          toStr(raw.name),
          toNullableStr(raw.dane),
          toNullableStr(raw.region),
          toNullableStr(raw.prefix),
          toNullableInt(raw.curencyId),
        ];
        break;
      case "cities":
        args = [
          toStr(raw.code),
          toStr(raw.name),
          toInt(raw.countriesId),
          toNullableStr(raw.statecode),
          toNullableStr(raw.iata),
        ];
        break;
      case "payments":
        args = [toStr(raw.code), toStr(raw.name), toBool(raw.inactive), toBool(raw.iscash), toBool(raw.iscredit)];
        break;
      default:
        return { ok: false, error: `Maestro ${slug} no soportado` };
    }

    await callProcedure(spName, [...prefix, ...args]);
    revalidatePath(`/dashboard/masters/${slug}`);
    return { ok: true };
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Error ejecutando procedimiento almacenado";
    return { ok: false, error: msg };
  }
}

export async function deleteMasterAction(slug: string, id: number): Promise<ActionResult> {
  const session = await requireSession();
  const config = MASTERS_CONFIG[slug];
  if (!config) {
    return { ok: false, error: "Maestro no encontrado" };
  }

  const parsedId = idSchema.safeParse(id);
  if (!parsedId.success) {
    return { ok: false, error: "ID inválido" };
  }

  try {
    await callProcedure(config.deleteSp, [session.id, parsedId.data]);
    revalidatePath(`/dashboard/masters/${slug}`);
    return { ok: true };
  } catch (err) {
    const msg = err instanceof Error ? err.message : "No se pudo eliminar el registro";
    return { ok: false, error: msg };
  }
}
