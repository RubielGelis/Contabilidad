import { callProcedure } from "./db";

export async function logSystemMovement(
  userId: number | null,
  action: string,
  module: string,
  description: string,
  metadata: Record<string, unknown> | null = null
): Promise<void> {
  await callProcedure("public.sp_system_log_create", [
    userId,
    action,
    module,
    description,
    metadata ? JSON.stringify(metadata) : null,
  ]);
}
