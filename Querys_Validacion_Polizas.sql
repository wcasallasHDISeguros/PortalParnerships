WITH primas AS (
SELECT 
TO_CHAR(car.fefecto,'YYYY-MM-DD') fecha_inicio_car,
TO_CHAR (nvl(Axis.pac_isqlfor_lcol.F_FVENCIM(car.sseguro, 'POL',NULL),sysdate),'YYYY-MM-DD') fecha_vencimiento_car,
TO_CHAR(car.FEMISIO ,'YYYY-MM-DD') fecha_emision_car,
decode(pp_tom.ctipide , 24, 'P.P',33, 'C.E',34,'Tarjeta identidad',35,'Registro civil',36,'C.C',37,'NIT',38,'N.U.I.P',40,'Pasaporte',43,'BIC',44,'Carnet Diplomático',45,'NIT E.',46,'Permiso especial de permanencia',47,'PECP',99,'Identificador simulaciones', 0, 'Identificiacion del sistema', 48, 'P.P.T') as tipo_identomador,
pp_tom.NNUMIDE as inden_tomador,
Axis.pac_isqlfor.f_dades_persona(pp_tom.sperson, 4, 8, 'POL')||' '||Axis.pac_isqlfor.f_dades_persona(pp_tom.sperson, 5, 8, 'POL') tom_nombres,
car.NPOLIZA num_poliza,
(case when to_CHAR(car.sproduc) in('10024','900742','LGP','900746','900747','900774','900776','900751','22','2') then 'EMP'
when to_CHAR(car.sproduc) in('900753','6031','6048','6033','6034','6047','6039','6042','6046','6049','6045','6043','6035','6038','6041','6036') then 'AUT'
when to_CHAR(car.sproduc) in ('6071','10003','900758','10001','10000')then 'HOG'
WHEN to_CHAR(car.SPRODUC) IN('7469','6023','6025','900720','6026','900719','6024','6028','7468','7467','6029','900721','6052')then 'VID'
WHEN to_CHAR(car.SPRODUC) IN ('E1','ADU','Z1','H1','SE','T1')then 'SAL'
WHEN to_CHAR(car.SPRODUC) IN ('BO','LB','10004','10005','1') THEN 'CUM'
WHEN to_CHAR(car.SPRODUC) IN ('TRC','10','70107','70108','900731','TRM','900777','8092','900778')THEN 'TRA'
WHEN to_CHAR(car.SPRODUC) IN ('DO1','LA1','111715','900775','900752','RCL','RCM','REO','RCP')THEN 'RCE'
WHEN to_CHAR(car.SPRODUC) IN ('900745','19','900779','17')THEN 'ING'
WHEN to_CHAR(car.SPRODUC) IN ('900730') THEN 'SOA'
END ) as agrupacion,
Axis.ff_desvalorfijo(61, 8, car.csituac) estado_caratula,
(CASE WHEN NVL (Axis.f_parproductos_v (car.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
'C'
ELSE 'I' END) tipo_poliza, 
--substr(Axis.pac_redcomercial.f_busca_padre(12,car.cagente,NULL,sysdate),length(Axis.pac_redcomercial.f_busca_padre(12,car.cagente,NULL,sysdate))-2,3)||'-'||Axis.ff_desagente(Axis.pac_redcomercial.f_busca_padre(12,car.cagente,NULL,sysdate)) sucursal
car.cagente as agente,
axis.f_por_comi_financiero (car.sseguro, null, car.fefecto, car.cagente, null, 'POL', null) comision,
axis.f_desproducto_t(car.cramo, car.cmodali, car.ctipseg, car.ccolect, 1, 8)  des_producto,
COALESCE((
    SELECT CASE
             WHEN Axis.ff_desvalorfijo(61, 8, cer.csituac) = 'Vigente'
             THEN t2.cantidad_cert
             ELSE 0
           END
    FROM (
            SELECT npoliza,
                   COUNT(*) cantidad_cert
            FROM axis.seguros WHERE ncertif <> 0
            GROUP BY npoliza
         ) t2
    WHERE car.npoliza = t2.npoliza
),0) AS num_certificado,
pp.trespue AS nro_cotizacion,
cer.ncertif certif_asegurado,
(SELECT nvl(sum(nvl(V.itotalr,0)),0) prima_total
 FROM AXIS.RECIBOS R
 LEFT JOIN AXIS.VDETRECIBOS V ON R.nrecibo = V.nrecibo
 WHERE R.sseguro = car.sseguro) prima_total_car,
car.sseguro as seguro,
car.cramo as codramo,
car.sproduc as producto,
DECODE(Axis.pac_preguntas.f_get_pregunpolseg_resp(car.sseguro,6117,'POL'),-1,'',Axis.pac_preguntas.f_get_pregunpolseg_resp(car.sseguro,6117,'POL')) modalidad,
1 as newcore,
r.TRAMO ramo,
TO_CHAR(car.FEMISIO ,'YYYY')  ano_periodo_contable_car,
TO_CHAR(car.FEMISIO ,'MM')  mes_periodo_contable_car,
Axis.F_SEGPRIMA2(car.sseguro, sysdate) prima_emitida_car,
axis.pac_isqlfor.f_dades_persona(aseg_cer.sperson, 1, 8, 'POL')  inden_asegurado,
decode(pp_aseg.ctipide , 24, 'P.P',33, 'C.E',34,'Tarjeta identidad',35,'Registro civil',36,'C.C',37,'NIT',38,'N.U.I.P',40,'Pasaporte',43,'BIC',44,'Carnet Diplomático',45,'NIT E.',46,'Permiso especial de permanencia',47,'PECP',99,'Identificador simulaciones', 0, 'Identificiacion del sistema', 48, 'P.P.T') 
  tipo_idenasegurado,
axis.pac_isqlfor.f_dades_persona(aseg_cer.sperson, 4, 8, 'POL')||' '||axis.pac_isqlfor.f_dades_persona(aseg_cer.sperson, 5, 8, 'POL')  aseg_nombres,
cer.sseguro sseguro_cert,
Axis.ff_desvalorfijo(61, 8, cer.csituac) estado_certif,
TO_CHAR(cer.fefecto,'YYYY-MM-DD') fecha_inicio_cer,
TO_CHAR (nvl(Axis.pac_isqlfor_lcol.F_FVENCIM(cer.sseguro, 'POL',NULL),sysdate),'YYYY-MM-DD') fecha_vencimiento_cer,
TO_CHAR(cer.FEMISIO ,'YYYY-MM-DD') fecha_emision_cer,
TO_CHAR(cer.FEMISIO ,'YYYY') ano_periodo_contable_cer,
TO_CHAR(cer.FEMISIO ,'MM') mes_periodo_contable_cer,
AXIS.F_SEGPRIMA2(cer.sseguro, sysdate) prima_emitida_cer,
(SELECT nvl(sum(nvl(V.itotalr,0)),0) prima_total
 FROM Axis.RECIBOS R
 LEFT JOIN Axis.VDETRECIBOS V ON R.nrecibo = V.nrecibo
 WHERE R.sseguro = cer.sseguro) prima_total_cer,
(SELECT LISTAGG (Axis.F_DESRIESGO_T_DWH(sseguro,nriesgo,sysdate,8) , '**RIES:') WITHIN GROUP (
    ORDER BY Axis.F_DESRIESGO_T_DWH(sseguro,nriesgo,sysdate,8) ) FROM Axis.riesgos WHERE sseguro=cer.sseguro) riesgos,
decode(cer.cramo,104,Axis.PAC_IAX_SERVICIOS_EXPRESS.f_estado_poliza(cer.sseguro),'')estado_renovacion,
(CASE WHEN car.cramo=701 or car.sproduc in (900730,7447,10005) then 0 else 1 end) pdf,
to_char(sysdate,'YYYY-MM-DD') fecha_ejecucion_dwh ,
Axis.ff_desvalorfijo(16, 8, mov_cer.CMOVSEG) tipo_transaccion,
(
    SELECT CASE
             WHEN Axis.ff_desvalorfijo(61, 8, cer.csituac) = 'Vigente'
             THEN t2.cantidad_riesgos
             ELSE 0
           END
    FROM (
            SELECT sseguro,
                   COUNT(*) cantidad_riesgos
            FROM axis.riesgos
            GROUP BY sseguro
         ) t2
    WHERE car.sseguro = t2.sseguro
) conteo_riesgos,
ar.cversion AS cod_fasecolda
FROM Axis.seguros car
INNER JOIN Axis.ramos r ON r.CRAMO=car.CRAMO AND r.CIDIOMA =8
INNER JOIN Axis.TOMADORES t ON t.sseguro=car.sseguro
INNER JOIN Axis.PER_PERSONAS pp_tom ON pp_tom.SPERSON=t.SPERSON
INNER JOIN Axis.seguros cer ON cer.npoliza=car.npoliza 
INNER JOIN Axis.movseguro mov_cer ON mov_cer.SSEGURO=cer.SSEGURO AND mov_cer.NMOVIMI = (SELECT max(nmovimi) FROM Axis.movseguro m2 WHERE m2.sseguro=cer.sseguro AND m2.CMOVSEG <> 52)
LEFT JOIN Axis.asegurados aseg_cer ON aseg_cer.SSEGURO =cer.sseguro
LEFT JOIN Axis.PER_PERSONAS pp_aseg ON pp_aseg.SPERSON=aseg_cer.SPERSON
LEFT JOIN Axis.AUTRIESGOS ar ON aseg_cer.SSEGURO =ar.sseguro
LEFT JOIN Axis.pregunpolseg pp ON aseg_cer.SSEGURO = pp.sseguro AND pp.cpregun = 795
WHERE car.sproduc in (6025) 
and pp_tom.nnumide= '9003542594'
AND car.npoliza IN (2395)
AND car.ncertif=0
ORDER BY
    car.npoliza,
    cer.ncertif ASc
)
SELECT * FROM primas



---Query de Polizas migrado a Redshift
WITH
/* =====================================================================
   1. RED COMERCIAL VIGENTE
      Equivalente a F_BUSCA_PADRE cuando pctipage IS NULL
   ===================================================================== */
redcomercial_vigente AS (
    SELECT
        rc.cagente,
        rc.cempres,
        rc.cpadre,
        rc.fmovini,
        rc.fmovfin,
        rc.fmodifi,
        ROW_NUMBER() OVER (
            PARTITION BY rc.cagente, rc.cempres
            ORDER BY
                rc.fmovini DESC,
                rc.fmodifi DESC
        ) AS rn
    FROM gde_adp_ods.axis_redcomercial rc
    WHERE rc.cempres = 12
      AND rc.fmovini <= CURRENT_TIMESTAMP
      AND (
            rc.fmovfin > CURRENT_TIMESTAMP
            OR rc.fmovfin IS NULL
          )
),
/* =====================================================================
   2. ÚLTIMO REGISTRO DEL AGENTE
      Equivalente al fallback de F_BUSCA_PADRE
   ===================================================================== */
redcomercial_ultimo AS (
    SELECT
        rc.cagente,
        rc.cpadre,
        rc.fmodifi,
        ROW_NUMBER() OVER (
            PARTITION BY rc.cagente
            ORDER BY
                rc.fmodifi DESC
        ) AS rn
    FROM gde_adp_ods.axis_redcomercial rc
),
/* =====================================================================
   3. LISTA DE AGENTES QUE NECESITAMOS
      Agentes obtenidos dinámicamente desde AXIS_SEGUROS
      para los productos requeridos y certificados de carátula.
   ===================================================================== */
agentes_consulta AS (
    SELECT DISTINCT
        car.cagente
    FROM gde_adp_ods.axis_seguros car
    WHERE car.sproduc IN (900730,10024,900747,6031,6042,6041,6043,6044,6045,6046,6047,6048,
        6049,6032,6033,6034,6035,6038,6039,6024,6025,809,6023,6026,6027,6028,6029,6030,6052,
        7467,70106,8201,8202,8203,8204,8205,8206,8207,8208,8209,8210,8211,900748,10004,10011,
        900753,10012,10013,10014,10015,10016,10017,10018,10019,10003,6071,900731,900758,10020,10001,
        10000,900719,10021,10022,10023,111715,10002,7469,900745,900720,70107,900744,7452,807,808,
        10009,7468,900755,900759,900762,900774,900776,900775,900778,900777,900779,900771,900746,900742)
    AND car.ncertif = 0
),
/* =====================================================================
   4. F_BUSCA_PADRE
   ===================================================================== */
padre_agente AS (
    SELECT
        ac.cagente,
        COALESCE(
            rv.cpadre,
            ru.cpadre
        ) AS cpadre
    FROM agentes_consulta ac
    LEFT JOIN redcomercial_vigente rv
        ON rv.cagente = ac.cagente
       AND rv.rn = 1
    LEFT JOIN redcomercial_ultimo ru
        ON ru.cagente = ac.cagente
       AND ru.rn = 1
),
/* =====================================================================
   5. F_DESAGENTE
      F_DESAGENTE(cpadre)

      SELECT f_nombre(sperson,1,NULL)
      FROM agentes
      WHERE cagente = cpadre
   ===================================================================== */
desagente_base AS (
    SELECT
        pa.cagente,
        pa.cpadre,
        ag.sperson AS sperson_agente
    FROM padre_agente pa
    LEFT JOIN gde_adp_ods.axis_agentes ag
    	ON ag.cagente = pa.cpadre
),
/* =====================================================================
   6. F_NOMBRE - PERSONA PÚBLICA
      Primera ruta de F_NOMBRE:

          swpubli = 1
          pd.cagente = p.cagente
   ===================================================================== */
nombre_publico AS (
    SELECT
        db.cagente,
        db.cpadre,
        db.sperson_agente,
        TRIM(pd.tapelli1) AS tapelli1,
        TRIM(pd.tapelli2) AS tapelli2,
        TRIM(pd.tnombre) AS tnombre,
        p.nnumide,
        ROW_NUMBER() OVER (
            PARTITION BY db.cagente
            ORDER BY
                pd.fmovimi DESC NULLS LAST
        ) AS rn
    FROM desagente_base db
    INNER JOIN gde_adp_ods.axis_per_personas p
        ON p.sperson = db.sperson_agente
       AND p.swpubli = 1
    INNER JOIN gde_adp_ods.axis_per_detper pd
        ON pd.sperson = p.sperson
       AND pd.cagente = p.cagente
),
/* * =====================================================================
   7. F_NOMBRE - PERSONA NO PÚBLICA
      Segunda ruta.

      Oracle:

          pd.cagente = FF_AGENTEPROD()

      Aquí FF_AGENTEPROD depende del contexto Oracle.
      
      Para Redshift dejamos parametrizado el agente de producción.

      >>> CAMBIAR  POR EL CAGENTE DE PRODUCCIÓN REAL SI APLICA.
   ===================================================================== */
nombre_no_publico AS (
    SELECT
        db.cagente,
        db.cpadre,
        db.sperson_agente,
        TRIM(pd.tapelli1) AS tapelli1,
        TRIM(pd.tapelli2) AS tapelli2,
        TRIM(pd.tnombre) AS tnombre,
        p.nnumide,
        ROW_NUMBER() OVER (
            PARTITION BY db.cagente
            ORDER BY
                pd.fmovimi DESC NULLS LAST
        ) AS rn
    FROM desagente_base db
    INNER JOIN gde_adp_ods.axis_per_personas p
        ON p.sperson = db.sperson_agente
       AND p.swpubli = 0
    INNER JOIN gde_adp_ods.axis_per_detper pd
        ON pd.sperson = p.sperson

       /*
          FF_AGENTEPROD()

          Si conoces el agente de producción de la ejecución,
          reemplazar NULL por ese valor:

          AND pd.cagente = <AGENTE_PRODUCCION>

          Por ahora no forzamos un agente.
       */
),
/* =====================================================================
   8. F_NOMBRE - PERSONA GENERAL
      Tercera ruta de Oracle:

          FROM personas
          WHERE sperson = psperson
   ===================================================================== */
nombre_persona AS (
    SELECT
        db.cagente,
        db.cpadre,
        db.sperson_agente,
        --TRIM(p.tapelli1) AS tapelli1,
        --TRIM(p.tapelli2) AS tapelli2,
        --TRIM(p.tnombre) AS tnombre,
        --p.nnumnif AS nnumide,
        'DUMMY' AS tapelli1,
        'PERSONA' AS tapelli2,
        'PERSONA_' || CAST(db.sperson_agente AS VARCHAR) AS tnombre,
        CAST(NULL AS VARCHAR(50)) AS nnumide,
        ROW_NUMBER() OVER (
            PARTITION BY db.cagente
            ORDER BY db.sperson_agente
        ) AS rn
    FROM desagente_base db
    --INNER JOIN gde_adp_ods.axis_personas p
        --ON p.sperson = db.sperson_agente
),
/* =====================================================================
   9. TAPENOM
      F_NOMBRE primero construye el nombre y posteriormente:

          SELECT tapenom
          FROM per_detper_ce
          WHERE sperson = psperson

      Si existe TAPENOM, reemplaza el nombre construido.
   ===================================================================== */
tapenom AS (    
    /*SELECT
        ce.sperson,
        TRIM(ce.tapenom) AS tapenom,

        ROW_NUMBER() OVER (
            PARTITION BY ce.sperson
            ORDER BY ce.sperson
        ) AS rn
    FROM gde_adp_ods.axis_per_detper_ce ce
    WHERE ce.tapenom IS NOT NULL*/

    SELECT
        CAST(NULL AS BIGINT) AS sperson,
        CAST(NULL AS VARCHAR(500)) AS tapenom,
        CAST(NULL AS INTEGER) AS rn
    WHERE 1 = 0
),
/* =====================================================================
   10. CONSOLIDAR F_NOMBRE
   ===================================================================== */
nombre_agente AS (
    SELECT
        db.cagente,
        db.cpadre,
        db.sperson_agente,
        CASE
            /* =========================================================
               TAPENOM tiene prioridad
               ========================================================= */
            WHEN tn.tapenom IS NOT NULL THEN
                tn.tapenom
            /* =========================================================
               Persona pública
               ========================================================= */
            WHEN np.sperson_agente IS NOT NULL THEN
                CASE
                    WHEN np.tnombre IS NULL THEN
                        TRIM(
                            COALESCE(np.tapelli1, '') ||
                            CASE
                                WHEN np.tapelli2 IS NOT NULL
                                THEN ' ' || np.tapelli2
                                ELSE ''
                            END
                        )
                    ELSE
                        TRIM(
                            COALESCE(np.tapelli1, '') ||
                            CASE
                                WHEN np.tapelli2 IS NOT NULL
                                THEN ' ' || np.tapelli2
                                ELSE ''
                            END ||
                            ', ' ||
                            np.tnombre
                        )
                END
            /* =========================================================
               Persona no pública
               ========================================================= */
            WHEN nnp.sperson_agente IS NOT NULL THEN
                CASE
                    WHEN nnp.tnombre IS NULL THEN
                        TRIM(
                            COALESCE(nnp.tapelli1, '') ||
                            CASE
                                WHEN nnp.tapelli2 IS NOT NULL
                                THEN ' ' || nnp.tapelli2
                                ELSE ''
                            END
                        )
                    ELSE
                        TRIM(
                            COALESCE(nnp.tapelli1, '') ||
                            CASE
                                WHEN nnp.tapelli2 IS NOT NULL
                                THEN ' ' || nnp.tapelli2
                                ELSE ''
                            END ||
                            ', ' ||
                            nnp.tnombre
                        )
                END
            /* =========================================================
               Tabla PERSONAS
               ========================================================= */
            WHEN per.sperson_agente IS NOT NULL THEN
                CASE
                    WHEN per.tnombre IS NULL THEN
                        TRIM(
                            COALESCE(per.tapelli1, '') ||
                            CASE
                                WHEN per.tapelli2 IS NOT NULL
                                THEN ' ' || per.tapelli2
                                ELSE ''
                            END
                        )
                    ELSE
                        TRIM(
                            COALESCE(per.tapelli1, '') ||
                            CASE
                                WHEN per.tapelli2 IS NOT NULL
                                THEN ' ' || per.tapelli2
                                ELSE ''
                            END ||
                            ', ' ||
                            per.tnombre
                        )
                END
            ELSE
                '**'
        END AS nombre_agente
    FROM desagente_base db
    LEFT JOIN nombre_publico np
        ON np.cagente = db.cagente
       AND np.rn = 1
    LEFT JOIN nombre_no_publico nnp
        ON nnp.cagente = db.cagente
       AND nnp.rn = 1
    LEFT JOIN nombre_persona per
        ON per.cagente = db.cagente
       AND per.rn = 1
    LEFT JOIN tapenom tn
        ON tn.sperson = db.sperson_agente
       AND tn.rn = 1
),
/* =====================================================================
   11. SUCURSAL FINAL
   ===================================================================== */
sucursal_agente AS (
    SELECT
        na.cagente,
        na.cpadre,
        CASE
            WHEN na.cpadre IS NULL THEN
                NULL
            ELSE
                RIGHT(
                    CAST(na.cpadre AS VARCHAR(30)),
                    3
                )
                || '-'
                || COALESCE(
                    na.nombre_agente,
                    '**'
                )
        END AS sucursal
    FROM nombre_agente na
),
/* ================================================================
   PRIMA TOTAL POR CERTIFICADO
   ================================================================ */
prima_certificado AS (
    SELECT
        s.sseguro,
        s.npoliza,
        s.sproduc,
        s.ncertif,
        SUM(
            CASE
                WHEN d.cconcep = 0
                THEN COALESCE(d.iconcep_monpol, 0)
                ELSE 0
            END
        ) AS prima_emitida,
        SUM(
            CASE
                WHEN d.cconcep IN (4,90,88,86,14)
                THEN COALESCE(d.iconcep_monpol, 0)
                ELSE 0
            END
        ) AS impuestos
    FROM gde_adp_ods.axis_seguros s
    INNER JOIN gde_adp_ods.axis_recibos r
        ON r.sseguro = s.sseguro
    INNER JOIN gde_adp_ods.axis_detrecibos d
        ON d.nrecibo = r.nrecibo
    WHERE s.ncertif >= 0
    GROUP BY
        s.sseguro,
        s.npoliza,
        s.sproduc,
        s.ncertif
),
/* ================================================================
   FECHA FIN VIGENCIA
   Equivalente a PAC_ISQLFOR_LCOL.F_FVENCIM(psseguro)
   ================================================================ */
seguros_vigencia AS (
    SELECT
        s.sseguro,
        s.sproduc,
        s.fefecto,
        s.nrenova,
        s.fcaranu,
        s.fvencim,
        p.cduraci,

        /* ============================================================
           Pregunta 4778:
           Se toma la respuesta del último movimiento
           ============================================================ */
        preg4778.crespue AS crespue_4778,

        /* ============================================================
           Fecha de nacimiento del primer asegurado
           ============================================================ */
        aseg.fnacimi AS fnacimi_asegurado

    FROM gde_adp_ods.axis_seguros s

    INNER JOIN gde_adp_ods.axis_productos p
        ON p.sproduc = s.sproduc

    /* ================================================================
       Última respuesta de la pregunta 4778
       ================================================================ */
    LEFT JOIN (
        SELECT
            x.sseguro,
            x.crespue,
            ROW_NUMBER() OVER (
                PARTITION BY x.sseguro
                ORDER BY x.nmovimi DESC
            ) AS rn
        FROM gde_adp_ods.axis_pregunpolseg x
        WHERE x.cpregun = 4778
    ) preg4778
        ON preg4778.sseguro = s.sseguro
       AND preg4778.rn = 1

    /* ================================================================
       Primer asegurado
       a.norden = 1

       Se utiliza solamente como fallback cuando:
       fvencim IS NULL
       y no existe pregunta 4778.
       ================================================================ */
    LEFT JOIN (
        SELECT
            a.sseguro,
            pper.fnacimi,
            ROW_NUMBER() OVER (
                PARTITION BY a.sseguro
                ORDER BY a.norden
            ) AS rn
        FROM gde_adp_ods.axis_asegurados a
        INNER JOIN gde_adp_ods.axis_per_personas pper
            ON pper.sperson = a.sperson
        WHERE a.norden = 1
    ) aseg
        ON aseg.sseguro = s.sseguro
       AND aseg.rn = 1
),
fecha_fin_vigencia AS (
    SELECT
        sv.sseguro,
        CASE
            /* ========================================================
               1. PRODUCTO ANUAL
               Oracle:
                   IF vcduraci = 0
               ======================================================== */
            WHEN sv.cduraci = 0 THEN
                /* ----------------------------------------------------
                   Si seguros.fcaranu existe, se utiliza directamente.
                   Oracle:
                       SELECT s.fcaranu
                       ...
                       IF fvencim IS NULL THEN ...
                   ---------------------------------------------------- */
                COALESCE(
                    sv.fcaranu,
                    /* ------------------------------------------------
                       Equivalente a:

                       vdd := SUBSTR(
                                  LPAD(nrenova,4,0),
                                  3,
                                  2
                              );

                       F_SUMMESES(
                           fefecto,
                           12,
                           vdd
                       )
                       ------------------------------------------------ */
                    DATEADD(
                        day,
                        LEAST(
                            CAST(
                                SUBSTRING(
                                    LPAD(
                                        CAST(COALESCE(sv.nrenova, 0) AS VARCHAR),
                                        4,
                                        '0'
                                    ),
                                    3,
                                    2
                                ) AS INTEGER
                            ),
                            EXTRACT(
                                day FROM LAST_DAY(
                                    DATEADD(
                                        month,
                                        12,
                                        sv.fefecto
                                    )
                                )
                            )::INTEGER
                        ) - 1,
                        DATE_TRUNC(
                            'month',
                            DATEADD(
                                month,
                                12,
                                sv.fefecto
                            )
                        )
                    )
                )
            /* ========================================================
               2. PRODUCTO NO ANUAL
               Oracle:

               SELECT TO_DATE(crespue,'yyyymmdd')
               FROM pregunpolseg
               WHERE cpregun = 4778
               ...
               ======================================================== */
            ELSE
                COALESCE(
                    /* ------------------------------------------------
                       Primera prioridad:
                       pregunta 4778
                       ------------------------------------------------ */
                    CASE
                        WHEN sv.crespue_4778 IS NOT NULL
                        THEN TO_DATE(
                            sv.crespue_4778,
                            'YYYYMMDD'
                        )
                    END,
                    /* ------------------------------------------------
                       Segunda prioridad:
                       seguros.fvencim
                       ------------------------------------------------ */
                    sv.fvencim,
                    /* ------------------------------------------------
                       Tercera prioridad:

                       ADD_MONTHS(
                           p.fnacimi,
                           1200
                       )

                       100 años
                       ------------------------------------------------ */
                    DATEADD(
                        month,
                        1200,
                        sv.fnacimi_asegurado
                    )
                )
        END AS fecha_fin_vigencia
   FROM seguros_vigencia sv
),
/*Campos que estan en Select principal y se deben manejar con consultas independientes para evitar duplicidad de datos*/
tomador_detalle AS (
    SELECT
        pd.sperson,
        pd.tapelli1,
        pd.tapelli2,
        pd.tnombre1,
        ROW_NUMBER() OVER (
            PARTITION BY pd.sperson
            ORDER BY pd.fmovimi DESC NULLS LAST
        ) AS rn
    FROM gde_adp_ods.axis_per_detper pd
),
cotizacion_certificado AS (
    SELECT
        a.sseguro,
        pp.trespue,
        ROW_NUMBER() OVER (
            PARTITION BY a.sseguro
            ORDER BY pp.nmovimi DESC NULLS LAST
        ) AS rn
    FROM gde_adp_ods.axis_asegurados a
    INNER JOIN gde_adp_ods.axis_pregunpolseg pp
        ON pp.sseguro = a.sseguro
       AND pp.cpregun = 795
),
ultimo_movimiento AS (
    SELECT
        m.sseguro,
        m.cmovseg,
        ROW_NUMBER() OVER (
            PARTITION BY m.sseguro
            ORDER BY m.nmovimi DESC
        ) AS rn
    FROM gde_adp_ods.axis_movseguro m
    WHERE m.cmovseg <> 52
)   
/* =====================================================================
   CONSULTA PRINCIPAL
   ===================================================================== */
SELECT
    TO_CHAR(
        car.fefecto,
        'YYYY-MM-DD'
    ) AS fecha_inicio_vigencia,
    TO_CHAR(
        ffv.fecha_fin_vigencia,
        'YYYY-MM-DD'
    ) AS fecha_fin_vigencia,
    TO_CHAR(
        car.femisIO,
        'YYYY-MM-DD'
    ) AS fecha_emision,
    /* ================================================================
       TIPO DOCUMENTO
       ================================================================ */
    CASE pp_tom.ctipide
        WHEN 24 THEN 'P.P'
        WHEN 33 THEN 'C.E'
        WHEN 34 THEN 'Tarjeta identidad'
        WHEN 35 THEN 'Registro civil'
        WHEN 36 THEN 'C.C'
        WHEN 37 THEN 'NIT'
        WHEN 38 THEN 'N.U.I.P'
        WHEN 40 THEN 'Pasaporte'
        WHEN 43 THEN 'BIC'
        WHEN 44 THEN 'Carnet Diplomático'
        WHEN 45 THEN 'NIT E.'
        WHEN 46 THEN 'Permiso especial de permanencia'
        WHEN 47 THEN 'PECP'
        WHEN 99 THEN 'Identificador simulaciones'
        WHEN 0 THEN 'Identificiacion del sistema'
        WHEN 48 THEN 'P.P.T'
    END AS tipo_documento,
    pp_tom.nnumide AS numero_identificacion_tomador,
    /* ================================================================
       NOMBRE TOMADOR
       ================================================================ */
    TRIM(
        COALESCE(per_det.tapelli1, '') ||
        CASE
            WHEN per_det.tapelli2 IS NOT NULL
            THEN ' ' || TRIM(per_det.tapelli2)
            ELSE ''
        END ||
        CASE
            WHEN per_det.tnombre1 IS NOT NULL
            THEN ' ' || TRIM(per_det.tnombre1)
            ELSE ''
        END
    ) AS nombre_tomador,
    car.npoliza AS numero_poliza,
    /* ================================================================
       RAMO
       ================================================================ */
    CASE
        WHEN CAST(car.sproduc AS VARCHAR) IN (
            '10024','900742','LGP','900746','900747',
            '900774','900776','900751','22','2'
        )
        THEN 'EMP'
        WHEN CAST(car.sproduc AS VARCHAR) IN (
            '900753','6031','6048','6033','6034','6047',
            '6039','6042','6046','6049','6045','6043',
            '6035','6038','6041','6036'
        )
        THEN 'AUT'
        WHEN CAST(car.sproduc AS VARCHAR) IN (
            '6071','10003','900758','10001','10000'
        )
        THEN 'HOG'
        WHEN CAST(car.sproduc AS VARCHAR) IN (
            '7469','6023','6025','900720','6026',
            '900719','6024','6028','7468','7467',
            '6029','900721','6052'
        )
        THEN 'VID'
        WHEN CAST(car.sproduc AS VARCHAR) IN (
            'E1','ADU','Z1','H1','SE','T1'
        )
        THEN 'SAL'
        WHEN CAST(car.sproduc AS VARCHAR) IN (
            'BO','LB','10004','10005','1'
        )
        THEN 'CUM'
        WHEN CAST(car.sproduc AS VARCHAR) IN (
            'TRC','10','70107','70108','900731',
            'TRM','900777','8092','900778'
        )
        THEN 'TRA'
        WHEN CAST(car.sproduc AS VARCHAR) IN (
            'DO1','LA1','111715','900775','900752',
            'RCL','RCM','REO','RCP'
        )
        THEN 'RCE'
        WHEN CAST(car.sproduc AS VARCHAR) IN (
            '900745','19','900779','17'
        )
        THEN 'ING'
        WHEN CAST(car.sproduc AS VARCHAR) IN (
            '900730'
        )
        THEN 'SOA'
    END AS ramo,
    dv_car.tatribu AS estado,
    NULL AS vistag,
    /* ================================================================
       TIPO POLIZA
       ================================================================ */
    CASE
        WHEN LOWER(
            CAST(car.sproduc AS VARCHAR)
        ) IN (
            '7469','900753','6023','6025','10024',
            '6048','900720','6026','e1','lgp','6047',
            'adu','900747','6024','6042','6046','z1',
            '6029','900774','6049','6045','6043',
            '6041','h1','6071','10003','900752',
            '900731','trm'
        )
        THEN 'C'
        ELSE 'I'
    END AS tipo_poliza,
    /* ================================================================
       SUCURSAL
       ================================================================ */
    sa.sucursal AS sucursal,
    /* ================================================================
       INTERMEDIARIO
       ================================================================ */
    car.cagente AS intermediario,
    /* ================================================================
       RIESGOS VIGENTES
       ================================================================ */
    CASE
        WHEN 1 = 1 THEN tp.ttitulo
        WHEN 1 = 2 THEN tp.trotulo
    END AS riesgos_vigentes,
    /* ================================================================
       RIESGOS
       ================================================================ */
    COALESCE(
        CASE
            WHEN dv.tatribu = 'Vigente'
            THEN t2.cantidad_cert
            ELSE 0
        END,
        0
    ) AS riesgos,
    cc.trespue AS nro_cotizacion,
    cer.ncertif AS certificado_asegurado,
    COALESCE(pc.prima_emitida, 0) AS prima_emitida,
    COALESCE(pc.impuestos, 0) AS impuestos,
    COALESCE(pc.prima_emitida, 0) + COALESCE(pc.impuestos, 0) AS prima_total,
    car.sseguro AS sseguro_caratula,
    cer.sseguro AS sseguro_certificado,
    car.sproduc,
    TO_CHAR(
        cer.fefecto,
        'YYYY-MM-DD'
    ) AS fecha_inicio_certificado,
    TO_CHAR(
        cer.femisio,
        'YYYY-MM-DD'
    ) AS fecha_emision_certificado,
    dv.tatribu AS estado_certificado,
    mov_cer.cmovseg AS ultimo_movimiento_certificado
FROM gde_adp_ods.axis_seguros car
INNER JOIN gde_adp_ods.axis_ramos r
    ON r.cramo = car.cramo
   AND r.cidioma = 8
INNER JOIN gde_adp_ods.axis_tomadores t
    ON t.sseguro = car.sseguro
INNER JOIN gde_adp_ods.axis_per_personas pp_tom
    ON pp_tom.sperson = t.sperson
INNER JOIN gde_adp_ods.axis_seguros cer
    ON cer.npoliza = car.npoliza
INNER JOIN ultimo_movimiento mov_cer
    ON mov_cer.sseguro = cer.sseguro
   AND mov_cer.rn = 1
INNER JOIN tomador_detalle per_det
    ON per_det.sperson = t.sperson
   AND per_det.rn = 1
LEFT JOIN cotizacion_certificado cc
    ON cc.sseguro = cer.sseguro
   AND cc.rn = 1
--LEFT JOIN gde_adp_ods.axis_per_personas pp_aseg
--    ON pp_aseg.sperson = aseg_cer.sperson
--LEFT JOIN gde_adp_ods.axis_autriesgos ar
--    ON aseg_cer.sseguro = ar.sseguro
LEFT JOIN gde_adp_ods.axis_pregunpolseg pp
    ON cc.sseguro = pp.sseguro
   AND pp.cpregun = 795
LEFT JOIN gde_adp_ods.axis_detvalores dv
    ON dv.cvalor = 61
   AND dv.cidioma = 8
   AND dv.catribu = cer.csituac
LEFT JOIN gde_adp_ods.axis_detvalores dv_car
    ON dv_car.cvalor = 61
   AND dv_car.cidioma = 8
   AND dv_car.catribu = car.csituac
LEFT JOIN (
    SELECT
        npoliza,
        COUNT(*) AS cantidad_cert
    FROM gde_adp_ods.axis_seguros
    WHERE ncertif <> 0
    GROUP BY npoliza
) t2
    ON car.npoliza = t2.npoliza
LEFT JOIN gde_adp_ods.axis_titulopro tp
    ON tp.ctipseg = car.ctipseg
   AND tp.cramo = car.cramo
   AND tp.cmodali = car.cmodali
   AND tp.ccolect = car.ccolect
   AND tp.cidioma = 8
/* ================================================================
  FECHA FIN VIGENCIA
   ================================================================ */
LEFT JOIN fecha_fin_vigencia ffv
    ON ffv.sseguro = car.sseguro   
/* ================================================================
   SUCURSAL
   ================================================================ */
LEFT JOIN sucursal_agente sa
    ON sa.cagente = car.cagente
/* ================================================================
   PRIMA TOTAL   
================================================================ */
LEFT JOIN prima_certificado pc
    ON pc.sseguro = cer.sseguro
WHERE car.sproduc IN ('6025')
AND car.npoliza IN (2395)
AND car.ncertif = 0
and pp_tom.nnumide=9003542594
ORDER BY
    car.npoliza,
    cer.ncertif ASC;                    



