-- ============================================================
-- DATA QUALITY TESTS - Staging Jardinería
-- Asignatura: Bases de Datos II
-- Estudiante: Francisco Javier Florez Ramirez
-- Fecha: Marzo 2026
-- ============================================================
-- Objetivo: Verificar la calidad de los datos cargados en la
-- base de datos jardineria_staging a través de pruebas que
-- cubren las siguientes dimensiones:
--   1. Completitud   (valores obligatorios no nulos)
--   2. Unicidad      (ausencia de duplicados)
--   3. Integridad    (claves foráneas consistentes)
--   4. Exactitud     (campos calculados correctos)
--   5. Consistencia  (reglas de negocio entre campos)
--   6. Validez       (formatos y dominios correctos)
--   7. Codificación  (detección de caracteres corruptos)
-- ============================================================
-- INSTRUCCIONES DE EJECUCIÓN:
--   Ejecutar sobre la BD: USE jardineria_staging;
--   Resultado esperado: columna "resultado" = 'PASS' en todos.
--   Cualquier 'FAIL' indica un problema de calidad de datos.
-- ============================================================

USE jardineria_staging;

-- ============================================================
-- SECCIÓN 1 — COMPLETITUD
-- Verifica que los campos NOT NULL definidos en el esquema
-- no contengan valores nulos en la práctica.
-- ============================================================

-- DQ-C01: STG_Fecha no debe tener NULLs en campos clave
SELECT
    'DQ-C01' AS test_id,
    'Completitud' AS dimension,
    'STG_Fecha - Campos obligatorios sin NULL' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' fila(s) con NULL en campo obligatorio')
    END AS resultado
FROM jardineria_staging.dbo.STG_Fecha
WHERE ID_fecha IS NULL
   OR fecha_completa IS NULL
   OR dia IS NULL
   OR mes IS NULL
   OR nombre_mes IS NULL
   OR trimestre IS NULL
   OR anio IS NULL
   OR dia_semana IS NULL
   OR es_fin_semana IS NULL;

-- DQ-C02: STG_Cliente - campos mínimos del cliente completos
SELECT
    'DQ-C02' AS test_id,
    'Completitud' AS dimension,
    'STG_Cliente - nombre_cliente y telefono no nulos' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' cliente(s) sin nombre o teléfono')
    END AS resultado
FROM jardineria_staging.dbo.STG_Cliente
WHERE nombre_cliente IS NULL
   OR nombre_cliente = ''
   OR telefono IS NULL
   OR telefono = '';

-- DQ-C03: STG_Cliente - campos de ubicación completos
SELECT
    'DQ-C03' AS test_id,
    'Completitud' AS dimension,
    'STG_Cliente - ciudad no nula' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' cliente(s) sin ciudad')
    END AS resultado
FROM jardineria_staging.dbo.STG_Cliente
WHERE ciudad IS NULL OR ciudad = '';

-- DQ-C04: STG_Cliente - pais nulo (campo opcional pero analíticamente importante)
SELECT
    'DQ-C04' AS test_id,
    'Completitud' AS dimension,
    'STG_Cliente - pais NULL (campo analítico clave)' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' cliente(s) sin país')
    END AS resultado
FROM jardineria_staging.dbo.STG_Cliente
WHERE pais IS NULL OR pais = '';

-- DQ-C05: STG_Producto - campos de precio no nulos
SELECT
    'DQ-C05' AS test_id,
    'Completitud' AS dimension,
    'STG_Producto - precio_venta no nulo' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' producto(s) sin precio de venta')
    END AS resultado
FROM jardineria_staging.dbo.STG_Producto
WHERE precio_venta IS NULL;

-- DQ-C06: STG_Producto - dimensiones vacías (string vacío en lugar de NULL)
SELECT
    'DQ-C06' AS test_id,
    'Completitud' AS dimension,
    'STG_Producto - dimensiones con string vacío en vez de NULL' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' producto(s) con dimensiones = '''' (debería ser NULL)')
    END AS resultado
FROM jardineria_staging.dbo.STG_Producto
WHERE dimensiones = '';

-- DQ-C07: STG_Empleado - campos de identidad completos
SELECT
    'DQ-C07' AS test_id,
    'Completitud' AS dimension,
    'STG_Empleado - nombre_completo y email no vacíos' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' empleado(s) sin nombre o email')
    END AS resultado
FROM jardineria_staging.dbo.STG_Empleado
WHERE nombre_completo IS NULL OR nombre_completo = ''
   OR email IS NULL OR email = '';

-- DQ-C08: STG_Pedido - estado no puede ser nulo
SELECT
    'DQ-C08' AS test_id,
    'Completitud' AS dimension,
    'STG_Pedido - estado no nulo' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' pedido(s) sin estado')
    END AS resultado
FROM jardineria_staging.dbo.STG_Pedido
WHERE estado IS NULL OR estado = '';

-- DQ-C09: STG_Ventas - todas las métricas presentes
SELECT
    'DQ-C09' AS test_id,
    'Completitud' AS dimension,
    'STG_Ventas - cantidad, precio_unidad y subtotal no nulos' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' hecho(s) con métrica nula')
    END AS resultado
FROM jardineria_staging.dbo.STG_Ventas
WHERE cantidad IS NULL
   OR precio_unidad IS NULL
   OR subtotal IS NULL;


-- ============================================================
-- SECCIÓN 2 — UNICIDAD
-- Verifica la ausencia de registros duplicados en las tablas
-- de dimensiones y en la tabla de hechos.
-- ============================================================

-- DQ-U01: STG_Fecha no tiene IDs duplicados
SELECT
    'DQ-U01' AS test_id,
    'Unicidad' AS dimension,
    'STG_Fecha - ID_fecha único (YYYYMMDD)' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' ID_fecha(s) duplicado(s)')
    END AS resultado
FROM (
    SELECT ID_fecha
    FROM jardineria_staging.dbo.STG_Fecha
    GROUP BY ID_fecha
    HAVING COUNT(*) > 1
) dup;

-- DQ-U02: STG_Fecha no tiene la misma fecha_completa más de una vez
SELECT
    'DQ-U02' AS test_id,
    'Unicidad' AS dimension,
    'STG_Fecha - fecha_completa sin duplicados' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' fecha(s) duplicada(s)')
    END AS resultado
FROM (
    SELECT fecha_completa
    FROM jardineria_staging.dbo.STG_Fecha
    GROUP BY fecha_completa
    HAVING COUNT(*) > 1
) dup;

-- DQ-U03: STG_Cliente - ID_cliente_origen sin duplicados
SELECT
    'DQ-U03' AS test_id,
    'Unicidad' AS dimension,
    'STG_Cliente - ID_cliente_origen único (sin duplicados del origen)' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' ID_cliente_origen duplicado(s)')
    END AS resultado
FROM (
    SELECT ID_cliente_origen
    FROM jardineria_staging.dbo.STG_Cliente
    GROUP BY ID_cliente_origen
    HAVING COUNT(*) > 1
) dup;

-- DQ-U04: STG_Producto - ID_producto_origen sin duplicados
SELECT
    'DQ-U04' AS test_id,
    'Unicidad' AS dimension,
    'STG_Producto - ID_producto_origen único' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' ID_producto_origen duplicado(s)')
    END AS resultado
FROM (
    SELECT ID_producto_origen
    FROM jardineria_staging.dbo.STG_Producto
    GROUP BY ID_producto_origen
    HAVING COUNT(*) > 1
) dup;

-- DQ-U05: STG_Empleado - ID_empleado_origen sin duplicados
SELECT
    'DQ-U05' AS test_id,
    'Unicidad' AS dimension,
    'STG_Empleado - ID_empleado_origen único' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' ID_empleado_origen duplicado(s)')
    END AS resultado
FROM (
    SELECT ID_empleado_origen
    FROM jardineria_staging.dbo.STG_Empleado
    GROUP BY ID_empleado_origen
    HAVING COUNT(*) > 1
) dup;

-- DQ-U06: STG_Empleado - email corporativo único por empleado
SELECT
    'DQ-U06' AS test_id,
    'Unicidad' AS dimension,
    'STG_Empleado - email único (sin empleados con mismo correo)' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' email(s) duplicado(s)')
    END AS resultado
FROM (
    SELECT email
    FROM jardineria_staging.dbo.STG_Empleado
    GROUP BY email
    HAVING COUNT(*) > 1
) dup;

-- DQ-U07: STG_Pedido - ID_pedido_origen sin duplicados
SELECT
    'DQ-U07' AS test_id,
    'Unicidad' AS dimension,
    'STG_Pedido - ID_pedido_origen único' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' ID_pedido_origen duplicado(s)')
    END AS resultado
FROM (
    SELECT ID_pedido_origen
    FROM jardineria_staging.dbo.STG_Pedido
    GROUP BY ID_pedido_origen
    HAVING COUNT(*) > 1
) dup;

-- DQ-U08: STG_Ventas - no hay líneas de pedido duplicadas
SELECT
    'DQ-U08' AS test_id,
    'Unicidad' AS dimension,
    'STG_Ventas - no hay (FK_pedido + numero_linea) duplicados' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' combinación(es) pedido+línea duplicada(s)')
    END AS resultado
FROM (
    SELECT FK_pedido, numero_linea
    FROM jardineria_staging.dbo.STG_Ventas
    GROUP BY FK_pedido, numero_linea
    HAVING COUNT(*) > 1
) dup;


-- ============================================================
-- SECCIÓN 3 — INTEGRIDAD REFERENCIAL
-- Verifica que todas las FKs de STG_Ventas apunten a
-- registros válidos en sus respectivas dimensiones.
-- ============================================================

-- DQ-I01: FK_fecha apunta a IDs existentes en STG_Fecha
SELECT
    'DQ-I01' AS test_id,
    'Integridad referencial' AS dimension,
    'STG_Ventas.FK_fecha referencia válida en STG_Fecha' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' hecho(s) con FK_fecha huérfana')
    END AS resultado
FROM jardineria_staging.dbo.STG_Ventas v
WHERE NOT EXISTS (
    SELECT 1 FROM jardineria_staging.dbo.STG_Fecha f
    WHERE f.ID_fecha = v.FK_fecha
);

-- DQ-I02: FK_cliente apunta a IDs existentes en STG_Cliente
SELECT
    'DQ-I02' AS test_id,
    'Integridad referencial' AS dimension,
    'STG_Ventas.FK_cliente referencia válida en STG_Cliente' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' hecho(s) con FK_cliente huérfana')
    END AS resultado
FROM jardineria_staging.dbo.STG_Ventas v
WHERE NOT EXISTS (
    SELECT 1 FROM jardineria_staging.dbo.STG_Cliente c
    WHERE c.ID_dim_cliente = v.FK_cliente
);

-- DQ-I03: FK_producto apunta a IDs existentes en STG_Producto
SELECT
    'DQ-I03' AS test_id,
    'Integridad referencial' AS dimension,
    'STG_Ventas.FK_producto referencia válida en STG_Producto' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' hecho(s) con FK_producto huérfana')
    END AS resultado
FROM jardineria_staging.dbo.STG_Ventas v
WHERE NOT EXISTS (
    SELECT 1 FROM jardineria_staging.dbo.STG_Producto p
    WHERE p.ID_dim_producto = v.FK_producto
);

-- DQ-I04: FK_empleado apunta a IDs existentes en STG_Empleado
SELECT
    'DQ-I04' AS test_id,
    'Integridad referencial' AS dimension,
    'STG_Ventas.FK_empleado referencia válida en STG_Empleado' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' hecho(s) con FK_empleado huérfana')
    END AS resultado
FROM jardineria_staging.dbo.STG_Ventas v
WHERE NOT EXISTS (
    SELECT 1 FROM jardineria_staging.dbo.STG_Empleado e
    WHERE e.ID_dim_empleado = v.FK_empleado
);

-- DQ-I05: FK_pedido apunta a IDs existentes en STG_Pedido
SELECT
    'DQ-I05' AS test_id,
    'Integridad referencial' AS dimension,
    'STG_Ventas.FK_pedido referencia válida en STG_Pedido' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' hecho(s) con FK_pedido huérfana')
    END AS resultado
FROM jardineria_staging.dbo.STG_Ventas v
WHERE NOT EXISTS (
    SELECT 1 FROM jardineria_staging.dbo.STG_Pedido pd
    WHERE pd.ID_dim_pedido = v.FK_pedido
);

-- DQ-I06: Todo pedido en STG_Ventas debe estar marcado como 'Entregado'
--         (el ETL filtra con WHERE p.estado = 'Entregado')
SELECT
    'DQ-I06' AS test_id,
    'Integridad referencial' AS dimension,
    'STG_Ventas - todos los pedidos vinculados están en estado Entregado' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' hecho(s) ligado(s) a pedido no entregado')
    END AS resultado
FROM jardineria_staging.dbo.STG_Ventas v
INNER JOIN jardineria_staging.dbo.STG_Pedido pd
        ON v.FK_pedido = pd.ID_dim_pedido
WHERE pd.estado <> 'Entregado';


-- ============================================================
-- SECCIÓN 4 — EXACTITUD (CAMPOS CALCULADOS)
-- Verifica que los campos derivados durante el ETL sean
-- matemáticamente correctos.
-- ============================================================

-- DQ-E01: subtotal = cantidad * precio_unidad en STG_Ventas
SELECT
    'DQ-E01' AS test_id,
    'Exactitud' AS dimension,
    'STG_Ventas - subtotal == cantidad * precio_unidad' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' hecho(s) con subtotal incorrecto')
    END AS resultado
FROM jardineria_staging.dbo.STG_Ventas
WHERE ABS(subtotal - (cantidad * precio_unidad)) > 0.01;

-- DQ-E02: dias_retraso = DATEDIFF(fecha_entrega, fecha_esperada) en STG_Pedido
SELECT
    'DQ-E02' AS test_id,
    'Exactitud' AS dimension,
    'STG_Pedido - dias_retraso == DATEDIFF(fecha_esperada, fecha_entrega)' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' pedido(s) con dias_retraso incorrecto')
    END AS resultado
FROM jardineria_staging.dbo.STG_Pedido
WHERE fecha_entrega IS NOT NULL
  AND dias_retraso IS NOT NULL
  AND dias_retraso <> DATEDIFF(DAY, fecha_esperada, fecha_entrega);

-- DQ-E03: ID_fecha en STG_Fecha coincide con el formato YYYYMMDD de fecha_completa
SELECT
    'DQ-E03' AS test_id,
    'Exactitud' AS dimension,
    'STG_Fecha - ID_fecha == CAST(FORMAT(fecha_completa,yyyyMMdd) AS INT)' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' fila(s) con ID_fecha inconsistente')
    END AS resultado
FROM jardineria_staging.dbo.STG_Fecha
WHERE ID_fecha <> CAST(FORMAT(fecha_completa, 'yyyyMMdd') AS INT);

-- DQ-E04: Atributos derivados de fecha_completa son correctos (dia, mes, anio, trimestre)
SELECT
    'DQ-E04' AS test_id,
    'Exactitud' AS dimension,
    'STG_Fecha - dia/mes/anio/trimestre consistentes con fecha_completa' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' fila(s) con atributo de fecha erróneo')
    END AS resultado
FROM jardineria_staging.dbo.STG_Fecha
WHERE dia       <> DAY(fecha_completa)
   OR mes       <> MONTH(fecha_completa)
   OR anio      <> YEAR(fecha_completa)
   OR trimestre <> DATEPART(QUARTER, fecha_completa);

-- DQ-E05: Flag es_fin_semana correcto (1 = sábado/domingo, 0 = resto)
SELECT
    'DQ-E05' AS test_id,
    'Exactitud' AS dimension,
    'STG_Fecha - es_fin_semana correcto para sábado y domingo' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' fila(s) con es_fin_semana incorrecto')
    END AS resultado
FROM jardineria_staging.dbo.STG_Fecha
WHERE es_fin_semana <> CASE
    WHEN DATEPART(WEEKDAY, fecha_completa) IN (1, 7) THEN 1
    ELSE 0
END;


-- ============================================================
-- SECCIÓN 5 — CONSISTENCIA (REGLAS DE NEGOCIO)
-- Verifica coherencia entre campos relacionados dentro de
-- una misma tabla o entre tablas del modelo.
-- ============================================================

-- DQ-N01: Pedidos 'Entregado' SIN fecha de entrega registrada
--         (estado inconsistente con ausencia de fecha)
SELECT
    'DQ-N01' AS test_id,
    'Consistencia' AS dimension,
    'STG_Pedido - Entregado pero fecha_entrega NULL' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' pedido(s) marcado(s) Entregado sin fecha de entrega')
    END AS resultado
FROM jardineria_staging.dbo.STG_Pedido
WHERE estado = 'Entregado'
  AND fecha_entrega IS NULL;

-- DQ-N02: Pedidos 'Rechazado' CON fecha de entrega (lógicamente inconsistente)
SELECT
    'DQ-N02' AS test_id,
    'Consistencia' AS dimension,
    'STG_Pedido - Rechazado pero con fecha_entrega registrada' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' pedido(s) Rechazado con fecha_entrega no nula')
    END AS resultado
FROM jardineria_staging.dbo.STG_Pedido
WHERE estado = 'Rechazado'
  AND fecha_entrega IS NOT NULL;

-- DQ-N03: Pedidos 'Pendiente' CON fecha de entrega
--         (un pedido pendiente no debería tener fecha de entrega)
SELECT
    'DQ-N03' AS test_id,
    'Consistencia' AS dimension,
    'STG_Pedido - Pendiente pero con fecha_entrega registrada' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' pedido(s) Pendiente con fecha_entrega no nula')
    END AS resultado
FROM jardineria_staging.dbo.STG_Pedido
WHERE estado = 'Pendiente'
  AND fecha_entrega IS NOT NULL;

-- DQ-N04: dias_retraso debe ser NULL cuando fecha_entrega es NULL
SELECT
    'DQ-N04' AS test_id,
    'Consistencia' AS dimension,
    'STG_Pedido - dias_retraso NULL cuando fecha_entrega es NULL' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' pedido(s) con dias_retraso <> NULL sin fecha_entrega')
    END AS resultado
FROM jardineria_staging.dbo.STG_Pedido
WHERE fecha_entrega IS NULL
  AND dias_retraso IS NOT NULL;

-- DQ-N05: dias_retraso NO debe ser NULL cuando fecha_entrega está presente
SELECT
    'DQ-N05' AS test_id,
    'Consistencia' AS dimension,
    'STG_Pedido - dias_retraso calculado cuando fecha_entrega no es NULL' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' pedido(s) con fecha_entrega pero sin dias_retraso')
    END AS resultado
FROM jardineria_staging.dbo.STG_Pedido
WHERE fecha_entrega IS NOT NULL
  AND dias_retraso IS NULL;

-- DQ-N06: fecha_entrega no debe ser anterior a fecha_pedido en STG_Fecha
--         (cruza STG_Ventas → STG_Pedido → STG_Fecha para validar orden temporal)
SELECT
    'DQ-N06' AS test_id,
    'Consistencia' AS dimension,
    'STG_Pedido - fecha_entrega no anterior a fecha_pedido (via STG_Ventas)' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' pedido(s) entregado(s) antes de ser pedido(s)')
    END AS resultado
FROM jardineria_staging.dbo.STG_Ventas v
INNER JOIN jardineria_staging.dbo.STG_Fecha f
        ON v.FK_fecha = f.ID_fecha
INNER JOIN jardineria_staging.dbo.STG_Pedido pd
        ON v.FK_pedido = pd.ID_dim_pedido
WHERE pd.fecha_entrega IS NOT NULL
  AND pd.fecha_entrega < f.fecha_completa;

-- DQ-N07: precio_proveedor = 0 en STG_Producto
--         (un precio de costo cero es sospechoso; debería ser NULL o > 0)
SELECT
    'DQ-N07' AS test_id,
    'Consistencia' AS dimension,
    'STG_Producto - precio_proveedor == 0 (debería ser NULL o positivo)' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' producto(s) con precio de proveedor = 0.00')
    END AS resultado
FROM jardineria_staging.dbo.STG_Producto
WHERE precio_proveedor = 0;

-- DQ-N08: precio_venta debe ser >= precio_proveedor (margen no negativo)
SELECT
    'DQ-N08' AS test_id,
    'Consistencia' AS dimension,
    'STG_Producto - precio_venta >= precio_proveedor (margen >= 0)' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' producto(s) con precio_venta < precio_proveedor')
    END AS resultado
FROM jardineria_staging.dbo.STG_Producto
WHERE precio_proveedor IS NOT NULL
  AND precio_proveedor > 0
  AND precio_venta < precio_proveedor;

-- DQ-N09: El representante de ventas (FK_empleado) debería tener puesto
--         'Representante Ventas' o similiar, no ser Director General
SELECT
    'DQ-N09' AS test_id,
    'Consistencia' AS dimension,
    'STG_Ventas - FK_empleado no apunta a Director General' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' hecho(s) asignado(s) a empleado no comercial (Director)')
    END AS resultado
FROM jardineria_staging.dbo.STG_Ventas v
INNER JOIN jardineria_staging.dbo.STG_Empleado e
        ON v.FK_empleado = e.ID_dim_empleado
WHERE e.puesto = 'Director General';


-- ============================================================
-- SECCIÓN 6 — VALIDEZ (FORMATOS Y DOMINIOS)
-- Verifica que los valores caigan dentro de rangos o
-- conjuntos de valores aceptables.
-- ============================================================

-- DQ-V01: estado de STG_Pedido solo acepta valores del dominio definido
SELECT
    'DQ-V01' AS test_id,
    'Validez' AS dimension,
    'STG_Pedido - estado dentro del dominio {Entregado, Pendiente, Rechazado}' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' pedido(s) con estado fuera del dominio')
    END AS resultado
FROM jardineria_staging.dbo.STG_Pedido
WHERE estado NOT IN ('Entregado', 'Pendiente', 'Rechazado', 'En Proceso');

-- DQ-V02: mes en STG_Fecha debe estar entre 1 y 12
SELECT
    'DQ-V02' AS test_id,
    'Validez' AS dimension,
    'STG_Fecha - mes entre 1 y 12' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' fila(s) con mes fuera de rango [1-12]')
    END AS resultado
FROM jardineria_staging.dbo.STG_Fecha
WHERE mes < 1 OR mes > 12;

-- DQ-V03: trimestre en STG_Fecha debe estar entre 1 y 4
SELECT
    'DQ-V03' AS test_id,
    'Validez' AS dimension,
    'STG_Fecha - trimestre entre 1 y 4' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' fila(s) con trimestre fuera de rango [1-4]')
    END AS resultado
FROM jardineria_staging.dbo.STG_Fecha
WHERE trimestre < 1 OR trimestre > 4;

-- DQ-V04: cantidad en STG_Ventas debe ser positiva (> 0)
SELECT
    'DQ-V04' AS test_id,
    'Validez' AS dimension,
    'STG_Ventas - cantidad > 0' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' hecho(s) con cantidad <= 0')
    END AS resultado
FROM jardineria_staging.dbo.STG_Ventas
WHERE cantidad <= 0;

-- DQ-V05: precio_unidad en STG_Ventas debe ser positivo
SELECT
    'DQ-V05' AS test_id,
    'Validez' AS dimension,
    'STG_Ventas - precio_unidad > 0' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' hecho(s) con precio_unidad <= 0')
    END AS resultado
FROM jardineria_staging.dbo.STG_Ventas
WHERE precio_unidad <= 0;

-- DQ-V06: precio_venta en STG_Producto debe ser positivo
SELECT
    'DQ-V06' AS test_id,
    'Validez' AS dimension,
    'STG_Producto - precio_venta > 0' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' producto(s) con precio_venta <= 0')
    END AS resultado
FROM jardineria_staging.dbo.STG_Producto
WHERE precio_venta <= 0;

-- DQ-V07: cantidad_en_stock en STG_Producto no debe ser negativa
SELECT
    'DQ-V07' AS test_id,
    'Validez' AS dimension,
    'STG_Producto - cantidad_en_stock >= 0' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' producto(s) con stock negativo')
    END AS resultado
FROM jardineria_staging.dbo.STG_Producto
WHERE cantidad_en_stock < 0;

-- DQ-V08: Email de empleados con formato básico válido (contiene @)
SELECT
    'DQ-V08' AS test_id,
    'Validez' AS dimension,
    'STG_Empleado - email contiene @' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' empleado(s) con email sin @')
    END AS resultado
FROM jardineria_staging.dbo.STG_Empleado
WHERE email NOT LIKE '%@%.%';

-- DQ-V09: Teléfonos de cliente con longitud razonable (6-15 caracteres)
SELECT
    'DQ-V09' AS test_id,
    'Validez' AS dimension,
    'STG_Cliente - teléfono con longitud entre 6 y 15 caracteres' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' cliente(s) con teléfono de longitud inválida: ',
             STRING_AGG(CAST(ID_dim_cliente AS VARCHAR) + '(' + telefono + ')', ', '))
    END AS resultado
FROM jardineria_staging.dbo.STG_Cliente
WHERE LEN(TRIM(telefono)) < 6 OR LEN(TRIM(telefono)) > 15;

-- DQ-V10: limite_credito en STG_Cliente debe ser >= 0
SELECT
    'DQ-V10' AS test_id,
    'Validez' AS dimension,
    'STG_Cliente - limite_credito >= 0' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' cliente(s) con límite de crédito negativo')
    END AS resultado
FROM jardineria_staging.dbo.STG_Cliente
WHERE limite_credito < 0;

-- DQ-V11: anio en STG_Fecha debe ser realista (entre 2000 y 2030)
SELECT
    'DQ-V11' AS test_id,
    'Validez' AS dimension,
    'STG_Fecha - año en rango realista [2000-2030]' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' fecha(s) con año fuera del rango esperado')
    END AS resultado
FROM jardineria_staging.dbo.STG_Fecha
WHERE anio < 2000 OR anio > 2030;


-- ============================================================
-- SECCIÓN 7 — CODIFICACIÓN DE CARACTERES
-- Detecta valores que contienen secuencias de bytes típicas
-- de una exportación UTF-8 interpretada como Latin-1/CP1252,
-- lo que produce caracteres corruptos como ├â, ├⌐, ├░, etc.
-- ============================================================

-- DQ-X01: STG_Fecha.dia_semana sin caracteres corruptos UTF-8/Latin-1
SELECT
    'DQ-X01' AS test_id,
    'Codificación' AS dimension,
    'STG_Fecha - dia_semana sin caracteres corruptos (ej: Mi├⌐rcoles)' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*),
                    ' fila(s) con dia_semana corrupto. Ejemplos: ',
                    STRING_AGG(DISTINCT dia_semana, ', '))
    END AS resultado
FROM jardineria_staging.dbo.STG_Fecha
WHERE dia_semana LIKE '%├%'
   OR dia_semana LIKE '%â%'
   OR dia_semana LIKE '%┬%';

-- DQ-X02: STG_Fecha.nombre_mes sin caracteres corruptos
SELECT
    'DQ-X02' AS test_id,
    'Codificación' AS dimension,
    'STG_Fecha - nombre_mes sin caracteres corruptos' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' fila(s) con nombre_mes corrupto')
    END AS resultado
FROM jardineria_staging.dbo.STG_Fecha
WHERE nombre_mes LIKE '%├%'
   OR nombre_mes LIKE '%â%'
   OR nombre_mes LIKE '%┬%';

-- DQ-X03: STG_Cliente.nombre_cliente sin caracteres corruptos
SELECT
    'DQ-X03' AS test_id,
    'Codificación' AS dimension,
    'STG_Cliente - nombre_cliente sin caracteres corruptos' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' cliente(s) con nombre corrupto')
    END AS resultado
FROM jardineria_staging.dbo.STG_Cliente
WHERE nombre_cliente LIKE '%├%'
   OR nombre_cliente LIKE '%â%'
   OR nombre_cliente LIKE '%┬%'
   OR nombre_cliente LIKE '%┼%';

-- DQ-X04: STG_Producto.nombre_producto sin caracteres corruptos
SELECT
    'DQ-X04' AS test_id,
    'Codificación' AS dimension,
    'STG_Producto - nombre_producto sin caracteres corruptos' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' producto(s) con nombre corrupto')
    END AS resultado
FROM jardineria_staging.dbo.STG_Producto
WHERE nombre_producto LIKE '%├%'
   OR nombre_producto LIKE '%â%'
   OR nombre_producto LIKE '%┬%';

-- DQ-X05: STG_Pedido.comentarios sin caracteres corruptos
SELECT
    'DQ-X05' AS test_id,
    'Codificación' AS dimension,
    'STG_Pedido - comentarios sin caracteres corruptos' AS descripcion,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE CONCAT('FAIL - ', COUNT(*), ' pedido(s) con comentario corrupto')
    END AS resultado
FROM jardineria_staging.dbo.STG_Pedido
WHERE CAST(comentarios AS NVARCHAR(MAX)) LIKE '%├%'
   OR CAST(comentarios AS NVARCHAR(MAX)) LIKE '%â%'
   OR CAST(comentarios AS NVARCHAR(MAX)) LIKE '%┬%';

