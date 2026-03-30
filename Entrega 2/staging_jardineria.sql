-- ============================================================
-- SCRIPT: Creación de la Base de Datos Staging - Jardinería
-- Asignatura: Bases de Datos II
-- Estudiante: Francisco Javier Florez Ramirez
-- Fecha: Marzo 2026
-- ============================================================
-- Este script crea la base de datos Staging y pobla sus tablas
-- con datos extraídos, limpios y transformados desde la BD
-- transaccional Jardinería, listos para alimentar el modelo
-- estrella definido en la Evidencia de Aprendizaje 1.
-- ============================================================

-- ============================================================
-- SECCIÓN 1: CREACIÓN DE LA BASE DE DATOS STAGING
-- ============================================================

DROP DATABASE IF EXISTS jardineria_staging;
CREATE DATABASE jardineria_staging;
USE jardineria_staging;

-- ------------------------------------------------------------
-- STG_Fecha
-- Dimensión de tiempo generada desde las fechas de pedido.
-- Se enriquece con atributos analíticos: mes, trimestre, año,
-- nombre del mes y flag de fin de semana.
-- Fuente: jardineria.pedido (fecha_pedido)
-- ------------------------------------------------------------
CREATE TABLE STG_Fecha (
    ID_fecha        INT           NOT NULL,   -- Formato YYYYMMDD (clave natural)
    fecha_completa  DATE          NOT NULL,
    dia             SMALLINT      NOT NULL,
    mes             SMALLINT      NOT NULL,
    nombre_mes      VARCHAR(20)   NOT NULL,
    trimestre       SMALLINT      NOT NULL,
    anio            SMALLINT      NOT NULL,
    dia_semana      VARCHAR(15)   NOT NULL,
    es_fin_semana   BIT           NOT NULL DEFAULT 0,
    PRIMARY KEY (ID_fecha)
);

-- ------------------------------------------------------------
-- STG_Cliente
-- Contiene los atributos descriptivos de cada cliente.
-- Se excluye: fax (no aporta valor analítico), 
-- linea_direccion1/2 (nivel de detalle excesivo para análisis).
-- Fuente: jardineria.cliente
-- ------------------------------------------------------------
CREATE TABLE STG_Cliente (
    ID_dim_cliente      INT              NOT NULL IDENTITY(1,1),
    ID_cliente_origen   INT              NOT NULL,
    nombre_cliente      VARCHAR(50)      NOT NULL,
    nombre_contacto     VARCHAR(30)      NULL,
    apellido_contacto   VARCHAR(30)      NULL,
    telefono            VARCHAR(15)      NOT NULL,
    ciudad              VARCHAR(50)      NOT NULL,
    region              VARCHAR(50)      NULL,
    pais                VARCHAR(50)      NULL,
    codigo_postal       VARCHAR(10)      NULL,
    limite_credito      NUMERIC(15,2)    NULL,
    PRIMARY KEY (ID_dim_cliente)
);

-- ------------------------------------------------------------
-- STG_Producto
-- Desnormaliza la relación producto-categoría.
-- El nombre de la categoría se integra directamente para
-- eliminar JOINs en las consultas analíticas.
-- Se excluye: descripcion (texto largo sin uso analítico).
-- Fuente: jardineria.producto JOIN jardineria.Categoria_producto
-- ------------------------------------------------------------
CREATE TABLE STG_Producto (
    ID_dim_producto     INT              NOT NULL IDENTITY(1,1),
    ID_producto_origen  VARCHAR(15)      NOT NULL,
    nombre_producto     VARCHAR(70)      NOT NULL,
    categoria           VARCHAR(50)      NOT NULL,
    proveedor           VARCHAR(50)      NULL,
    dimensiones         VARCHAR(25)      NULL,
    precio_venta        NUMERIC(15,2)    NOT NULL,
    precio_proveedor    NUMERIC(15,2)    NULL,
    cantidad_en_stock   SMALLINT         NOT NULL,
    PRIMARY KEY (ID_dim_producto)
);

-- ------------------------------------------------------------
-- STG_Empleado
-- Desnormaliza la jerarquía empleado-oficina.
-- El nombre del jefe se resuelve mediante self-join.
-- Los datos de la oficina se integran directamente.
-- Se excluye: linea_direccion1/2, codigo_postal de oficina
--             (no útiles para análisis de ventas).
-- Fuente: jardineria.empleado JOIN jardineria.oficina
--         + self-join para nombre del jefe
-- ------------------------------------------------------------
CREATE TABLE STG_Empleado (
    ID_dim_empleado     INT              NOT NULL IDENTITY(1,1),
    ID_empleado_origen  INT              NOT NULL,
    nombre_completo     VARCHAR(120)     NOT NULL,
    puesto              VARCHAR(50)      NULL,
    email               VARCHAR(100)     NOT NULL,
    extension           VARCHAR(10)      NOT NULL,
    nombre_jefe         VARCHAR(120)     NULL,
    oficina_descripcion VARCHAR(10)      NULL,
    oficina_ciudad      VARCHAR(30)      NULL,
    oficina_pais        VARCHAR(50)      NULL,
    oficina_region      VARCHAR(50)      NULL,
    PRIMARY KEY (ID_dim_empleado)
);

-- ------------------------------------------------------------
-- STG_Pedido
-- Contiene el estado y datos logísticos del pedido.
-- Se calcula dias_retraso como campo derivado:
--   - Positivo: pedido llegó tarde
--   - Negativo: pedido llegó antes de lo esperado
--   - NULL: pedido sin fecha de entrega registrada
-- Fuente: jardineria.pedido
-- ------------------------------------------------------------
CREATE TABLE STG_Pedido (
    ID_dim_pedido       INT              NOT NULL IDENTITY(1,1),
    ID_pedido_origen    INT              NOT NULL,
    fecha_esperada      DATE             NOT NULL,
    fecha_entrega       DATE             NULL,
    estado              VARCHAR(15)      NOT NULL,
    dias_retraso        INT              NULL,   -- calculado: fecha_entrega - fecha_esperada
    comentarios         TEXT             NULL,
    PRIMARY KEY (ID_dim_pedido)
);

-- ------------------------------------------------------------
-- STG_Ventas (Tabla de Hechos)
-- Granularidad: 1 fila = 1 línea de detalle de pedido.
-- Métricas aditivas: cantidad, precio_unidad, subtotal.
-- numero_linea: atributo degenerado del sistema origen.
-- Fuente: jardineria.detalle_pedido + jardineria.pedido
--         (para obtener FK_fecha, FK_cliente, FK_empleado)
-- ------------------------------------------------------------
CREATE TABLE STG_Ventas (
    ID_hecho        INT              NOT NULL IDENTITY(1,1),
    FK_fecha        INT              NOT NULL,
    FK_cliente      INT              NOT NULL,
    FK_producto     INT              NOT NULL,
    FK_empleado     INT              NOT NULL,
    FK_pedido       INT              NOT NULL,
    cantidad        INT              NOT NULL,
    precio_unidad   NUMERIC(15,2)    NOT NULL,
    subtotal        NUMERIC(15,2)    NOT NULL,   -- calculado: cantidad * precio_unidad
    numero_linea    SMALLINT         NOT NULL,
    PRIMARY KEY (ID_hecho),
    FOREIGN KEY (FK_fecha)    REFERENCES STG_Fecha(ID_fecha),
    FOREIGN KEY (FK_cliente)  REFERENCES STG_Cliente(ID_dim_cliente),
    FOREIGN KEY (FK_producto) REFERENCES STG_Producto(ID_dim_producto),
    FOREIGN KEY (FK_empleado) REFERENCES STG_Empleado(ID_dim_empleado),
    FOREIGN KEY (FK_pedido)   REFERENCES STG_Pedido(ID_dim_pedido)
);


-- ============================================================
-- SECCIÓN 2: CONSULTAS ETL - POBLADO DE LA STAGING
-- ============================================================

-- ------------------------------------------------------------
-- ETL 1: Poblar STG_Fecha
-- Se genera una fila por cada fecha única de pedido presente
-- en la tabla jardineria.pedido.
-- Se enriquece con atributos temporales calculados.
-- ------------------------------------------------------------
INSERT INTO jardineria_staging.STG_Fecha
    (ID_fecha, fecha_completa, dia, mes, nombre_mes,
     trimestre, anio, dia_semana, es_fin_semana)
SELECT DISTINCT
    -- Clave natural en formato YYYYMMDD
    CAST(FORMAT(p.fecha_pedido, 'yyyyMMdd') AS INT)     AS ID_fecha,
    p.fecha_pedido                                       AS fecha_completa,
    DAY(p.fecha_pedido)                                  AS dia,
    MONTH(p.fecha_pedido)                                AS mes,
    DATENAME(MONTH, p.fecha_pedido)                      AS nombre_mes,
    DATEPART(QUARTER, p.fecha_pedido)                    AS trimestre,
    YEAR(p.fecha_pedido)                                 AS anio,
    DATENAME(WEEKDAY, p.fecha_pedido)                    AS dia_semana,
    CASE WHEN DATEPART(WEEKDAY, p.fecha_pedido) IN (1,7) THEN 1 ELSE 0 END AS es_fin_semana
FROM jardineria.dbo.pedido p
WHERE p.fecha_pedido IS NOT NULL
ORDER BY p.fecha_pedido;

-- ------------------------------------------------------------
-- ETL 2: Poblar STG_Cliente
-- Se excluyen clientes duplicados (misma combinación de
-- nombre_cliente + telefono) que existen en la BD fuente.
-- Se usa ROW_NUMBER() para mantener solo el primer registro.
-- Se excluyen columnas: fax, linea_direccion1, linea_direccion2
--   (irrelevantes para análisis multidimensional).
-- ------------------------------------------------------------
INSERT INTO jardineria_staging.STG_Cliente
    (ID_cliente_origen, nombre_cliente, nombre_contacto,
     apellido_contacto, telefono, ciudad, region,
     pais, codigo_postal, limite_credito)
SELECT
    c.ID_cliente,
    c.nombre_cliente,
    c.nombre_contacto,
    c.apellido_contacto,
    c.telefono,
    c.ciudad,
    c.region,
    c.pais,
    c.codigo_postal,
    c.limite_credito
FROM jardineria.dbo.cliente c
INNER JOIN (
    -- Seleccionar solo el primer registro cuando hay duplicados
    SELECT ID_cliente,
           ROW_NUMBER() OVER (
               PARTITION BY nombre_cliente, telefono
               ORDER BY ID_cliente ASC
           ) AS rn
    FROM jardineria.dbo.cliente
) dedup ON c.ID_cliente = dedup.ID_cliente AND dedup.rn = 1
ORDER BY c.ID_cliente;

-- ------------------------------------------------------------
-- ETL 3: Poblar STG_Producto
-- Se desnormaliza la categoría desde Categoria_producto.
-- Se excluye el campo 'descripcion' (texto libre sin valor
-- analítico directo).
-- Nota: Los IDs de categoría en el script fuente son textos
--   ('Herramientas', 'Frutales', etc.) — se normaliza mediante
--   JOIN con Categoria_producto sobre Desc_Categoria.
-- ------------------------------------------------------------
INSERT INTO jardineria_staging.STG_Producto
    (ID_producto_origen, nombre_producto, categoria,
     proveedor, dimensiones, precio_venta,
     precio_proveedor, cantidad_en_stock)
SELECT
    p.ID_producto,
    p.nombre,
    -- Desnormalizar nombre de categoría
    COALESCE(cp.Desc_Categoria, CAST(p.Categoria AS VARCHAR(50))) AS categoria,
    p.proveedor,
    p.dimensiones,
    p.precio_venta,
    p.precio_proveedor,
    p.cantidad_en_stock
FROM jardineria.dbo.producto p
LEFT JOIN jardineria.dbo.Categoria_producto cp
       ON p.Categoria = cp.Id_Categoria
ORDER BY p.ID_producto;

-- ------------------------------------------------------------
-- ETL 4: Poblar STG_Empleado
-- Se desnormaliza la oficina mediante JOIN con oficina.
-- Se resuelve la jerarquía del jefe mediante self-join.
-- El nombre completo se construye concatenando nombre + apellidos.
-- Se excluye: linea_direccion1/2 y codigo_postal de oficina.
-- ------------------------------------------------------------
INSERT INTO jardineria_staging.STG_Empleado
    (ID_empleado_origen, nombre_completo, puesto,
     email, extension, nombre_jefe,
     oficina_descripcion, oficina_ciudad,
     oficina_pais, oficina_region)
SELECT
    e.ID_empleado,
    -- Nombre completo concatenado (manejo de apellido2 opcional)
    TRIM(e.nombre + ' ' + e.apellido1 +
         CASE WHEN e.apellido2 IS NOT NULL AND e.apellido2 <> ''
              THEN ' ' + e.apellido2 ELSE '' END)     AS nombre_completo,
    e.puesto,
    e.email,
    e.extension,
    -- Nombre del jefe mediante self-join
    CASE WHEN jefe.ID_empleado IS NOT NULL
         THEN TRIM(jefe.nombre + ' ' + jefe.apellido1 +
                   CASE WHEN jefe.apellido2 IS NOT NULL AND jefe.apellido2 <> ''
                        THEN ' ' + jefe.apellido2 ELSE '' END)
         ELSE NULL END                                AS nombre_jefe,
    o.Descripcion                                     AS oficina_descripcion,
    o.ciudad                                          AS oficina_ciudad,
    o.pais                                            AS oficina_pais,
    o.region                                          AS oficina_region
FROM jardineria.dbo.empleado e
INNER JOIN jardineria.dbo.oficina o
        ON e.ID_oficina = o.ID_oficina
LEFT JOIN jardineria.dbo.empleado jefe
       ON e.ID_jefe = jefe.ID_empleado
ORDER BY e.ID_empleado;

-- ------------------------------------------------------------
-- ETL 5: Poblar STG_Pedido
-- Se calcula dias_retraso como diferencia entre fecha real y
-- fecha esperada. Valores positivos indican retraso.
-- Se preservan comentarios para análisis cualitativo.
-- Se excluye: fecha_pedido (ya está en STG_Fecha), ID_cliente
--   (ya disponible a través de la tabla de hechos).
-- ------------------------------------------------------------
INSERT INTO jardineria_staging.STG_Pedido
    (ID_pedido_origen, fecha_esperada, fecha_entrega,
     estado, dias_retraso, comentarios)
SELECT
    p.ID_pedido,
    p.fecha_esperada,
    p.fecha_entrega,
    p.estado,
    -- Campo calculado: positivo = retraso, negativo = adelanto
    CASE WHEN p.fecha_entrega IS NOT NULL
         THEN DATEDIFF(DAY, p.fecha_esperada, p.fecha_entrega)
         ELSE NULL END                                AS dias_retraso,
    p.comentarios
FROM jardineria.dbo.pedido p
ORDER BY p.ID_pedido;

-- ------------------------------------------------------------
-- ETL 6: Poblar STG_Ventas (Tabla de Hechos)
-- Se integran todas las claves foráneas mediante JOINs sobre
-- las tablas de dimensiones staging ya pobladas.
-- El subtotal se calcula: cantidad * precio_unidad.
-- Solo se incluyen pedidos con estado 'Entregado' para 
-- garantizar que se contabilicen ventas efectivas.
-- ------------------------------------------------------------
INSERT INTO jardineria_staging.STG_Ventas
    (FK_fecha, FK_cliente, FK_producto,
     FK_empleado, FK_pedido,
     cantidad, precio_unidad, subtotal, numero_linea)
SELECT
    -- FK hacia STG_Fecha (formato YYYYMMDD)
    CAST(FORMAT(p.fecha_pedido, 'yyyyMMdd') AS INT)   AS FK_fecha,

    -- FK hacia STG_Cliente (clave subrogante de staging)
    sc.ID_dim_cliente                                  AS FK_cliente,

    -- FK hacia STG_Producto (clave subrogante de staging)
    sp.ID_dim_producto                                 AS FK_producto,

    -- FK hacia STG_Empleado (representante de ventas del cliente)
    se.ID_dim_empleado                                 AS FK_empleado,

    -- FK hacia STG_Pedido (clave subrogante de staging)
    spd.ID_dim_pedido                                  AS FK_pedido,

    -- Métricas
    dp.cantidad,
    dp.precio_unidad,
    dp.cantidad * dp.precio_unidad                     AS subtotal,
    dp.numero_linea

FROM jardineria.dbo.detalle_pedido dp

-- JOIN con pedido para obtener fecha, cliente y empleado rep ventas
INNER JOIN jardineria.dbo.pedido p
        ON dp.ID_pedido = p.ID_pedido

-- JOIN con STG_Fecha
INNER JOIN jardineria_staging.STG_Fecha f
        ON CAST(FORMAT(p.fecha_pedido, 'yyyyMMdd') AS INT) = f.ID_fecha

-- JOIN con STG_Cliente (usando ID origen del cliente)
INNER JOIN jardineria_staging.STG_Cliente sc
        ON p.ID_cliente = sc.ID_cliente_origen

-- JOIN con STG_Producto (usando ID origen del producto)
INNER JOIN jardineria_staging.STG_Producto sp
        ON dp.ID_producto = sp.ID_producto_origen

-- JOIN con STG_Empleado (representante de ventas asignado al cliente)
INNER JOIN jardineria.dbo.cliente c
        ON p.ID_cliente = c.ID_cliente
INNER JOIN jardineria_staging.STG_Empleado se
        ON c.ID_empleado_rep_ventas = se.ID_empleado_origen

-- JOIN con STG_Pedido (usando ID origen del pedido)
INNER JOIN jardineria_staging.STG_Pedido spd
        ON p.ID_pedido = spd.ID_pedido_origen

-- Solo pedidos efectivamente entregados
WHERE p.estado = 'Entregado'

ORDER BY p.fecha_pedido, dp.ID_pedido, dp.numero_linea;


-- ============================================================
-- SECCIÓN 3: CONSULTAS DE VALIDACIÓN
-- ============================================================

-- Validar conteo de registros por tabla
SELECT 'STG_Fecha'    AS tabla, COUNT(*) AS registros FROM jardineria_staging.STG_Fecha
UNION ALL
SELECT 'STG_Cliente'  AS tabla, COUNT(*) AS registros FROM jardineria_staging.STG_Cliente
UNION ALL
SELECT 'STG_Producto' AS tabla, COUNT(*) AS registros FROM jardineria_staging.STG_Producto
UNION ALL
SELECT 'STG_Empleado' AS tabla, COUNT(*) AS registros FROM jardineria_staging.STG_Empleado
UNION ALL
SELECT 'STG_Pedido'   AS tabla, COUNT(*) AS registros FROM jardineria_staging.STG_Pedido
UNION ALL
SELECT 'STG_Ventas'   AS tabla, COUNT(*) AS registros FROM jardineria_staging.STG_Ventas;

-- Verificar integridad: no deben existir FKs huérfanas en STG_Ventas
SELECT COUNT(*) AS ventas_sin_fecha    FROM jardineria_staging.STG_Ventas v
WHERE NOT EXISTS (SELECT 1 FROM jardineria_staging.STG_Fecha f WHERE f.ID_fecha = v.FK_fecha);

SELECT COUNT(*) AS ventas_sin_cliente  FROM jardineria_staging.STG_Ventas v
WHERE NOT EXISTS (SELECT 1 FROM jardineria_staging.STG_Cliente c WHERE c.ID_dim_cliente = v.FK_cliente);

SELECT COUNT(*) AS ventas_sin_producto FROM jardineria_staging.STG_Ventas v
WHERE NOT EXISTS (SELECT 1 FROM jardineria_staging.STG_Producto p WHERE p.ID_dim_producto = v.FK_producto);

-- Verificar subtotales calculados correctamente
SELECT TOP 10
    ID_hecho,
    cantidad,
    precio_unidad,
    subtotal,
    cantidad * precio_unidad AS subtotal_calculado,
    CASE WHEN subtotal = cantidad * precio_unidad THEN 'OK' ELSE 'ERROR' END AS validacion
FROM jardineria_staging.STG_Ventas;

-- Verificar desnormalización de categorías en STG_Producto
SELECT categoria, COUNT(*) AS productos
FROM jardineria_staging.STG_Producto
GROUP BY categoria
ORDER BY productos DESC;

-- Verificar rango de fechas cargadas
SELECT MIN(fecha_completa) AS fecha_min,
       MAX(fecha_completa) AS fecha_max,
       COUNT(*) AS total_fechas
FROM jardineria_staging.STG_Fecha;

-- Verificar empleados con jefe resuelto vs sin jefe (Director General)
SELECT
    CASE WHEN nombre_jefe IS NULL THEN 'Sin jefe (Director)' ELSE 'Con jefe' END AS tipo,
    COUNT(*) AS empleados
FROM jardineria_staging.STG_Empleado
GROUP BY CASE WHEN nombre_jefe IS NULL THEN 'Sin jefe (Director)' ELSE 'Con jefe' END;

-- Muestra de ventas integradas con dimensiones (prueba de calidad)
SELECT TOP 5
    v.ID_hecho,
    f.fecha_completa,
    f.nombre_mes,
    f.anio,
    c.nombre_cliente,
    c.pais                  AS pais_cliente,
    p.nombre_producto,
    p.categoria,
    e.nombre_completo       AS representante,
    e.oficina_ciudad,
    pd.estado               AS estado_pedido,
    pd.dias_retraso,
    v.cantidad,
    v.precio_unidad,
    v.subtotal
FROM jardineria_staging.STG_Ventas v
INNER JOIN jardineria_staging.STG_Fecha    f  ON v.FK_fecha    = f.ID_fecha
INNER JOIN jardineria_staging.STG_Cliente  c  ON v.FK_cliente  = c.ID_dim_cliente
INNER JOIN jardineria_staging.STG_Producto p  ON v.FK_producto = p.ID_dim_producto
INNER JOIN jardineria_staging.STG_Empleado e  ON v.FK_empleado = e.ID_dim_empleado
INNER JOIN jardineria_staging.STG_Pedido   pd ON v.FK_pedido   = pd.ID_dim_pedido;
