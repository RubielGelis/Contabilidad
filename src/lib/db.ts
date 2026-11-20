import { Pool, QueryResult, QueryResultRow } from "pg";

declare global {
  var __pgPool: Pool | undefined;
}

function getPool(): Pool {
  if (!globalThis.__pgPool) {
    const connectionString = process.env.DATABASE_URL;
    if (!connectionString) {
      throw new Error("DATABASE_URL no está configurada en las variables de entorno.");
    }
    globalThis.__pgPool = new Pool({
      connectionString,
      max: 15,
      idleTimeoutMillis: 30000,
    });
  }
  return globalThis.__pgPool;
}

export async function query<T extends QueryResultRow = QueryResultRow>(
  sql: string,
  params: unknown[] = []
): Promise<QueryResult<T>> {
  const pool = getPool();
  return pool.query<T>(sql, params);
}

export async function callProcedure(
  procedureName: string,
  params: unknown[] = []
): Promise<void> {
  const placeholders = params.map((_, idx) => `$${idx + 1}`).join(", ");
  const sql = `CALL ${procedureName}(${placeholders})`;
  await query(sql, params);
}
