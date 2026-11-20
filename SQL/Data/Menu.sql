-- Menú principal del aplicativo contable
-- Idempotente: puede ejecutarse múltiples veces sin errores

INSERT INTO public."Menu" (code, name, parent, action, disable)
VALUES
    ('DASHBOARD', 'Dashboard', NULL, '/dashboard', false),
    ('MAESTROS', 'Maestros', NULL, '/dashboard/masters', false),
    ('TRANSACCIONES', 'Transacciones', NULL, '/dashboard/transactions', false),
    ('AUDITORIA', 'Auditoría (SystemLog)', NULL, '/dashboard/logs', false)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    parent = EXCLUDED.parent,
    action = EXCLUDED.action,
    disable = EXCLUDED.disable;

-- Submenús de Maestros
INSERT INTO public."Menu" (code, name, parent, action, disable)
VALUES
    ('MAESTRO_ROLES', 'Roles', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/roles', false),
    ('MAESTRO_USER', 'Usuarios', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/users', false),
    ('MAESTRO_ACCOUNT', 'Plan de Cuentas', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/accounts', false),
    ('MAESTRO_THIRD', 'Terceros', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/thirds', false),
    ('MAESTRO_CLIENT', 'Clientes', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/clients', false),
    ('MAESTRO_SUPPLIER', 'Proveedores', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/suppliers', false),
    ('MAESTRO_SELLER', 'Vendedores', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/sellers', false),
    ('MAESTRO_CURRENCY', 'Monedas', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/currencies', false),
    ('MAESTRO_COUNTRIES', 'Países', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/countries', false),
    ('MAESTRO_CITIES', 'Ciudades', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/cities', false),
    ('MAESTRO_PAYMENT', 'Formas de Pago', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/payments', false),
    ('MAESTRO_BOOKS', 'Libros Contables', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/books', false),
    ('MAESTRO_BU', 'Unidades de Negocio', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/bu', false),
    ('MAESTRO_AUXILIARY', 'Auxiliares', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/auxiliaries', false),
    ('MAESTRO_COSTCENTER', 'Centros de Costo', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/cost-centers', false),
    ('MAESTRO_ITEMS', 'Ítems', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/items', false),
    ('MAESTRO_BANKS', 'Bancos', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/banks', false),
    ('MAESTRO_SQUARE', 'Plazas / Cajas', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/squares', false),
    ('MAESTRO_INVOICETYPE', 'Tipos de Factura', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/invoice-types', false),
    ('MAESTRO_DOCUMENTTYPE', 'Tipos de Documento', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/document-types', false),
    ('MAESTRO_SOURCES', 'Fuentes Contables', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/sources', false),
    ('MAESTRO_DAYS', 'Días Contables', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/days', false),
    ('MAESTRO_MASTERVARIABLE', 'Variables Maestras', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/master-variables', false),
    ('MAESTRO_SYSTEMPARAMETER', 'Parámetros del Sistema', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/system-parameters', false),
    ('MAESTRO_MENU', 'Menú', (SELECT id FROM public."Menu" WHERE code = 'MAESTROS' LIMIT 1), '/dashboard/masters/menus', false)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    parent = EXCLUDED.parent,
    action = EXCLUDED.action,
    disable = EXCLUDED.disable;

-- Submenús de Transacciones
INSERT INTO public."Menu" (code, name, parent, action, disable)
VALUES
    ('NOTA_CONTABLE', 'Nota Contable', (SELECT id FROM public."Menu" WHERE code = 'TRANSACCIONES' LIMIT 1), '/dashboard/transactions/accounting-note', false)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    parent = EXCLUDED.parent,
    action = EXCLUDED.action,
    disable = EXCLUDED.disable;
