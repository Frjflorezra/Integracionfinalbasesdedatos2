-- ============================================================
-- BACKUP (BK) - Base de Datos Staging Jardinería
-- Asignatura: Bases de Datos II
-- Estudiante: Francisco Javier Florez Ramirez
-- Fecha: Marzo 2026
-- Descripción: Script de respaldo de la base de datos Staging.
--   Incluye estructura completa de las seis tablas del modelo
--   estrella en su capa de preparación de datos.
--   Compatible con SQL Server (T-SQL / IDENTITY).
-- ============================================================

DROP DATABASE IF EXISTS jardineria_staging;
CREATE DATABASE jardineria_staging;
USE jardineria_staging;

-- ============================================================
-- ESTRUCTURA DE TABLAS STAGING
-- ============================================================

-- Dimensión de tiempo
CREATE TABLE STG_Fecha (
    ID_fecha        INT           NOT NULL,
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

-- Dimensión cliente (desnormalizada, sin fax ni direcciones)
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

-- Dimensión producto (categoría desnormalizada)
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

-- Dimensión empleado (oficina y jefe desnormalizados)
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

-- Dimensión pedido (con campo calculado dias_retraso)
CREATE TABLE STG_Pedido (
    ID_dim_pedido       INT              NOT NULL IDENTITY(1,1),
    ID_pedido_origen    INT              NOT NULL,
    fecha_esperada      DATE             NOT NULL,
    fecha_entrega       DATE             NULL,
    estado              VARCHAR(15)      NOT NULL,
    dias_retraso        INT              NULL,
    comentarios         TEXT             NULL,
    PRIMARY KEY (ID_dim_pedido)
);

-- Tabla de hechos de ventas
CREATE TABLE STG_Ventas (
    ID_hecho        INT              NOT NULL IDENTITY(1,1),
    FK_fecha        INT              NOT NULL,
    FK_cliente      INT              NOT NULL,
    FK_producto     INT              NOT NULL,
    FK_empleado     INT              NOT NULL,
    FK_pedido       INT              NOT NULL,
    cantidad        INT              NOT NULL,
    precio_unidad   NUMERIC(15,2)    NOT NULL,
    subtotal        NUMERIC(15,2)    NOT NULL,
    numero_linea    SMALLINT         NOT NULL,
    PRIMARY KEY (ID_hecho),
    FOREIGN KEY (FK_fecha)    REFERENCES STG_Fecha(ID_fecha),
    FOREIGN KEY (FK_cliente)  REFERENCES STG_Cliente(ID_dim_cliente),
    FOREIGN KEY (FK_producto) REFERENCES STG_Producto(ID_dim_producto),
    FOREIGN KEY (FK_empleado) REFERENCES STG_Empleado(ID_dim_empleado),
    FOREIGN KEY (FK_pedido)   REFERENCES STG_Pedido(ID_dim_pedido)
);

-- ============================================================
-- DATOS COMPLETOS (resultado del proceso ETL desde jardinería)
-- ============================================================

-- ============================================================
-- DATOS - STG_Fecha
-- ============================================================
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20060117,'2006-01-17',17,1,'Enero',1,2006,'Martes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20060525,'2006-05-25',25,5,'Mayo',2,2006,'Jueves',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20070107,'2007-01-07',7,1,'Enero',1,2007,'Domingo',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20070319,'2007-03-19',19,3,'Marzo',1,2007,'Lunes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20070520,'2007-05-20',20,5,'Mayo',2,2007,'Domingo',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20070620,'2007-06-20',20,6,'Junio',2,2007,'Mi├⌐rcoles',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20071005,'2007-10-05',5,10,'Octubre',4,2007,'Viernes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20071023,'2007-10-23',23,10,'Octubre',4,2007,'Martes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20080104,'2008-01-04',4,1,'Enero',1,2008,'Viernes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20080305,'2008-03-05',5,3,'Marzo',1,2008,'Mi├⌐rcoles',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20080310,'2008-03-10',10,3,'Marzo',1,2008,'Lunes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20080317,'2008-03-17',17,3,'Marzo',1,2008,'Lunes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20080320,'2008-03-20',20,3,'Marzo',1,2008,'Jueves',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20080620,'2008-06-20',20,6,'Junio',2,2008,'Viernes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20080628,'2008-06-28',28,6,'Junio',2,2008,'S├íbado',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20080712,'2008-07-12',12,7,'Julio',3,2008,'S├íbado',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20080714,'2008-07-14',14,7,'Julio',3,2008,'Lunes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20080801,'2008-08-01',1,8,'Agosto',3,2008,'Viernes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20080803,'2008-08-03',3,8,'Agosto',3,2008,'Domingo',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20080825,'2008-08-25',25,8,'Agosto',3,2008,'Lunes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20080904,'2008-09-04',4,9,'Septiembre',3,2008,'Jueves',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20081001,'2008-10-01',1,10,'Octubre',4,2008,'Mi├⌐rcoles',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20081008,'2008-10-08',8,10,'Octubre',4,2008,'Mi├⌐rcoles',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20081015,'2008-10-15',15,10,'Octubre',4,2008,'Mi├⌐rcoles',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20081028,'2008-10-28',28,10,'Octubre',4,2008,'Martes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20081103,'2008-11-03',3,11,'Noviembre',4,2008,'Lunes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20081109,'2008-11-09',9,11,'Noviembre',4,2008,'Domingo',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20081110,'2008-11-10',10,11,'Noviembre',4,2008,'Lunes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20081115,'2008-11-15',15,11,'Noviembre',4,2008,'S├íbado',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20081129,'2008-11-29',29,11,'Noviembre',4,2008,'S├íbado',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20081207,'2008-12-07',7,12,'Diciembre',4,2008,'Domingo',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20081210,'2008-12-10',10,12,'Diciembre',4,2008,'Mi├⌐rcoles',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20081215,'2008-12-15',15,12,'Diciembre',4,2008,'Lunes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20081219,'2008-12-19',19,12,'Diciembre',4,2008,'Viernes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20081222,'2008-12-22',22,12,'Diciembre',4,2008,'Lunes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20081228,'2008-12-28',28,12,'Diciembre',4,2008,'Domingo',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20081230,'2008-12-30',30,12,'Diciembre',4,2008,'Martes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090102,'2009-01-02',2,1,'Enero',1,2009,'Viernes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090103,'2009-01-03',3,1,'Enero',1,2009,'S├íbado',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090105,'2009-01-05',5,1,'Enero',1,2009,'Lunes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090106,'2009-01-06',6,1,'Enero',1,2009,'Martes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090108,'2009-01-08',8,1,'Enero',1,2009,'Jueves',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090109,'2009-01-09',9,1,'Enero',1,2009,'Viernes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090110,'2009-01-10',10,1,'Enero',1,2009,'S├íbado',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090111,'2009-01-11',11,1,'Enero',1,2009,'Domingo',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090112,'2009-01-12',12,1,'Enero',1,2009,'Lunes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090114,'2009-01-14',14,1,'Enero',1,2009,'Mi├⌐rcoles',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090115,'2009-01-15',15,1,'Enero',1,2009,'Jueves',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090118,'2009-01-18',18,1,'Enero',1,2009,'Domingo',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090120,'2009-01-20',20,1,'Enero',1,2009,'Martes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090122,'2009-01-22',22,1,'Enero',1,2009,'Jueves',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090124,'2009-01-24',24,1,'Enero',1,2009,'S├íbado',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090125,'2009-01-25',25,1,'Enero',1,2009,'Domingo',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090202,'2009-02-02',2,2,'Febrero',1,2009,'Lunes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090206,'2009-02-06',6,2,'Febrero',1,2009,'Viernes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090207,'2009-02-07',7,2,'Febrero',1,2009,'S├íbado',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090210,'2009-02-10',10,2,'Febrero',1,2009,'Martes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090214,'2009-02-14',14,2,'Febrero',1,2009,'S├íbado',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090215,'2009-02-15',15,2,'Febrero',1,2009,'Domingo',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090302,'2009-03-02',2,3,'Marzo',1,2009,'Lunes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090305,'2009-03-05',5,3,'Marzo',1,2009,'Jueves',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090306,'2009-03-06',6,3,'Marzo',1,2009,'Viernes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090307,'2009-03-07',7,3,'Marzo',1,2009,'S├íbado',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090309,'2009-03-09',9,3,'Marzo',1,2009,'Lunes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090312,'2009-03-12',12,3,'Marzo',1,2009,'Jueves',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090318,'2009-03-18',18,3,'Marzo',1,2009,'Mi├⌐rcoles',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090322,'2009-03-22',22,3,'Marzo',1,2009,'Domingo',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090325,'2009-03-25',25,3,'Marzo',1,2009,'Mi├⌐rcoles',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090326,'2009-03-26',26,3,'Marzo',1,2009,'Jueves',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090401,'2009-04-01',1,4,'Abril',2,2009,'Mi├⌐rcoles',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090403,'2009-04-03',3,4,'Abril',2,2009,'Viernes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090406,'2009-04-06',6,4,'Abril',2,2009,'Lunes',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090409,'2009-04-09',9,4,'Abril',2,2009,'Jueves',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090415,'2009-04-15',15,4,'Abril',2,2009,'Mi├⌐rcoles',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090419,'2009-04-19',19,4,'Abril',2,2009,'Domingo',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090503,'2009-05-03',3,5,'Mayo',2,2009,'Domingo',1);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20090513,'2009-05-13',13,5,'Mayo',2,2009,'Mi├⌐rcoles',0);
INSERT INTO STG_Fecha (ID_fecha,fecha_completa,dia,mes,nombre_mes,trimestre,anio,dia_semana,es_fin_semana) VALUES (20091018,'2009-10-18',18,10,'Octubre',4,2009,'Domingo',1);

-- ============================================================
-- DATOS - STG_Cliente
-- ============================================================
SET IDENTITY_INSERT STG_Cliente ON;
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (1,1,'GoldFish Garden','Daniel G','GoldFish','5556901745','San Francisco',NULL,'USA','24006',3000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (2,2,'Gardening Associates','Anne','Wright','5557410345','Miami','Miami','USA','24010',6000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (3,3,'Gerudo Valley','Link','Flaute','5552323129','New York',NULL,'USA','85495',12000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (4,4,'Tendo Garden','Akane','Tendo','55591233210','Miami',NULL,'USA','696969',600000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (5,5,'Lasas S.A.','Antonio','Lasas','34916540145','Fuenlabrada','Madrid','Spain','28945',154310.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (6,6,'Beragua','Jose','Bermejo','654987321','Madrid','Madrid','Spain','28942',20000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (7,7,'Club Golf Puerta del hierro','Paco','Lopez','62456810','Madrid','Madrid','Spain','28930',40000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (8,8,'Naturagua','Guillermo','Rengifo','689234750','Madrid','Madrid','Spain','28947',32000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (9,9,'DaraDistribuciones','David','Serrano','675598001','Madrid','Madrid','Spain','28946',50000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (10,10,'Madrile├â┬▒a de riegos','Jose','Taca├â┬▒o','655983045','Madrid','Madrid','Spain','28943',20000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (11,12,'Camunas Jardines S.L.','Pedro','Camunas','34914873241','San Lorenzo del Escorial','Madrid','Spain','28145',16481.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (12,13,'Dardena S.A.','Juan','Rodriguez','34912453217','Madrid','Madrid','Spain','28003',321000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (13,14,'Jardin de Flores','Javier','Villar','654865643','Madrid','Madrid','Spain','28950',40000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (14,15,'Flores Marivi','Maria','Rodriguez','666555444','Fuenlabrada','Madrid','Spain','28945',1500.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (15,16,'Flowers, S.A','Beatriz','Fernandez','698754159','Montornes del valles','Barcelona','Spain','24586',3500.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (16,17,'Naturajardin','Victoria','Cruz','612343529','Madrid','Madrid','Spain','28011',5050.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (17,18,'Golf S.A.','Luis','Martinez','916458762','Santa cruz de Tenerife','Islas Canarias','Spain','38297',30000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (18,19,'Americh Golf Management SL','Mario','Suarez','964493072','Barcelona','Catalu├â┬▒a','Spain','12320',20000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (19,20,'Aloha','Cristian','Rodrigez','916485852','Canarias','Canarias','Spain','35488',50000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (20,21,'El Prat','Francisco','Camacho','916882323','Barcelona','Catalu├â┬▒a','Spain','12320',30000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (21,22,'Sotogrande','Maria','Santillana','915576622','Sotogrande','Cadiz','Spain','11310',60000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (22,23,'Vivero Humanes','Federico','Gomez','654987690','Humanes','Madrid','Spain','28970',7430.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (23,24,'Fuenla City','Tony','Mu├â┬▒oz Mena','675842139','Fuenlabrada','Madrid','Spain','28574',4500.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (24,25,'Jardines y Mansiones Cactus SL','Eva Mar├â┬¡a','S├â┬ínchez','916877445','Madrid','Madrid','Spain','29874',76000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (25,26,'Jardiner├â┬¡as Mat├â┬¡as SL','Mat├â┬¡as','San Mart├â┬¡n','916544147','Madrid','Madrid','Spain','37845',100500.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (26,27,'Agrojardin','Benito','Lopez','675432926','Getafe','Madrid','Spain','28904',8040.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (27,28,'Top Campo','Joseluis','Sanchez','685746512','Humanes','Madrid','Spain','28574',5500.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (28,29,'Jardineria Sara','Sara','Marquez','675124537','Fuenlabrada','Madrid','Spain','27584',7500.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (29,30,'Campohermoso','Luis','Jimenez','645925376','Fuenlabrada','Madrid','Spain','28945',3250.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (30,31,'france telecom','Fra├â╞Æ├é┬ºois','Toulou','(33)5120578961','Paris',NULL,'France','75010',10000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (31,32,'Mus├â┬⌐e du Louvre','Pierre','Delacroux','(33)0140205050','Paris',NULL,'France','75058',30000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (32,33,'Tutifruti S.A','Jacob','Jones','2 9261-2433','Sydney','Nueva Gales del Sur','Australia','2000',10000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (33,34,'Flores S.L.','Antonio','Romero','654352981','Madrid','Fuenlabrada','Spain','29643',6000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (34,35,'The Magic Garden','Richard','Mcain','926523468','London','London','United Kingdom','65930',10000.00);
INSERT INTO STG_Cliente (ID_dim_cliente,ID_cliente_origen,nombre_cliente,nombre_contacto,apellido_contacto,telefono,ciudad,region,pais,codigo_postal,limite_credito) VALUES (35,36,'El Jardin Viviente S.L','Justin','Smith','2 8005-7161','Sydney','Nueva Gales del Sur','Australia','2003',8000.00);
SET IDENTITY_INSERT STG_Cliente OFF;

-- ============================================================
-- DATOS - STG_Producto
-- ============================================================
SET IDENTITY_INSERT STG_Producto ON;
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (1,'11679','Sierra de Poda 400MM','Herramientas','HiperGarden Tools','0,258',14.00,11.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (2,'21636','Pala','Herramientas','HiperGarden Tools','0,156',14.00,13.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (3,'22225','Rastrillo de Jard├â┬¡n','Herramientas','HiperGarden Tools','1,064',12.00,11.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (4,'30310','Azad├â┬│n','Herramientas','HiperGarden Tools','0,168',12.00,11.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (5,'AR-001','Ajedrea','Arom├íticas','Murcia Seasons','15-20',1.00,0.00,140);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (6,'AR-002','Lav├â┬índula Dentata','Arom├íticas','Murcia Seasons','15-20',1.00,0.00,140);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (7,'AR-003','Mejorana','Arom├íticas','Murcia Seasons','15-20',1.00,0.00,140);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (8,'AR-004','Melissa ','Arom├íticas','Murcia Seasons','15-20',1.00,0.00,140);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (9,'AR-005','Mentha Sativa','Arom├íticas','Murcia Seasons','15-20',1.00,0.00,140);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (10,'AR-006','Petrosilium Hortense (Peregil)','Arom├íticas','Murcia Seasons','15-20',1.00,0.00,140);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (11,'AR-007','Salvia Mix','Arom├íticas','Murcia Seasons','15-20',1.00,0.00,140);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (12,'AR-008','Thymus Citriodra (Tomillo lim├â┬│n)','Arom├íticas','Murcia Seasons','15-20',1.00,0.00,140);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (13,'AR-009','Thymus Vulgaris','Arom├íticas','Murcia Seasons','15-20',1.00,0.00,140);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (14,'AR-010','Santolina Chamaecyparys','Arom├íticas','Murcia Seasons','15-20',1.00,0.00,140);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (15,'FR-1','Expositor C├â┬¡tricos Mix','Frutales','Frutales Talavera S.A','100-120',7.00,5.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (16,'FR-10','Limonero 2 a├â┬▒os injerto','Frutales','NaranjasValencianas.com','',7.00,5.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (17,'FR-100','Nectarina','Frutales','Frutales Talavera S.A','8/10',11.00,8.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (18,'FR-101','Nogal','Frutales','Frutales Talavera S.A','8/10',13.00,10.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (19,'FR-102','Olea-Olivos','Frutales','Frutales Talavera S.A','8/10',18.00,14.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (20,'FR-103','Olea-Olivos','Frutales','Frutales Talavera S.A','10/12',25.00,20.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (21,'FR-104','Olea-Olivos','Frutales','Frutales Talavera S.A','12/4',49.00,39.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (22,'FR-105','Olea-Olivos','Frutales','Frutales Talavera S.A','14/16',70.00,56.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (23,'FR-106','Peral','Frutales','Frutales Talavera S.A','8/10',11.00,8.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (24,'FR-107','Peral','Frutales','Frutales Talavera S.A','10/12',22.00,17.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (25,'FR-108','Peral','Frutales','Frutales Talavera S.A','12/14',32.00,25.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (26,'FR-11','Limonero 30/40','Frutales','NaranjasValencianas.com','',100.00,80.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (27,'FR-12','Kunquat ','Frutales','NaranjasValencianas.com','',21.00,16.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (28,'FR-13','Kunquat  EXTRA con FRUTA','Frutales','NaranjasValencianas.com','150-170',57.00,45.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (29,'FR-14','Calamondin Mini','Frutales','Frutales Talavera S.A','',10.00,8.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (30,'FR-15','Calamondin Copa ','Frutales','Frutales Talavera S.A','',25.00,20.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (31,'FR-16','Calamondin Copa EXTRA Con FRUTA','Frutales','Frutales Talavera S.A','100-120',45.00,36.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (32,'FR-17','Rosal bajo 1├âΓÇÜ├é┬¬ -En maceta-inicio brotaci├â┬│n','Frutales','Frutales Talavera S.A','',2.00,1.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (33,'FR-18','ROSAL TREPADOR','Frutales','Frutales Talavera S.A','',4.00,3.00,350);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (34,'FR-19','Camelia Blanco, Chrysler Rojo, Soraya Naranja, ','Frutales','NaranjasValencianas.com','',4.00,3.00,350);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (35,'FR-2','Naranjo -Plant├â┬│n joven 1 a├â┬▒o injerto','Frutales','NaranjasValencianas.com','',6.00,4.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (36,'FR-20','Landora Amarillo, Rose Gaujard bicolor blanco-rojo','Frutales','Frutales Talavera S.A','',4.00,3.00,350);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (37,'FR-21','Kordes Perfect bicolor rojo-amarillo, Roundelay rojo fuerte','Frutales','Frutales Talavera S.A','',4.00,3.00,350);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (38,'FR-22','Pitimini rojo','Frutales','Frutales Talavera S.A','',4.00,3.00,350);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (39,'FR-23','Rosal copa ','Frutales','Frutales Talavera S.A','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (40,'FR-24','Albaricoquero Corbato','Frutales','Melocotones de Cieza S.A.','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (41,'FR-25','Albaricoquero Moniqui','Frutales','Melocotones de Cieza S.A.','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (42,'FR-26','Albaricoquero Kurrot','Frutales','Melocotones de Cieza S.A.','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (43,'FR-27','Cerezo Burlat','Frutales','Jerte Distribuciones S.L.','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (44,'FR-28','Cerezo Picota','Frutales','Jerte Distribuciones S.L.','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (45,'FR-29','Cerezo Napole├â┬│n','Frutales','Jerte Distribuciones S.L.','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (46,'FR-3','Naranjo 2 a├â┬▒os injerto','Frutales','NaranjasValencianas.com','',7.00,5.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (47,'FR-30','Ciruelo R. Claudia Verde   ','Frutales','Frutales Talavera S.A','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (48,'FR-31','Ciruelo Santa Rosa','Frutales','Frutales Talavera S.A','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (49,'FR-32','Ciruelo Golden Japan','Frutales','Frutales Talavera S.A','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (50,'FR-33','Ciruelo Friar','Frutales','Frutales Talavera S.A','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (51,'FR-34','Ciruelo Reina C. De Ollins','Frutales','Frutales Talavera S.A','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (52,'FR-35','Ciruelo Claudia Negra','Frutales','Frutales Talavera S.A','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (53,'FR-36','Granado Mollar de Elche','Frutales','Frutales Talavera S.A','',9.00,7.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (54,'FR-37','Higuera Napolitana','Frutales','Frutales Talavera S.A','',9.00,7.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (55,'FR-38','Higuera Verdal','Frutales','Frutales Talavera S.A','',9.00,7.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (56,'FR-39','Higuera Breva','Frutales','Frutales Talavera S.A','',9.00,7.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (57,'FR-4','Naranjo calibre 8/10','Frutales','NaranjasValencianas.com','',29.00,23.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (58,'FR-40','Manzano Starking Delicious','Frutales','Frutales Talavera S.A','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (59,'FR-41','Manzano Reineta','Frutales','Frutales Talavera S.A','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (60,'FR-42','Manzano Golden Delicious','Frutales','Frutales Talavera S.A','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (61,'FR-43','Membrillero Gigante de Wranja','Frutales','Frutales Talavera S.A','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (62,'FR-44','Melocotonero Spring Crest','Frutales','Melocotones de Cieza S.A.','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (63,'FR-45','Melocotonero Amarillo de Agosto','Frutales','Melocotones de Cieza S.A.','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (64,'FR-46','Melocotonero Federica','Frutales','Melocotones de Cieza S.A.','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (65,'FR-47','Melocotonero Paraguayo','Frutales','Melocotones de Cieza S.A.','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (66,'FR-48','Nogal Com├â┬║n','Frutales','Frutales Talavera S.A','',9.00,7.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (67,'FR-49','Parra Uva de Mesa','Frutales','Frutales Talavera S.A','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (68,'FR-5','Mandarino -Plant├â┬│n joven','Frutales','Frutales Talavera S.A','',6.00,4.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (69,'FR-50','Peral Castell','Frutales','Frutales Talavera S.A','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (70,'FR-51','Peral Williams','Frutales','Frutales Talavera S.A','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (71,'FR-52','Peral Conference','Frutales','Frutales Talavera S.A','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (72,'FR-53','Peral Blanq. de Aranjuez','Frutales','Frutales Talavera S.A','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (73,'FR-54','N├â┬¡spero Tanaca','Frutales','Frutales Talavera S.A','',9.00,7.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (74,'FR-55','Olivo Cipresino','Frutales','Frutales Talavera S.A','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (75,'FR-56','Nectarina','Frutales','Frutales Talavera S.A','',8.00,6.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (76,'FR-57','Kaki Rojo Brillante','Frutales','NaranjasValencianas.com','',9.00,7.00,400);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (77,'FR-58','Albaricoquero','Frutales','Melocotones de Cieza S.A.','8/10',11.00,8.00,200);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (78,'FR-59','Albaricoquero','Frutales','Melocotones de Cieza S.A.','10/12',22.00,17.00,200);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (79,'FR-6','Mandarino 2 a├â┬▒os injerto','Frutales','Frutales Talavera S.A','',7.00,5.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (80,'FR-60','Albaricoquero','Frutales','Melocotones de Cieza S.A.','12/14',32.00,25.00,200);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (81,'FR-61','Albaricoquero','Frutales','Melocotones de Cieza S.A.','14/16',49.00,39.00,200);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (82,'FR-62','Albaricoquero','Frutales','Melocotones de Cieza S.A.','16/18',70.00,56.00,200);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (83,'FR-63','Cerezo','Frutales','Jerte Distribuciones S.L.','8/10',11.00,8.00,300);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (84,'FR-64','Cerezo','Frutales','Jerte Distribuciones S.L.','10/12',22.00,17.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (85,'FR-65','Cerezo','Frutales','Jerte Distribuciones S.L.','12/14',32.00,25.00,200);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (86,'FR-66','Cerezo','Frutales','Jerte Distribuciones S.L.','14/16',49.00,39.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (87,'FR-67','Cerezo','Frutales','Jerte Distribuciones S.L.','16/18',70.00,56.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (88,'FR-68','Cerezo','Frutales','Jerte Distribuciones S.L.','18/20',80.00,64.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (89,'FR-69','Cerezo','Frutales','Jerte Distribuciones S.L.','20/25',91.00,72.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (90,'FR-7','Mandarino calibre 8/10','Frutales','Frutales Talavera S.A','',29.00,23.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (91,'FR-70','Ciruelo','Frutales','Frutales Talavera S.A','8/10',11.00,8.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (92,'FR-71','Ciruelo','Frutales','Frutales Talavera S.A','10/12',22.00,17.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (93,'FR-72','Ciruelo','Frutales','Frutales Talavera S.A','12/14',32.00,25.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (94,'FR-73','Granado','Frutales','Frutales Talavera S.A','8/10',13.00,10.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (95,'FR-74','Granado','Frutales','Frutales Talavera S.A','10/12',22.00,17.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (96,'FR-75','Granado','Frutales','Frutales Talavera S.A','12/14',32.00,25.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (97,'FR-76','Granado','Frutales','Frutales Talavera S.A','14/16',49.00,39.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (98,'FR-77','Granado','Frutales','Frutales Talavera S.A','16/18',70.00,56.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (99,'FR-78','Higuera','Frutales','Frutales Talavera S.A','8/10',15.00,12.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (100,'FR-79','Higuera','Frutales','Frutales Talavera S.A','10/12',22.00,17.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (101,'FR-8','Limonero -Plant├â┬│n joven','Frutales','NaranjasValencianas.com','',6.00,4.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (102,'FR-80','Higuera','Frutales','Frutales Talavera S.A','12/14',32.00,25.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (103,'FR-81','Higuera','Frutales','Frutales Talavera S.A','14/16',49.00,39.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (104,'FR-82','Higuera','Frutales','Frutales Talavera S.A','16/18',70.00,56.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (105,'FR-83','Higuera','Frutales','Frutales Talavera S.A','18/20',80.00,64.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (106,'FR-84','Kaki','Frutales','NaranjasValencianas.com','8/10',13.00,10.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (107,'FR-85','Kaki','Frutales','NaranjasValencianas.com','16/18',70.00,56.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (108,'FR-86','Manzano','Frutales','Frutales Talavera S.A','8/10',11.00,8.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (109,'FR-87','Manzano','Frutales','Frutales Talavera S.A','10/12',22.00,17.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (110,'FR-88','Manzano','Frutales','Frutales Talavera S.A','12/14',32.00,25.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (111,'FR-89','Manzano','Frutales','Frutales Talavera S.A','14/16',49.00,39.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (112,'FR-9','Limonero calibre 8/10','Frutales','NaranjasValencianas.com','',29.00,23.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (113,'FR-90','N├â┬¡spero','Frutales','Frutales Talavera S.A','16/18',70.00,56.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (114,'FR-91','N├â┬¡spero','Frutales','Frutales Talavera S.A','18/20',80.00,64.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (115,'FR-92','Melocotonero','Frutales','Melocotones de Cieza S.A.','8/10',11.00,8.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (116,'FR-93','Melocotonero','Frutales','Melocotones de Cieza S.A.','10/12',22.00,17.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (117,'FR-94','Melocotonero','Frutales','Melocotones de Cieza S.A.','12/14',32.00,25.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (118,'FR-95','Melocotonero','Frutales','Melocotones de Cieza S.A.','14/16',49.00,39.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (119,'FR-96','Membrillero','Frutales','Frutales Talavera S.A','8/10',11.00,8.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (120,'FR-97','Membrillero','Frutales','Frutales Talavera S.A','10/12',22.00,17.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (121,'FR-98','Membrillero','Frutales','Frutales Talavera S.A','12/14',32.00,25.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (122,'FR-99','Membrillero','Frutales','Frutales Talavera S.A','14/16',49.00,39.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (123,'OR-001','Arbustos Mix Maceta','Ornamentales','Valencia Garden Service','40-60',5.00,4.00,25);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (124,'OR-100','Mimosa Injerto CLASICA Dealbata ','Ornamentales','Viveros EL OASIS','100-110',12.00,9.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (125,'OR-101','Expositor Mimosa Semilla Mix','Ornamentales','Viveros EL OASIS','170-200',6.00,4.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (126,'OR-102','Mimosa Semilla Bayleyana  ','Ornamentales','Viveros EL OASIS','170-200',6.00,4.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (127,'OR-103','Mimosa Semilla Bayleyana   ','Ornamentales','Viveros EL OASIS','200-225',10.00,8.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (128,'OR-104','Mimosa Semilla Cyanophylla    ','Ornamentales','Viveros EL OASIS','200-225',10.00,8.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (129,'OR-105','Mimosa Semilla Espectabilis  ','Ornamentales','Viveros EL OASIS','160-170',6.00,4.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (130,'OR-106','Mimosa Semilla Longifolia   ','Ornamentales','Viveros EL OASIS','200-225',10.00,8.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (131,'OR-107','Mimosa Semilla Floribunda 4 estaciones','Ornamentales','Viveros EL OASIS','120-140',6.00,4.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (132,'OR-108','Abelia Floribunda','Ornamentales','Viveros EL OASIS','35-45',5.00,4.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (133,'OR-109','Callistemom (Mix)','Ornamentales','Viveros EL OASIS','35-45',5.00,4.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (134,'OR-110','Callistemom (Mix)','Ornamentales','Viveros EL OASIS','40-60',2.00,1.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (135,'OR-111','Corylus Avellana \"Contorta\"','Ornamentales','Viveros EL OASIS','35-45',5.00,4.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (136,'OR-112','Escallonia (Mix)','Ornamentales','Viveros EL OASIS','35-45',5.00,4.00,120);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (137,'OR-113','Evonimus Emerald Gayeti','Ornamentales','Viveros EL OASIS','35-45',5.00,4.00,120);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (138,'OR-114','Evonimus Pulchellus','Ornamentales','Viveros EL OASIS','35-45',5.00,4.00,120);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (139,'OR-115','Forsytia Intermedia \"Lynwood\"','Ornamentales','Viveros EL OASIS','35-45',7.00,5.00,120);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (140,'OR-116','Hibiscus Syriacus  \"Diana\" -Blanco Puro','Ornamentales','Viveros EL OASIS','35-45',7.00,5.00,120);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (141,'OR-117','Hibiscus Syriacus  \"Helene\" -Blanco-C.rojo','Ornamentales','Viveros EL OASIS','35-45',7.00,5.00,120);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (142,'OR-118','Hibiscus Syriacus \"Pink Giant\" Rosa','Ornamentales','Viveros EL OASIS','35-45',7.00,5.00,120);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (143,'OR-119','Laurus Nobilis Arbusto - Ramificado Bajo','Ornamentales','Viveros EL OASIS','40-50',5.00,4.00,120);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (144,'OR-120','Lonicera Nitida ','Ornamentales','Viveros EL OASIS','35-45',5.00,4.00,120);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (145,'OR-121','Lonicera Nitida \"Maigrum\"','Ornamentales','Viveros EL OASIS','35-45',5.00,4.00,120);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (146,'OR-122','Lonicera Pileata','Ornamentales','Viveros EL OASIS','35-45',5.00,4.00,120);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (147,'OR-123','Philadelphus \"Virginal\"','Ornamentales','Viveros EL OASIS','35-45',5.00,4.00,120);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (148,'OR-124','Prunus pisardii  ','Ornamentales','Viveros EL OASIS','35-45',5.00,4.00,120);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (149,'OR-125','Viburnum Tinus \"Eve Price\"','Ornamentales','Viveros EL OASIS','35-45',5.00,4.00,120);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (150,'OR-126','Weigelia \"Bristol Ruby\"','Ornamentales','Viveros EL OASIS','35-45',5.00,4.00,120);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (151,'OR-127','Camelia japonica','Ornamentales','Viveros EL OASIS','40-60',7.00,5.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (152,'OR-128','Camelia japonica ejemplar','Ornamentales','Viveros EL OASIS','200-250',98.00,78.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (153,'OR-129','Camelia japonica ejemplar','Ornamentales','Viveros EL OASIS','250-300',110.00,88.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (154,'OR-130','Callistemom COPA','Ornamentales','Viveros EL OASIS','110/120',18.00,14.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (155,'OR-131','Leptospermum formado PIRAMIDE','Ornamentales','Viveros EL OASIS','80-100',18.00,14.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (156,'OR-132','Leptospermum COPA','Ornamentales','Viveros EL OASIS','110/120',18.00,14.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (157,'OR-133','Nerium oleander-CALIDAD \"GARDEN\"','Ornamentales','Viveros EL OASIS','40-45',2.00,1.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (158,'OR-134','Nerium Oleander Arbusto GRANDE','Ornamentales','Viveros EL OASIS','160-200',38.00,30.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (159,'OR-135','Nerium oleander COPA  Calibre 6/8','Ornamentales','Viveros EL OASIS','50-60',5.00,4.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (160,'OR-136','Nerium oleander ARBOL Calibre 8/10','Ornamentales','Viveros EL OASIS','225-250',18.00,14.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (161,'OR-137','ROSAL TREPADOR','Ornamentales','Viveros EL OASIS','',4.00,3.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (162,'OR-138','Camelia Blanco, Chrysler Rojo, Soraya Naranja, ','Ornamentales','Viveros EL OASIS','',4.00,3.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (163,'OR-139','Landora Amarillo, Rose Gaujard bicolor blanco-rojo','Ornamentales','Viveros EL OASIS','',4.00,3.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (164,'OR-140','Kordes Perfect bicolor rojo-amarillo, Roundelay rojo fuerte','Ornamentales','Viveros EL OASIS','',4.00,3.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (165,'OR-141','Pitimini rojo','Ornamentales','Viveros EL OASIS','',4.00,3.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (166,'OR-142','Solanum Jazminoide','Ornamentales','Viveros EL OASIS','150-160',2.00,1.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (167,'OR-143','Wisteria Sinensis  azul, rosa, blanca','Ornamentales','Viveros EL OASIS','',9.00,7.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (168,'OR-144','Wisteria Sinensis INJERTADAS DEC├â╞Æ├óΓé¼┼ô','Ornamentales','Viveros EL OASIS','140-150',12.00,9.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (169,'OR-145','Bougamvillea Sanderiana Tutor','Ornamentales','Viveros EL OASIS','80-100',2.00,1.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (170,'OR-146','Bougamvillea Sanderiana Tutor','Ornamentales','Viveros EL OASIS','125-150',4.00,3.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (171,'OR-147','Bougamvillea Sanderiana Tutor','Ornamentales','Viveros EL OASIS','180-200',7.00,5.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (172,'OR-148','Bougamvillea Sanderiana Espaldera','Ornamentales','Viveros EL OASIS','45-50',7.00,5.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (173,'OR-149','Bougamvillea Sanderiana Espaldera','Ornamentales','Viveros EL OASIS','140-150',17.00,13.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (174,'OR-150','Bougamvillea roja, naranja','Ornamentales','Viveros EL OASIS','110-130',2.00,1.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (175,'OR-151','Bougamvillea Sanderiana, 3 tut. piramide','Ornamentales','Viveros EL OASIS','',6.00,4.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (176,'OR-152','Expositor ├â┬ürboles clima continental','Ornamentales','Viveros EL OASIS','170-200',6.00,4.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (177,'OR-153','Expositor ├â┬ürboles clima mediterr├â┬íneo','Ornamentales','Viveros EL OASIS','170-200',6.00,4.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (178,'OR-154','Expositor ├â┬ürboles borde del mar','Ornamentales','Viveros EL OASIS','170-200',6.00,4.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (179,'OR-155','Acer Negundo  ','Ornamentales','Viveros EL OASIS','200-225',6.00,4.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (180,'OR-156','Acer platanoides  ','Ornamentales','Viveros EL OASIS','200-225',10.00,8.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (181,'OR-157','Acer Pseudoplatanus ','Ornamentales','Viveros EL OASIS','200-225',10.00,8.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (182,'OR-158','Brachychiton Acerifolius  ','Ornamentales','Viveros EL OASIS','200-225',6.00,4.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (183,'OR-159','Brachychiton Discolor  ','Ornamentales','Viveros EL OASIS','200-225',6.00,4.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (184,'OR-160','Brachychiton Rupestris','Ornamentales','Viveros EL OASIS','170-200',10.00,8.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (185,'OR-161','Cassia Corimbosa  ','Ornamentales','Viveros EL OASIS','200-225',6.00,4.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (186,'OR-162','Cassia Corimbosa ','Ornamentales','Viveros EL OASIS','200-225',10.00,8.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (187,'OR-163','Chitalpa Summer Bells   ','Ornamentales','Viveros EL OASIS','200-225',10.00,8.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (188,'OR-164','Erytrina Kafra','Ornamentales','Viveros EL OASIS','170-180',6.00,4.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (189,'OR-165','Erytrina Kafra','Ornamentales','Viveros EL OASIS','200-225',10.00,8.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (190,'OR-166','Eucalyptus Citriodora  ','Ornamentales','Viveros EL OASIS','170-200',6.00,4.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (191,'OR-167','Eucalyptus Ficifolia  ','Ornamentales','Viveros EL OASIS','170-200',6.00,4.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (192,'OR-168','Eucalyptus Ficifolia   ','Ornamentales','Viveros EL OASIS','200-225',10.00,8.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (193,'OR-169','Hibiscus Syriacus  Var. Injertadas 1 Tallo ','Ornamentales','Viveros EL OASIS','170-200',12.00,9.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (194,'OR-170','Lagunaria Patersonii  ','Ornamentales','Viveros EL OASIS','140-150',6.00,4.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (195,'OR-171','Lagunaria Patersonii   ','Ornamentales','Viveros EL OASIS','200-225',10.00,8.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (196,'OR-172','Lagunaria patersonii  calibre 8/10','Ornamentales','Viveros EL OASIS','200-225',18.00,14.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (197,'OR-173','Morus Alba  ','Ornamentales','Viveros EL OASIS','200-225',6.00,4.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (198,'OR-174','Morus Alba  calibre 8/10','Ornamentales','Viveros EL OASIS','200-225',18.00,14.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (199,'OR-175','Platanus Acerifolia   ','Ornamentales','Viveros EL OASIS','200-225',10.00,8.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (200,'OR-176','Prunus pisardii  ','Ornamentales','Viveros EL OASIS','200-225',10.00,8.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (201,'OR-177','Robinia Pseudoacacia Casque Rouge   ','Ornamentales','Viveros EL OASIS','200-225',15.00,12.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (202,'OR-178','Salix Babylonica  Pendula  ','Ornamentales','Viveros EL OASIS','170-200',6.00,4.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (203,'OR-179','Sesbania Punicea   ','Ornamentales','Viveros EL OASIS','170-200',6.00,4.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (204,'OR-180','Tamarix  Ramosissima Pink Cascade   ','Ornamentales','Viveros EL OASIS','170-200',6.00,4.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (205,'OR-181','Tamarix  Ramosissima Pink Cascade   ','Ornamentales','Viveros EL OASIS','200-225',10.00,8.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (206,'OR-182','Tecoma Stands   ','Ornamentales','Viveros EL OASIS','200-225',6.00,4.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (207,'OR-183','Tecoma Stands  ','Ornamentales','Viveros EL OASIS','200-225',10.00,8.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (208,'OR-184','Tipuana Tipu  ','Ornamentales','Viveros EL OASIS','170-200',6.00,4.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (209,'OR-185','Pleioblastus distichus-Bamb├â┬║ enano','Ornamentales','Viveros EL OASIS','15-20',6.00,4.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (210,'OR-186','Sasa palmata ','Ornamentales','Viveros EL OASIS','20-30',6.00,4.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (211,'OR-187','Sasa palmata ','Ornamentales','Viveros EL OASIS','40-45',10.00,8.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (212,'OR-188','Sasa palmata ','Ornamentales','Viveros EL OASIS','50-60',25.00,20.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (213,'OR-189','Phylostachys aurea','Ornamentales','Viveros EL OASIS','180-200',22.00,17.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (214,'OR-190','Phylostachys aurea','Ornamentales','Viveros EL OASIS','250-300',32.00,25.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (215,'OR-191','Phylostachys Bambusa Spectabilis','Ornamentales','Viveros EL OASIS','180-200',24.00,19.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (216,'OR-192','Phylostachys biseti','Ornamentales','Viveros EL OASIS','160-170',22.00,17.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (217,'OR-193','Phylostachys biseti','Ornamentales','Viveros EL OASIS','160-180',20.00,16.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (218,'OR-194','Pseudosasa japonica (Metake)','Ornamentales','Viveros EL OASIS','225-250',20.00,16.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (219,'OR-195','Pseudosasa japonica (Metake) ','Ornamentales','Viveros EL OASIS','30-40',6.00,4.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (220,'OR-196','Cedrus Deodara ','Ornamentales','Viveros EL OASIS','80-100',10.00,8.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (221,'OR-197','Cedrus Deodara \"Feeling Blue\" Novedad','Ornamentales','Viveros EL OASIS','rastrero',12.00,9.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (222,'OR-198','Juniperus chinensis \"Blue Alps\"','Ornamentales','Viveros EL OASIS','20-30',4.00,3.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (223,'OR-199','Juniperus Chinensis Stricta','Ornamentales','Viveros EL OASIS','20-30',4.00,3.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (224,'OR-200','Juniperus horizontalis Wiltonii','Ornamentales','Viveros EL OASIS','20-30',4.00,3.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (225,'OR-201','Juniperus squamata \"Blue Star\"','Ornamentales','Viveros EL OASIS','20-30',4.00,3.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (226,'OR-202','Juniperus x media Phitzeriana verde','Ornamentales','Viveros EL OASIS','20-30',4.00,3.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (227,'OR-203','Pinus Canariensis','Ornamentales','Viveros EL OASIS','80-100',10.00,8.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (228,'OR-204','Pinus Halepensis','Ornamentales','Viveros EL OASIS','160-180',10.00,8.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (229,'OR-205','Pinus Pinea -Pino Pi├â┬▒onero','Ornamentales','Viveros EL OASIS','70-80',10.00,8.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (230,'OR-206','Thuja Esmeralda ','Ornamentales','Viveros EL OASIS','80-100',5.00,4.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (231,'OR-207','Tuja Occidentalis Woodwardii','Ornamentales','Viveros EL OASIS','20-30',4.00,3.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (232,'OR-208','Tuja orientalis \"Aurea nana\"','Ornamentales','Viveros EL OASIS','20-30',4.00,3.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (233,'OR-209','Archontophoenix Cunninghamiana','Ornamentales','Viveros EL OASIS','80 - 100',10.00,8.00,80);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (234,'OR-210','Beucarnea Recurvata','Ornamentales','Viveros EL OASIS','130  - 150',39.00,31.00,2);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (235,'OR-211','Beucarnea Recurvata','Ornamentales','Viveros EL OASIS','180 - 200',59.00,47.00,5);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (236,'OR-212','Bismarckia Nobilis','Ornamentales','Viveros EL OASIS','200 - 220',217.00,173.00,4);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (237,'OR-213','Bismarckia Nobilis','Ornamentales','Viveros EL OASIS','240 - 260',266.00,212.00,4);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (238,'OR-214','Brahea Armata','Ornamentales','Viveros EL OASIS','45 - 60',10.00,8.00,0);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (239,'OR-215','Brahea Armata','Ornamentales','Viveros EL OASIS','120 - 140',112.00,89.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (240,'OR-216','Brahea Edulis','Ornamentales','Viveros EL OASIS','80 - 100',19.00,15.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (241,'OR-217','Brahea Edulis','Ornamentales','Viveros EL OASIS','140 - 160',64.00,51.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (242,'OR-218','Butia Capitata','Ornamentales','Viveros EL OASIS','70 - 90',25.00,20.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (243,'OR-219','Butia Capitata','Ornamentales','Viveros EL OASIS','90 - 110',29.00,23.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (244,'OR-220','Butia Capitata','Ornamentales','Viveros EL OASIS','90 - 120',36.00,28.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (245,'OR-221','Butia Capitata','Ornamentales','Viveros EL OASIS','85 - 105',59.00,47.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (246,'OR-222','Butia Capitata','Ornamentales','Viveros EL OASIS','130 - 150',87.00,69.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (247,'OR-223','Chamaerops Humilis','Ornamentales','Viveros EL OASIS','40 - 45',4.00,3.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (248,'OR-224','Chamaerops Humilis','Ornamentales','Viveros EL OASIS','50 - 60',7.00,5.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (249,'OR-225','Chamaerops Humilis','Ornamentales','Viveros EL OASIS','70 - 90',10.00,8.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (250,'OR-226','Chamaerops Humilis','Ornamentales','Viveros EL OASIS','115 - 130',38.00,30.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (251,'OR-227','Chamaerops Humilis','Ornamentales','Viveros EL OASIS','130 - 150',64.00,51.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (252,'OR-228','Chamaerops Humilis \"Cerifera\"','Ornamentales','Viveros EL OASIS','70 - 80',32.00,25.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (253,'OR-229','Chrysalidocarpus Lutescens -ARECA','Ornamentales','Viveros EL OASIS','130 - 150',22.00,17.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (254,'OR-230','Cordyline Australis -DRACAENA','Ornamentales','Viveros EL OASIS','190 - 210',38.00,30.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (255,'OR-231','Cycas Revoluta','Ornamentales','Viveros EL OASIS','55 - 65',15.00,12.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (256,'OR-232','Cycas Revoluta','Ornamentales','Viveros EL OASIS','80 - 90',34.00,27.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (257,'OR-233','Dracaena Drago','Ornamentales','Viveros EL OASIS','60 - 70',13.00,10.00,1);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (258,'OR-234','Dracaena Drago','Ornamentales','Viveros EL OASIS','130 - 150',64.00,51.00,2);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (259,'OR-235','Dracaena Drago','Ornamentales','Viveros EL OASIS','150 - 175',92.00,73.00,2);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (260,'OR-236','Jubaea Chilensis','Ornamentales','Viveros EL OASIS','',49.00,39.00,100);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (261,'OR-237','Livistonia Australis','Ornamentales','Viveros EL OASIS','100 - 125',19.00,15.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (262,'OR-238','Livistonia Decipiens','Ornamentales','Viveros EL OASIS','90 - 110',19.00,15.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (263,'OR-239','Livistonia Decipiens','Ornamentales','Viveros EL OASIS','180 - 200',49.00,39.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (264,'OR-240','Phoenix Canariensis','Ornamentales','Viveros EL OASIS','110 - 130',6.00,4.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (265,'OR-241','Phoenix Canariensis','Ornamentales','Viveros EL OASIS','180 - 200',19.00,15.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (266,'OR-242','Rhaphis Excelsa','Ornamentales','Viveros EL OASIS','80 - 100',21.00,16.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (267,'OR-243','Rhaphis Humilis','Ornamentales','Viveros EL OASIS','150- 170',64.00,51.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (268,'OR-244','Sabal Minor','Ornamentales','Viveros EL OASIS','60 - 75',11.00,8.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (269,'OR-245','Sabal Minor','Ornamentales','Viveros EL OASIS','120 - 140',34.00,27.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (270,'OR-246','Trachycarpus Fortunei','Ornamentales','Viveros EL OASIS','90 - 105',18.00,14.00,50);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (271,'OR-247','Trachycarpus Fortunei','Ornamentales','Viveros EL OASIS','250-300',462.00,369.00,2);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (272,'OR-248','Washingtonia Robusta','Ornamentales','Viveros EL OASIS','60 - 70',3.00,2.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (273,'OR-249','Washingtonia Robusta','Ornamentales','Viveros EL OASIS','130 - 150',5.00,4.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (274,'OR-250','Yucca Jewel','Ornamentales','Viveros EL OASIS','80 - 105',10.00,8.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (275,'OR-251','Zamia Furfuracaea','Ornamentales','Viveros EL OASIS','90 - 110',168.00,134.00,15);
INSERT INTO STG_Producto (ID_dim_producto,ID_producto_origen,nombre_producto,categoria,proveedor,dimensiones,precio_venta,precio_proveedor,cantidad_en_stock) VALUES (276,'OR-99','Mimosa DEALBATA Gaulois Astier  ','Ornamentales','Viveros EL OASIS','200-225',14.00,11.00,100);
SET IDENTITY_INSERT STG_Producto OFF;

-- ============================================================
-- DATOS - STG_Empleado
-- ============================================================
SET IDENTITY_INSERT STG_Empleado ON;
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (1,1,'Marcos Maga├â┬▒a Perez','Director General','marcos@jardineria.es','3897',NULL,'TAL-ES','Talavera de la Reina','Espa├â┬▒a','Castilla-LaMancha');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (2,2,'Ruben L├â┬│pez Martinez','Subdirector Marketing','rlopez@jardineria.es','2899','Marcos Maga├â┬▒a Perez','TAL-ES','Talavera de la Reina','Espa├â┬▒a','Castilla-LaMancha');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (3,3,'Alberto Soria Carrasco','Subdirector Ventas','asoria@jardineria.es','2837','Ruben L├â┬│pez Martinez','TAL-ES','Talavera de la Reina','Espa├â┬▒a','Castilla-LaMancha');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (4,4,'Maria Sol├â┬¡s Jerez','Secretaria','msolis@jardineria.es','2847','Ruben L├â┬│pez Martinez','TAL-ES','Talavera de la Reina','Espa├â┬▒a','Castilla-LaMancha');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (5,5,'Felipe Rosas Marquez','Representante Ventas','frosas@jardineria.es','2844','Alberto Soria Carrasco','TAL-ES','Talavera de la Reina','Espa├â┬▒a','Castilla-LaMancha');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (6,6,'Juan Carlos Ortiz Serrano','Representante Ventas','cortiz@jardineria.es','2845','Alberto Soria Carrasco','TAL-ES','Talavera de la Reina','Espa├â┬▒a','Castilla-LaMancha');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (7,7,'Carlos Soria Jimenez','Director Oficina','csoria@jardineria.es','2444','Alberto Soria Carrasco','MAD-ES','Madrid','Espa├â┬▒a','Madrid');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (8,8,'Mariano L├â┬│pez Murcia','Representante Ventas','mlopez@jardineria.es','2442','Carlos Soria Jimenez','MAD-ES','Madrid','Espa├â┬▒a','Madrid');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (9,9,'Lucio Campoamor Mart├â┬¡n','Representante Ventas','lcampoamor@jardineria.es','2442','Carlos Soria Jimenez','MAD-ES','Madrid','Espa├â┬▒a','Madrid');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (10,10,'Hilario Rodriguez Huertas','Representante Ventas','hrodriguez@jardineria.es','2444','Carlos Soria Jimenez','MAD-ES','Madrid','Espa├â┬▒a','Madrid');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (11,11,'Emmanuel Maga├â┬▒a Perez','Director Oficina','manu@jardineria.es','2518','Alberto Soria Carrasco','BCN-ES','Barcelona','Espa├â┬▒a','Barcelona');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (12,12,'Jos├â┬⌐ Manuel Martinez De la Osa','Representante Ventas','jmmart@hotmail.es','2519','Emmanuel Maga├â┬▒a Perez','BCN-ES','Barcelona','Espa├â┬▒a','Barcelona');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (13,13,'David Palma Aceituno','Representante Ventas','dpalma@jardineria.es','2519','Emmanuel Maga├â┬▒a Perez','BCN-ES','Barcelona','Espa├â┬▒a','Barcelona');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (14,14,'Oscar Palma Aceituno','Representante Ventas','opalma@jardineria.es','2519','Emmanuel Maga├â┬▒a Perez','BCN-ES','Barcelona','Espa├â┬▒a','Barcelona');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (15,15,'Francois Fignon','Director Oficina','ffignon@gardening.com','9981','Alberto Soria Carrasco','PAR-FR','Paris','Francia','EMEA');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (16,16,'Lionel Narvaez','Representante Ventas','lnarvaez@gardening.com','9982','Francois Fignon','PAR-FR','Paris','Francia','EMEA');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (17,17,'Laurent Serra','Representante Ventas','lserra@gardening.com','9982','Francois Fignon','PAR-FR','Paris','Francia','EMEA');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (18,18,'Michael Bolton','Director Oficina','mbolton@gardening.com','7454','Alberto Soria Carrasco','SFC-USA','San Francisco','EEUU','CA');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (19,19,'Walter Santiago Sanchez Lopez','Representante Ventas','wssanchez@gardening.com','7454','Michael Bolton','SFC-USA','San Francisco','EEUU','CA');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (20,20,'Hilary Washington','Director Oficina','hwashington@gardening.com','7565','Alberto Soria Carrasco','BOS-USA','Boston','EEUU','MA');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (21,21,'Marcus Paxton','Representante Ventas','mpaxton@gardening.com','7565','Hilary Washington','BOS-USA','Boston','EEUU','MA');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (22,22,'Lorena Paxton','Representante Ventas','lpaxton@gardening.com','7665','Hilary Washington','BOS-USA','Boston','EEUU','MA');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (23,23,'Nei Nishikori','Director Oficina','nnishikori@gardening.com','8734','Alberto Soria Carrasco','TOK-JP','Tokyo','Jap├â┬│n','Chiyoda-Ku');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (24,24,'Narumi Riko','Representante Ventas','nriko@gardening.com','8734','Nei Nishikori','TOK-JP','Tokyo','Jap├â┬│n','Chiyoda-Ku');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (25,25,'Takuma Nomura','Representante Ventas','tnomura@gardening.com','8735','Nei Nishikori','TOK-JP','Tokyo','Jap├â┬│n','Chiyoda-Ku');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (26,26,'Amy Johnson','Director Oficina','ajohnson@gardening.com','3321','Alberto Soria Carrasco','LON-UK','Londres','Inglaterra','EMEA');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (27,27,'Larry Westfalls','Representante Ventas','lwestfalls@gardening.com','3322','Amy Johnson','LON-UK','Londres','Inglaterra','EMEA');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (28,28,'John Walton','Representante Ventas','jwalton@gardening.com','3322','Amy Johnson','LON-UK','Londres','Inglaterra','EMEA');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (29,29,'Kevin Fallmer','Director Oficina','kfalmer@gardening.com','3210','Alberto Soria Carrasco','SYD-AU','Sydney','Australia','APAC');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (30,30,'Julian Bellinelli','Representante Ventas','jbellinelli@gardening.com','3211','Kevin Fallmer','SYD-AU','Sydney','Australia','APAC');
INSERT INTO STG_Empleado (ID_dim_empleado,ID_empleado_origen,nombre_completo,puesto,email,extension,nombre_jefe,oficina_descripcion,oficina_ciudad,oficina_pais,oficina_region) VALUES (31,31,'Mariko Kishi','Representante Ventas','mkishi@gardening.com','3211','Kevin Fallmer','SYD-AU','Sydney','Australia','APAC');
SET IDENTITY_INSERT STG_Empleado OFF;

-- ============================================================
-- DATOS - STG_Pedido
-- ============================================================
SET IDENTITY_INSERT STG_Pedido ON;
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (1,1,'2006-01-19','2006-01-19','Entregado',0,'Pagado a plazos');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (2,2,'2007-10-28','2007-10-26','Entregado',-2,'La entrega llego antes de lo esperado');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (3,3,'2008-06-25',NULL,'Rechazado',NULL,'Limite de credito superado');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (4,4,'2009-01-26',NULL,'Pendiente',NULL,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (5,5,'2008-11-14','2008-11-14','Entregado',0,'El cliente paga la mitad con tarjeta y la otra mitad con efectivo, se le realizan dos facturas');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (6,6,'2008-12-27','2008-12-28','Entregado',1,'El cliente comprueba la integridad del paquete, todo correcto');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (7,7,'2009-01-20',NULL,'Pendiente',NULL,'El cliente llama para confirmar la fecha - Esperando al proveedor');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (8,8,'2009-01-27',NULL,'Pendiente',NULL,'El cliente requiere que el pedido se le entregue de 16:00h a 22:00h');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (9,9,'2009-01-27',NULL,'Pendiente',NULL,'El cliente requiere que el pedido se le entregue de 9:00h a 13:00h');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (10,10,'2009-01-14','2009-01-15','Entregado',1,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (11,11,'2009-01-02',NULL,'Rechazado',NULL,'mal pago');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (12,12,'2009-01-12','2009-01-11','Entregado',-1,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (13,13,'2009-01-07','2009-01-15','Entregado',8,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (14,14,'2009-01-09','2009-01-11','Entregado',2,'mal estado');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (15,15,'2009-01-06','2009-01-07','Entregado',1,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (16,16,'2009-02-12',NULL,'Pendiente',NULL,'entregar en murcia');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (17,17,'2009-02-15',NULL,'Pendiente',NULL,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (18,18,'2009-01-09','2009-01-09','Rechazado',0,'mal pago');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (19,19,'2009-01-11','2009-01-13','Entregado',2,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (20,20,'2009-01-10',NULL,'Rechazado',NULL,'El pedido fue anulado por el cliente');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (21,21,'2008-07-31','2008-07-25','Entregado',-6,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (22,22,'2009-02-08',NULL,'Rechazado',NULL,'El cliente carece de saldo en la cuenta asociada');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (23,23,'2009-02-12',NULL,'Rechazado',NULL,'El cliente anula la operacion para adquirir mas producto');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (24,24,'2009-02-13',NULL,'Entregado',NULL,'El pedido aparece como entregado pero no sabemos en que fecha');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (25,25,'2009-02-17','2009-02-20','Entregado',3,'El cliente se queja bastante de la espera asociada al producto');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (26,26,'2008-09-01','2008-09-01','Rechazado',0,'El cliente no est├â┬í conforme con el pedido');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (27,27,'2008-09-03','2008-08-31','Entregado',-3,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (28,28,'2008-09-30','2008-10-04','Rechazado',4,'El cliente ha rechazado por llegar 5 dias tarde');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (29,29,'2007-01-19','2007-01-27','Entregado',8,'Entrega tardia, el cliente puso reclamacion');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (30,30,'2007-05-28',NULL,'Rechazado',NULL,'El pedido fue anulado por el cliente');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (31,31,'2008-06-28','2008-06-28','Entregado',0,'Pagado a plazos');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (32,32,'2009-03-20',NULL,'Rechazado',NULL,'Limite de credito superado');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (33,33,'2008-12-15','2008-12-10','Entregado',-5,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (34,34,'2009-11-13',NULL,'Pendiente',NULL,'El pedido nunca llego a su destino');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (35,35,'2009-03-06','2009-03-07','Entregado',1,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (36,36,'2009-03-07','2009-03-09','Pendiente',2,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (37,37,'2009-03-10','2009-03-13','Rechazado',3,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (38,38,'2009-03-13','2009-03-13','Entregado',0,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (39,39,'2009-03-23','2009-03-27','Entregado',4,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (40,40,'2009-03-26','2009-03-28','Pendiente',2,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (41,41,'2009-03-27','2009-03-30','Pendiente',3,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (42,42,'2009-03-04','2009-03-07','Entregado',3,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (43,43,'2009-03-04','2009-03-05','Rechazado',1,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (44,44,'2009-03-17','2009-03-17','Entregado',0,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (45,45,'2008-03-30','2008-03-29','Entregado',-1,'Seg├â┬║n el Cliente, el pedido lleg├â┬│ defectuoso');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (46,46,'2008-07-22','2008-07-30','Entregado',8,'El pedido lleg├â┬│ 1 d├â┬¡a tarde, pero no hubo queja por parte de la empresa compradora');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (47,47,'2008-08-09',NULL,'Pendiente',NULL,'Al parecer, el pedido se ha extraviado a la altura de Sotalbo (├â┬üvila)');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (48,48,'2008-10-14','2008-10-14','Entregado',0,'Todo se entreg├â┬│ a tiempo y en perfecto estado, a pesar del p├â┬⌐simo estado de las carreteras.');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (49,49,'2008-12-21',NULL,'Pendiente',NULL,'El transportista ha llamado a Eva Mar├â┬¡a para indicarle que el pedido llegar├â┬í m├â┬ís tarde de lo esperado.');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (50,50,'2008-11-15','2008-11-09','Entregado',-6,'El pedido llega 6 dias antes');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (51,51,'2009-02-11',NULL,'Pendiente',NULL,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (52,52,'2009-01-10','2009-01-11','Entregado',1,'Retrasado 1 dia por problemas de transporte');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (53,53,'2009-01-20',NULL,'Rechazado',NULL,'El cliente a anulado el pedido el dia 2009-01-10');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (54,54,'2009-02-05',NULL,'Pendiente',NULL,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (55,55,'2009-01-31','2009-01-30','Entregado',-1,'Todo correcto');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (56,56,'2008-11-14','2008-11-14','Entregado',0,'El cliente paga la mitad con tarjeta y la otra mitad con efectivo, se le realizan dos facturas');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (57,57,'2008-12-27','2008-12-28','Entregado',1,'El cliente comprueba la integridad del paquete, todo correcto');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (58,58,'2009-01-20',NULL,'Pendiente',NULL,'El cliente llama para confirmar la fecha - Esperando al proveedor');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (59,59,'2009-01-27',NULL,'Pendiente',NULL,'El cliente requiere que el pedido se le entregue de 16:00h a 22:00h');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (60,60,'2009-01-27',NULL,'Pendiente',NULL,'El cliente requiere que el pedido se le entregue de 9:00h a 13:00h');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (61,61,'2009-01-31','2009-01-30','Entregado',-1,'Todo correcto');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (62,62,'2009-02-08',NULL,'Rechazado',NULL,'El cliente carece de saldo en la cuenta asociada');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (63,63,'2009-02-12',NULL,'Rechazado',NULL,'El cliente anula la operacion para adquirir mas producto');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (64,64,'2009-02-13',NULL,'Entregado',NULL,'El pedido aparece como entregado pero no sabemos en que fecha');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (65,65,'2009-02-17','2009-02-20','Entregado',3,'El cliente se queja bastante de la espera asociada al producto');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (66,66,'2009-01-22',NULL,'Rechazado',NULL,'El pedido no llego el dia que queria el cliente por fallo del transporte');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (67,67,'2009-01-13','2009-01-13','Entregado',0,'El pedido llego perfectamente');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (68,68,'2008-11-23','2008-11-23','Entregado',0,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (69,69,'2009-01-08',NULL,'Pendiente',NULL,'El pedido no pudo ser entregado por problemas meteorologicos');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (70,70,'2008-12-17','2008-12-17','Entregado',0,'Fue entregado, pero faltaba mercancia que sera entregada otro dia');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (71,71,'2009-01-13','2009-01-13','Entregado',0,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (72,72,'2009-01-26',NULL,'Pendiente',NULL,'No termin├â┬│ el pago');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (73,73,'2009-01-24',NULL,'Rechazado',NULL,'Los producto estaban en mal estado');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (74,74,'2009-01-29','2009-01-29','Entregado',0,'El pedido llego un poco mas tarde de la hora fijada');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (75,75,'2009-01-28',NULL,'Entregado',NULL,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (76,76,'2007-12-13','2007-12-10','Entregado',-3,'La entrega se realizo dias antes de la fecha esperada por lo que el cliente quedo satisfecho');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (77,77,'2008-02-17',NULL,'Pendiente',NULL,'Debido a la nevada ca├â┬¡da en la sierra, el pedido no podr├â┬í llegar hasta el d├â┬¡a ');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (78,78,'2009-03-29','2009-03-27','Entregado',-2,'Todo se entreg├â┬│ a su debido tiempo, incluso con un d├â┬¡a de antelaci├â┬│n');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (79,79,'2009-04-30','2009-05-03','Entregado',3,'El pedido se entreg├â┬│ tarde debido a la festividad celebrada en Espa├â┬▒a durante esas fechas');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (80,80,'2009-05-30','2009-05-17','Entregado',-13,'El pedido se entreg├â┬│ antes de lo esperado.');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (81,81,'2009-11-01',NULL,'Pendiente',NULL,'El pedido est├â┬í en camino.');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (82,82,'2008-01-19','2008-01-19','Entregado',0,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (83,83,'2008-04-12','2008-04-13','Entregado',1,'La entrega se retraso un dia');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (84,84,'2008-11-25','2008-11-25','Entregado',0,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (85,85,'2009-02-13',NULL,'Pendiente',NULL,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (86,86,'2009-02-27',NULL,'Pendiente',NULL,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (87,87,'2009-01-15','2009-01-15','Entregado',0,'El pedido llego perfectamente');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (88,88,'2009-03-27',NULL,'Rechazado',NULL,'El pedido fue rechazado por el cliente');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (89,89,'2009-01-08','2009-01-08','Entregado',0,'Pago pendiente');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (90,90,'2009-01-20','2009-01-24','Pendiente',4,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (91,91,'2009-03-06','2009-03-06','Entregado',0,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (92,92,'2009-02-20',NULL,'Rechazado',NULL,'el producto ha sido rechazado por la pesima calidad');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (93,93,'2009-05-15','2009-05-20','Pendiente',5,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (94,94,'2009-04-10','2009-04-10','Entregado',0,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (95,95,'2009-04-15','2009-04-15','Entregado',0,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (96,96,'2006-07-28','2006-07-28','Entregado',0,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (97,97,'2007-04-24','2007-04-24','Entregado',0,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (98,98,'2008-03-30','2008-03-30','Entregado',0,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (99,99,'2009-04-06','2009-05-07','Pendiente',31,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (100,100,'2008-11-09','2009-01-09','Rechazado',61,'El producto ha sido rechazado por la tardanza de el envio');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (101,101,'2009-01-29','2009-01-31','Entregado',2,'El envio llego dos dias m├â┬ís tarde debido al mal tiempo');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (102,102,'2009-01-26','2009-02-27','Pendiente',32,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (103,103,'2008-08-01','2008-08-01','Entregado',0,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (104,104,'2008-10-01',NULL,'Rechazado',NULL,'El pedido ha sido rechazado por la acumulacion de pago pendientes del cliente');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (105,105,'2009-02-27',NULL,'Pendiente',NULL,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (106,106,'2009-01-15','2009-01-15','Entregado',0,'El pedido llego perfectamente');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (107,107,'2009-03-27',NULL,'Rechazado',NULL,'El pedido fue rechazado por el cliente');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (108,108,'2009-01-08','2009-01-08','Entregado',0,'Pago pendiente');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (109,109,'2009-04-15','2009-04-15','Entregado',0,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (110,110,'2009-01-20','2009-01-24','Pendiente',4,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (111,111,'2009-03-06','2009-03-06','Entregado',0,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (112,112,'2009-02-20',NULL,'Rechazado',NULL,'el producto ha sido rechazado por la pesima calidad');
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (113,113,'2009-05-15','2009-05-20','Pendiente',5,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (114,114,'2009-04-10','2009-04-10','Entregado',0,NULL);
INSERT INTO STG_Pedido (ID_dim_pedido,ID_pedido_origen,fecha_esperada,fecha_entrega,estado,dias_retraso,comentarios) VALUES (115,115,'2008-12-10','2008-12-29','Rechazado',19,'El pedido ha sido rechazado por el cliente por el retraso en la entrega');
SET IDENTITY_INSERT STG_Pedido OFF;

-- ============================================================
-- DATOS - STG_Ventas
-- ============================================================
SET IDENTITY_INSERT STG_Ventas ON;
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (1,20060117,5,87,8,1,10,70.00,700.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (2,20060117,5,151,8,1,40,4.00,160.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (3,20060117,5,165,8,1,25,4.00,100.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (4,20060117,5,265,8,1,15,19.00,285.00,4);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (5,20060117,5,276,8,1,23,14.00,322.00,5);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (6,20071023,5,57,8,2,3,29.00,87.00,6);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (7,20071023,5,58,8,2,7,8.00,56.00,7);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (8,20071023,5,164,8,2,50,4.00,200.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (9,20071023,5,165,8,2,20,5.00,100.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (10,20071023,5,183,8,2,12,6.00,72.00,5);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (11,20071023,5,251,8,2,67,64.00,4288.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (12,20071023,5,271,8,2,5,462.00,2310.00,4);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (13,20090112,7,104,11,10,5,70.00,350.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (14,20090112,7,114,11,10,30,75.00,2250.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (15,20090112,7,258,11,10,5,64.00,320.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (16,20090109,7,13,11,12,290,1.00,290.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (17,20090106,7,1,11,13,5,14.00,70.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (18,20090106,7,2,11,13,12,14.00,168.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (19,20090106,7,26,11,13,5,100.00,500.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (20,20090108,7,17,11,14,8,11.00,88.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (21,20090108,7,28,11,14,13,57.00,741.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (22,20090105,9,106,11,15,4,13.00,52.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (23,20090105,9,125,11,15,2,6.00,12.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (24,20090105,9,180,11,15,6,10.00,60.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (25,20090105,9,227,11,15,9,10.00,90.00,4);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (26,20090111,9,4,11,19,9,12.00,108.00,5);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (27,20090111,9,39,11,19,6,8.00,48.00,4);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (28,20090111,9,96,11,19,1,32.00,32.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (29,20090111,9,106,11,19,5,13.00,65.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (30,20090111,9,232,11,19,20,4.00,80.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (31,20080714,13,2,30,21,5,14.00,70.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (32,20080714,13,33,30,21,22,4.00,88.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (33,20080714,13,72,30,21,3,8.00,24.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (34,20090207,3,3,22,24,3,15.00,45.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (35,20090207,3,15,22,24,4,7.00,28.00,4);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (36,20090207,3,39,22,24,2,7.00,14.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (37,20090207,3,265,22,24,10,20.00,200.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (38,20090210,3,98,22,25,15,69.00,1035.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (39,20090210,3,112,22,25,4,30.00,120.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (40,20090210,3,117,22,25,10,30.00,300.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (41,20080803,12,125,8,27,22,6.00,132.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (42,20080803,12,126,8,27,22,6.00,132.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (43,20080803,12,210,8,27,40,6.00,240.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (44,20070107,4,104,22,29,4,70.00,280.00,4);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (45,20070107,4,112,22,29,4,28.00,112.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (46,20070107,4,117,22,29,20,31.00,620.00,5);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (47,20070107,4,153,22,29,2,111.00,222.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (48,20070107,4,184,22,29,10,9.00,90.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (49,20070620,4,13,22,31,25,2.00,50.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (50,20070620,4,19,22,31,1,20.00,20.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (51,20070620,4,57,22,31,6,29.00,174.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (52,20081015,13,32,30,33,423,2.00,846.00,4);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (53,20081015,13,45,30,33,120,8.00,960.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (54,20081015,13,238,30,33,212,10.00,2120.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (55,20081015,13,271,30,33,150,462.00,69300.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (56,20090305,18,2,12,35,12,14.00,168.00,4);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (57,20090305,18,65,12,35,55,8.00,440.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (58,20090305,18,189,12,35,3,10.00,30.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (59,20090305,18,205,12,35,36,10.00,360.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (60,20090305,18,249,12,35,72,10.00,720.00,5);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (61,20090312,18,1,12,38,5,14.00,70.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (62,20090312,18,2,12,38,2,14.00,28.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (63,20090322,18,3,12,39,3,12.00,36.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (64,20090322,18,4,12,39,6,12.00,72.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (65,20090401,22,9,30,42,3,1.00,3.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (66,20090401,22,10,30,42,1,1.00,1.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (67,20090415,22,12,30,44,5,1.00,5.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (68,20080317,25,13,9,45,6,1.00,6.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (69,20080317,25,14,9,45,4,1.00,4.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (70,20080712,25,15,9,46,4,7.00,28.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (71,20080712,25,16,9,46,8,7.00,56.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (72,20081001,25,19,9,48,1,18.00,18.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (73,20081001,25,20,9,48,1,25.00,25.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (74,20081001,25,258,9,48,50,64.00,3200.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (75,20081001,25,260,9,48,45,49.00,2205.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (76,20081001,25,261,9,48,50,19.00,950.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (77,20081015,12,249,8,50,12,10.00,120.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (78,20081015,12,250,8,50,15,38.00,570.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (79,20081015,12,251,8,50,44,64.00,2816.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (80,20090124,3,139,22,55,9,7.00,63.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (81,20090124,3,237,22,55,2,266.00,532.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (82,20090124,3,251,22,55,6,64.00,384.00,5);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (83,20090124,3,267,22,55,2,64.00,128.00,4);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (84,20090124,3,271,22,55,1,462.00,462.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (85,20081109,1,153,19,56,1,115.00,115.00,5);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (86,20081109,1,154,19,56,10,18.00,180.00,6);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (87,20081109,1,203,19,56,1,6.00,6.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (88,20081109,1,220,19,56,3,10.00,30.00,4);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (89,20081109,1,231,19,56,4,4.00,16.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (90,20081109,1,274,19,56,3,10.00,30.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (91,20081222,1,89,19,57,6,91.00,546.00,4);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (92,20081222,1,103,19,57,3,49.00,147.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (93,20081222,1,106,19,57,2,13.00,26.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (94,20081222,1,117,19,57,6,9.00,54.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (95,20090120,27,87,5,74,15,70.00,1050.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (96,20090120,27,251,5,74,34,64.00,2176.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (97,20090120,27,271,5,74,42,8.00,336.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (98,20090124,27,10,5,75,60,1.00,60.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (99,20090124,27,109,5,75,24,22.00,528.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (100,20090124,27,181,5,75,46,10.00,460.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (101,20071005,34,13,18,76,250,1.00,250.00,5);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (102,20071005,34,100,18,76,40,22.00,880.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (103,20071005,34,109,18,76,24,22.00,528.00,4);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (104,20071005,34,117,18,76,35,9.00,315.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (105,20071005,34,220,18,76,25,10.00,250.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (106,20090318,26,72,30,78,25,8.00,200.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (107,20090318,26,107,30,78,56,70.00,3920.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (108,20090318,26,181,30,78,42,10.00,420.00,4);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (109,20090318,26,232,30,78,30,4.00,120.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (110,20090419,26,264,30,79,50,6.00,300.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (111,20090503,26,26,30,80,40,100.00,4000.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (112,20090503,26,53,30,80,47,9.00,423.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (113,20090503,26,160,30,80,75,18.00,1350.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (114,20080104,34,251,18,82,34,64.00,2176.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (115,20080320,34,232,18,83,30,4.00,120.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (116,20081228,15,25,5,89,3,32.00,96.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (117,20081228,15,46,5,89,15,7.00,105.00,6);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (118,20081228,15,60,5,89,12,8.00,96.00,4);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (119,20081228,15,86,5,89,5,49.00,245.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (120,20081228,15,109,5,89,4,22.00,88.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (121,20081228,15,181,5,89,8,10.00,80.00,5);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (122,20090302,29,17,30,91,52,11.00,572.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (123,20090302,29,18,30,91,14,13.00,182.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (124,20090302,29,19,30,91,35,18.00,630.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (125,20090406,29,1,30,94,12,14.00,168.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (126,20090406,29,26,30,94,33,100.00,3300.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (127,20090406,29,57,30,94,79,29.00,2291.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (128,20090409,15,16,5,95,9,7.00,63.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (129,20090409,15,96,5,95,6,32.00,192.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (130,20090409,15,104,5,95,5,70.00,350.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (131,20080305,35,50,31,98,14,8.00,112.00,4);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (132,20080305,35,75,31,98,16,8.00,128.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (133,20080305,35,80,31,98,8,32.00,256.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (134,20080305,35,101,31,98,18,6.00,108.00,5);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (135,20080305,35,107,31,98,6,70.00,420.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (136,20090115,35,10,31,101,50,1.00,50.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (137,20090115,35,13,31,101,159,1.00,159.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (138,20090110,15,13,5,106,231,1.00,231.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (139,20090110,15,160,5,106,47,18.00,846.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (140,20081228,15,72,5,108,53,8.00,424.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (141,20081228,15,232,5,108,59,4.00,236.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (142,20090409,15,38,5,109,8,4.00,32.00,5);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (143,20090409,15,53,5,109,12,9.00,108.00,3);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (144,20090409,15,63,5,109,14,8.00,112.00,4);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (145,20090409,15,128,5,109,20,10.00,200.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (146,20090409,15,143,5,109,10,5.00,50.00,2);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (147,20090409,15,149,5,109,3,5.00,15.00,6);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (148,20090409,15,154,5,109,2,18.00,36.00,7);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (149,20081210,13,87,30,52,10,70.00,700.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (150,20090124,1,87,19,61,10,70.00,700.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (151,20090207,3,87,22,64,10,70.00,700.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (152,20090210,3,87,22,65,10,70.00,700.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (153,20090111,14,87,5,67,10,70.00,700.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (154,20081115,14,87,5,68,10,70.00,700.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (155,20090302,29,87,30,111,10,70.00,700.00,1);
INSERT INTO STG_Ventas (ID_hecho,FK_fecha,FK_cliente,FK_producto,FK_empleado,FK_pedido,cantidad,precio_unidad,subtotal,numero_linea) VALUES (156,20090406,29,87,30,114,10,70.00,700.00,1);
SET IDENTITY_INSERT STG_Ventas OFF;


-- ============================================================
-- CONSULTAS DE VERIFICACIÓN DEL BK
-- ============================================================
SELECT 'STG_Fecha'    AS tabla, COUNT(*) AS registros FROM STG_Fecha
UNION ALL
SELECT 'STG_Cliente'  AS tabla, COUNT(*) AS registros FROM STG_Cliente
UNION ALL
SELECT 'STG_Producto' AS tabla, COUNT(*) AS registros FROM STG_Producto
UNION ALL
SELECT 'STG_Empleado' AS tabla, COUNT(*) AS registros FROM STG_Empleado
UNION ALL
SELECT 'STG_Pedido'   AS tabla, COUNT(*) AS registros FROM STG_Pedido
UNION ALL
SELECT 'STG_Ventas'   AS tabla, COUNT(*) AS registros FROM STG_Ventas;
