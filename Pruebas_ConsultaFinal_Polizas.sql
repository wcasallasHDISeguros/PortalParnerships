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
    ),
    comision_base AS (
	    SELECT
	        car.sseguro,
	        car.npoliza,
	        car.ncertif,
	        car.sproduc,
	        car.fefecto,
	        car.cagente,
	        car.cramo,
	        car.cmodali,
	        car.ctipseg,
	        car.ccolect,
	        car.cactivi,
	        car.cidioma,
	        car.ctipcom,
	        car.ctipretr,
	        CASE WHEN EXISTS (
	                SELECT 1
	                FROM gde_adp_ods.axis_movseguro ms
	                WHERE ms.sseguro = car.sseguro
	                  AND ms.cmovseg = 2
	                  AND ms.cmotmov = 404
	            ) THEN 2
	            ELSE 1
	        END AS cmodcom
	    FROM gde_adp_ods.axis_seguros car
    ) 
select * from comision_base  
    


