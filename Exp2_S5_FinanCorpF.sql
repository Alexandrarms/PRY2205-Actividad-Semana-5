/*
PRY2205 - CONSULTA DE BASES DE DATOS
ACTIVIDAD FORMATIVA - SEMANA 5
Caso: Gestión de clientes y productos financieros - FinanCorp

Estudiante: 
-- Alexandra Martínez
-- Nicole Ortega
*/


/* ============================================================
   CASO 1
   ============================================================ */

SELECT
    TO_CHAR(
        c.numrun,
        'FM999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) || '-' || c.dvrun AS "RUT Cliente",
    INITCAP(c.pnombre || ' ' || c.appaterno) AS "Nombre Cliente",
    UPPER(po.nombre_prof_ofic) AS "Profesión u Oficio",
    TO_CHAR(c.fecha_inscripcion, 'DD-MM-YYYY') AS "Fecha Inscripción",
    INITCAP(c.direccion) AS "Dirección Cliente"
FROM cliente c
    INNER JOIN tipo_cliente tc
        ON c.cod_tipo_cliente = tc.cod_tipo_cliente
    INNER JOIN profesion_oficio po
        ON c.cod_prof_ofic = po.cod_prof_ofic
WHERE tc.cod_tipo_cliente = 10
  AND UPPER(po.nombre_prof_ofic) IN ('CONTADOR', 'VENDEDOR')
  AND EXTRACT(YEAR FROM c.fecha_inscripcion) >
      (
          SELECT ROUND(AVG(EXTRACT(YEAR FROM fecha_inscripcion)))
          FROM cliente
      )
ORDER BY c.numrun ASC;


/* ============================================================
   CASO 2
   ============================================================ */

CREATE TABLE CLIENTES_CUPOS_COMPRA AS
SELECT
    TO_CHAR(
        c.numrun,
        'FM999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) || '-' || c.dvrun AS "RUT Cliente",
    TRUNC(
        MONTHS_BETWEEN(SYSDATE, c.fecha_nacimiento) / 12
    ) AS "Edad Cliente",
    '$' || TO_CHAR(
        ROUND(tar.cupo_disp_compra, 0),
        'FM999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "Cupo Disponible Compras"
FROM cliente c
    INNER JOIN tarjeta_cliente tar
        ON c.numrun = tar.numrun
WHERE tar.cupo_disp_compra >=
      (
          SELECT MAX(tar_ant.cupo_disp_compra)
          FROM tarjeta_cliente tar_ant
          WHERE EXTRACT(YEAR FROM tar_ant.fecha_solic_tarjeta) =
                EXTRACT(YEAR FROM SYSDATE) - 1
      );


/* Consulta final para presentar los resultados ordenados por edad. */

SELECT
    "RUT Cliente",
    "Edad Cliente",
    "Cupo Disponible Compras"
FROM CLIENTES_CUPOS_COMPRA
ORDER BY "Edad Cliente" ASC;
