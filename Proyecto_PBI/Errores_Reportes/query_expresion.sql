
WITH variable AS (
    SELECT
        sseguro,
        MAX(CRESPUE) AS Indice_Variable
    FROM PROD.DWH_PREGUNGARANSEG
    WHERE cpregun = 6124
      AND crespue <> 0
    GROUP BY sseguro
),
polizas_ult_doc AS (
    SELECT *
    FROM (
        SELECT
            TRIM(RAMO_PROD) || '_' || POLIZA::VARCHAR AS LLAVE_POL,
            DOCUMENTO,
            ANEXO,
            RECIBO,
            SMOVREC,
            SUM(VR_ASEG_POLIZA) AS VR_ASEG_POLIZA,
            SUM(VR_PRIMA_ANUAL) AS VR_PRIMA_ANUAL,
            INTERMEDIARIO_LIDE,
            SUCURSAL_EXPE,
            TIPO_IDENTIFI_TOM,
            NRO_IDENTIFI_TOM,
            COD_MODALIDAD,
            ROW_NUMBER() OVER (
                PARTITION BY TRIM(RAMO_PROD) || '_' || POLIZA::VARCHAR
                ORDER BY POLIZA, DOCUMENTO DESC, ANEXO DESC, RECIBO DESC, SMOVREC DESC
            ) AS ult_doc
        FROM Liberty.PROD.DWH_POLIZAS_H
        WHERE PERIODO_CONTABLE > TO_CHAR(DATEADD(month, -14, CURRENT_DATE), 'YYYYMM')::INTEGER
          AND FF_CERTIFICADO BETWEEN (TO_CHAR(DATEADD(month, -1, CURRENT_DATE), 'YYYYMM') || '01')::INTEGER
                                 AND (TO_CHAR(DATEADD(month, 4, CURRENT_DATE), 'YYYYMM') || '31')::INTEGER
          AND RAMO_PROD IN ('70107','70108','8092  ','900742','900745','900746')
        GROUP BY RAMO_PROD, POLIZA, CERTIFICADO, DOCUMENTO, ANEXO, RECIBO, SMOVREC,
                 INTERMEDIARIO_LIDE, SUCURSAL_EXPE, TIPO_IDENTIFI_TOM, NRO_IDENTIFI_TOM, COD_MODALIDAD
    ) M
    WHERE ult_doc = 1
),
vencimientos_detalle AS (
    SELECT
        LEFT(T.FF_CERTIFICADO::VARCHAR, 6) AS PERIODO_VENCIMIENTO,
        TRIM(T.RAMO_PROD) || '_' || T.POLIZA::VARCHAR AS LLAVE_POL,
        TRIM(T.RAMO_PROD) || '_' || T.RIESGO::VARCHAR AS LLAVE_CARATULA,
        TRIM(T.RAMO_PROD) || '_' || T.POLIZA::VARCHAR || '_' || T.RIESGO::VARCHAR AS LLAVE_CERT,
        P.SUCURSAL_EXPE AS SUCURSAL_LIDER,
        TRIM(T.RAMO_PROD) AS RAMO_PROD,
        B.DESC_RAMO_PROD,
        T.POLIZA,
        T.RIESGO AS CERTIFICADOS,
        T.AMPARO,
        CASE
            WHEN TRIM(T.RAMO_PROD) || '_' || T.AMPARO::VARCHAR IN (
                '70107_5485','900742_3042','900731_8047','900742_3039','900742_3036','70107_8044','900745_9883','900745_9884','900742_3124','900742_3130',
                '70107_8046','70107_5454','900742_3022','900742_3014','900745_9944','900742_3028','70107_8040','900742_3149','70107_5459','900731_8044','900742_3037','70107_5463','900745_9969','900742_3012',
                '70107_8047','900742_3131','900745_9922','900742_3013','70107_5461','900742_3035','900742_3122','900731_8045','900746_9849','70107_8048','900742_3027','8092_5402','900745_754','70108_6901',
                '70107_5460','900742_3114','900742_3212','70107_5484','900745_9937','70107_8052','900742_3158','70107_5449','70107_5450','900742_3032','900731_8040','900742_3029','8092_5386','70107_8045',
                '900745_9921'
            ) THEN SUM(T.valor_asegurado)
            ELSE 0
        END AS VR_ASEG_POLIZA,
        SUM(T.VR_PRIMA_ANUAL) AS VR_PRIMA_ANUAL,
        MIN(T.FI_CERTIFICADO) AS FECHA_INI_VIG,
        MAX(T.FF_CERTIFICADO) AS FECHA_FIN_VIG,
        P.INTERMEDIARIO_LIDE AS CLAVE,
        T.documento,
        T.tipo_transaccion,
        T.cod_transaccion,
        T.tipo_transaccion::VARCHAR || '_' || T.cod_transaccion::VARCHAR AS llave_transac,
        CASE WHEN P.TIPO_IDENTIFI_TOM = 'N' THEN 2 ELSE 1 END AS TIPO_IDENTIFI_TOM,
        MAX(P.NRO_IDENTIFI_TOM) AS ID_TOMADOR,
        P.COD_MODALIDAD,
        T.anexo,
        COALESCE(T.RECIBO, 0) AS RECIBO,
        COALESCE(T.SMOVREC, 0) AS SMOVREC,
        'a' AS base,
        MAX(Z.Indice_Variable) AS Indice_Variable
    FROM Liberty.OTH.dwh_detalle_riesgos T
    LEFT JOIN polizas_ult_doc P
        ON TRIM(T.RAMO_PROD) || '_' || T.POLIZA::VARCHAR = P.LLAVE_POL
    LEFT JOIN Liberty.APOYO.DWH_SBU_RAMO_PROD B
        ON TRIM(T.RAMO_PROD) = TRIM(B.RAMO_PROD)
    LEFT JOIN variable Z
        ON T.sseguro = Z.SSEGURO
    WHERE T.PERIODO_CONTABLE > TO_CHAR(DATEADD(month, -14, CURRENT_DATE), 'YYYYMM')::INTEGER
      AND T.sucursal_prod NOT IN (97,27,214,26,199,93)
      AND T.FF_CERTIFICADO BETWEEN (TO_CHAR(DATEADD(month, -1, CURRENT_DATE), 'YYYYMM') || '01')::INTEGER
                               AND (TO_CHAR(DATEADD(month, 4, CURRENT_DATE), 'YYYYMM') || '31')::INTEGER
      AND B.SBU IN ('OTH','BON')
      AND T.RAMO_PROD NOT IN ('411','IF','01','BO','10002','10004','10005','JU','900748','900731')
      AND T.VR_PRIMA_ANUAL > 0
    GROUP BY T.RAMO_PROD, T.POLIZA, T.RIESGO, T.AMPARO, P.SUCURSAL_EXPE, B.DESC_RAMO_PROD,
             P.INTERMEDIARIO_LIDE, P.TIPO_IDENTIFI_TOM, T.documento, T.anexo, T.RECIBO, T.SMOVREC,
             P.VR_ASEG_POLIZA, P.VR_PRIMA_ANUAL, T.tipo_transaccion, T.cod_transaccion,
             LEFT(T.FF_CERTIFICADO::VARCHAR, 6), P.COD_MODALIDAD

    UNION

    SELECT
        LEFT(T.FF_CERTIFICADO::VARCHAR, 6) AS PERIODO_VENCIMIENTO,
        TRIM(T.RAMO_PROD) || '_' || T.POLIZA::VARCHAR AS LLAVE_POL,
        TRIM(T.RAMO_PROD) || '_' || T.CERTIFICADO::VARCHAR AS LLAVE_CARATULA,
        TRIM(T.RAMO_PROD) || '_' || T.POLIZA::VARCHAR || '_' || T.CERTIFICADO::VARCHAR AS LLAVE_CERT,
        T.SUCURSAL_EXPE AS SUCURSAL_LIDER,
        TRIM(T.RAMO_PROD) AS RAMO_PROD,
        B.DESC_RAMO_PROD,
        T.POLIZA,
        T.CERTIFICADO AS CERTIFICADOS,
        0 AS AMPARO,
        SUM(T.VR_ASEG_POLIZA) AS VR_ASEG_POLIZA,
        SUM(T.VR_PRIMA_ANUAL) AS VR_PRIMA_ANUAL,
        MIN(T.FI_CERTIFICADO) AS FECHA_INI_VIG,
        MAX(T.FF_CERTIFICADO) AS FECHA_FIN_VIG,
        MAX(T.INTERMEDIARIO_LIDE) AS CLAVE,
        T.documento,
        T.TIPO_TRANSAC AS tipo_transaccion,
        T.cod_transac AS cod_transaccion,
        T.tipo_transac::VARCHAR || '_' || T.cod_transac::VARCHAR AS llave_transac,
        CASE WHEN T.TIPO_IDENTIFI_TOM = 'N' THEN 2 ELSE 1 END AS TIPO_IDENTIFI_TOM,
        MAX(T.NRO_IDENTIFI_TOM) AS ID_TOMADOR,
        T.COD_MODALIDAD,
        T.anexo,
        COALESCE(T.RECIBO, 0) AS RECIBO,
        COALESCE(T.SMOVREC, 0) AS SMOVREC,
        'b' AS base,
        MAX(Z.Indice_Variable) AS Indice_Variable
    FROM Liberty.PROD.dwh_polizas_h T
    LEFT JOIN Liberty.APOYO.DWH_SBU_RAMO_PROD B
        ON TRIM(T.RAMO_PROD) = TRIM(B.RAMO_PROD)
    LEFT JOIN variable Z
        ON T.sseguro = Z.SSEGURO
    WHERE T.PERIODO_CONTABLE > TO_CHAR(DATEADD(month, -14, CURRENT_DATE), 'YYYYMM')::INTEGER
      AND T.sucursal_prod NOT IN (97,27,214,26,199,93)
      AND T.FF_CERTIFICADO BETWEEN (TO_CHAR(DATEADD(month, -1, CURRENT_DATE), 'YYYYMM') || '01')::INTEGER
                               AND (TO_CHAR(DATEADD(month, 4, CURRENT_DATE), 'YYYYMM') || '31')::INTEGER
      AND B.SBU IN ('OTH','BON')
      AND T.RAMO_PROD NOT IN ('411','IF','70107','70108','8092  ','900742','900745','900746','01','BO','10002','10004','10005','JU','900748')
      AND TRIM(T.RAMO_PROD) || '_' || T.cod_producto::VARCHAR <> 'LB_1'
    GROUP BY T.RAMO_PROD, T.POLIZA, T.CERTIFICADO, T.SUCURSAL_EXPE, B.DESC_RAMO_PROD,
             T.documento, T.anexo, T.RECIBO, T.SMOVREC, T.TIPO_TRANSAC, T.cod_transac,
             LEFT(T.FF_CERTIFICADO::VARCHAR, 6), T.COD_MODALIDAD, T.TIPO_IDENTIFI_TOM
),
vencimientos AS (
    SELECT
        P.PERIODO_VENCIMIENTO,
        P.LLAVE_POL,
        P.LLAVE_CARATULA,
        P.LLAVE_CERT,
        P.SUCURSAL_LIDER,
        P.RAMO_PROD,
        P.DESC_RAMO_PROD,
        P.POLIZA,
        COUNT(DISTINCT P.CERTIFICADOS) AS CERTIFICADOS,
        SUM(P.VR_ASEG_POLIZA) AS VR_ASEG_POLIZA,
        SUM(P.VR_PRIMA_ANUAL) AS VR_PRIMA_ANUAL,
        P.FECHA_INI_VIG,
        P.FECHA_FIN_VIG,
        P.CLAVE,
        P.documento,
        P.tipo_transaccion,
        P.cod_transaccion,
        P.llave_transac,
        P.TIPO_IDENTIFI_TOM,
        P.ID_TOMADOR,
        P.COD_MODALIDAD,
        P.anexo,
        P.RECIBO,
        P.SMOVREC,
        P.base,
        MAX(P.Indice_Variable) AS Indice_Variable
    FROM vencimientos_detalle P
    GROUP BY P.PERIODO_VENCIMIENTO, P.CERTIFICADOS, P.LLAVE_POL, P.LLAVE_CARATULA, P.LLAVE_CERT,
             P.SUCURSAL_LIDER, P.RAMO_PROD, P.DESC_RAMO_PROD, P.POLIZA, P.FECHA_INI_VIG,
             P.FECHA_FIN_VIG, P.CLAVE, P.documento, P.tipo_transaccion, P.cod_transaccion,
             P.llave_transac, P.TIPO_IDENTIFI_TOM, P.ID_TOMADOR, P.COD_MODALIDAD, P.anexo,
             P.RECIBO, P.SMOVREC, P.base
),
vencimientos_ordenados AS (
    SELECT
        M.*,
        ROW_NUMBER() OVER (
            PARTITION BY M.LLAVE_CERT
            ORDER BY M.LLAVE_CERT, M.DOCUMENTO DESC, M.anexo DESC, M.recibo DESC, M.SMOVREC DESC
        ) AS ult_doc
    FROM vencimientos M
),
vencimientos_unicos AS (
    SELECT
        PERIODO_VENCIMIENTO,
        LLAVE_POL AS LLAVE,
        SUCURSAL_LIDER,
        A.RAMO_PROD,
        DESC_RAMO_PROD,
        POLIZA,
        A.COD_MODALIDAD::VARCHAR || '_' || C.DESC_MODALIDAD AS MODALIDAD,
        COUNT(DISTINCT LLAVE_CERT) AS CERTIFICADOS,
        SUM(VR_ASEG_POLIZA) AS VALOR_ASEGURADO_POLIZA,
        SUM(VR_PRIMA_ANUAL) AS PRIMA_POLIZA,
        MIN(FECHA_INI_VIG) AS FECHA_INI_VIG,
        MAX(FECHA_FIN_VIG) AS FECHA_FIN_VIG,
        MAX(CLAVE) AS CLAVE,
        B.RAZON_SOCIAL AS RAZON_SOCIAL_INTERMEDIARIO,
        MAX(TIPO_IDENTIFI_TOM) AS TIPO_IDENTIFI_TOM,
        MAX(ID_TOMADOR) AS ID_TOMADOR,
        MAX(A.Indice_Variable) AS Indice_Variable
    FROM vencimientos_ordenados A
    LEFT JOIN Liberty.APOYO.dwh_intermediarios_total B
        ON B.cod_intermediario = A.CLAVE
    LEFT JOIN Liberty.APOYO.DWH_MODALIDADES C
        ON A.ramo_prod = C.ramo_prod
       AND A.cod_modalidad = C.cod_modalidad
    WHERE ult_doc = 1
      AND tipo_transaccion <> 4
      AND llave_transac NOT IN ('8_224','8_241','8_242','8_514','8_664','9_221','9_242','9_322','9_514')
    GROUP BY PERIODO_VENCIMIENTO, LLAVE_POL, SUCURSAL_LIDER, A.RAMO_PROD, DESC_RAMO_PROD,
             POLIZA, A.COD_MODALIDAD, C.DESC_MODALIDAD, B.RAZON_SOCIAL
),
siniestros AS (
    SELECT
        TRIM(A.RAMO_PROD) || '_' || A.POLIZA::VARCHAR AS LLAVE_POL,
        A.LLAVE_SIN,
        A.AMPARO,
        CASE WHEN A.SIS_ORIGEN = 'O' THEN D.DESC_SUBAMPARO ELSE E.DESCRIPCION END AS DES_AMPARO,
        A.SUBAMPARO,
        SUM(A.VR_NOVEDAD) AS Incurrido,
        A.RAMO_PROD,
        A.POLIZA,
        B.ANNO_SINIESTRO
    FROM Liberty.SINI.DWH_S_NOV_CONT_D A
    LEFT JOIN Liberty.SINI.DWH_S_MAESTRO_D B
        ON A.LLAVE_SIN = B.LLAVE_SIN
    LEFT JOIN Liberty.APOYO.DWH_SBU_RAMO_PROD C
        ON TRIM(A.RAMO_PROD) = TRIM(C.RAMO_PROD)
    LEFT JOIN Liberty.APOYO.DWH_S_AMPARO D
        ON A.RAMO_PROD = D.RAMO_PROD
       AND A.AMPARO = D.AMPARO
       AND A.SUBAMPARO = D.SUBAMPARO
    LEFT JOIN Liberty.APOYO.DWH_DESC_AMPARO E
        ON A.AMPARO = E.AMPARO
    WHERE C.SBU IN ('OTH','BON')
      AND C.RAMO_PROD NOT IN ('411','IF','01','BO','10002','10004','10005','JU','900748')
      AND B.ANNO_SINIESTRO >= EXTRACT(year FROM CURRENT_DATE)::INTEGER - 2
      AND A.TIPO_NOVEDAD NOT IN (5,6)
    GROUP BY A.LLAVE_SIN, A.AMPARO, A.RAMO_PROD, A.POLIZA, B.ANNO_SINIESTRO,
             A.SUBAMPARO, A.SIS_ORIGEN, D.DESC_SUBAMPARO, E.DESCRIPCION
),
amparos AS (
    SELECT
        LLAVE_POL,
        LISTAGG(DISTINCT DES_AMPARO, ',_,') WITHIN GROUP (ORDER BY DES_AMPARO) AS amparos
    FROM siniestros
    GROUP BY LLAVE_POL
),
incurridos AS (
    SELECT
        S.LLAVE_POL,
        SUM(CASE WHEN S.ANNO_SINIESTRO = 2020 THEN S.Incurrido ELSE 0 END) AS "2020",
        SUM(CASE WHEN S.ANNO_SINIESTRO = 2021 THEN S.Incurrido ELSE 0 END) AS "2021",
        SUM(CASE WHEN S.ANNO_SINIESTRO = 2022 THEN S.Incurrido ELSE 0 END) AS "2022",
        SUM(CASE WHEN S.ANNO_SINIESTRO = 2023 THEN S.Incurrido ELSE 0 END) AS "2023",
        A.amparos
    FROM siniestros S
    LEFT JOIN amparos A
        ON S.LLAVE_POL = A.LLAVE_POL
    GROUP BY S.LLAVE_POL, A.amparos
),
poliza_lider AS (
    SELECT RAMO_PROD, POLIZA, POLIZA_LIDER
    FROM (
        SELECT
            M.RAMO_PROD,
            M.POLIZA,
            M.NRO_LIDER AS POLIZA_LIDER,
            ROW_NUMBER() OVER (
                PARTITION BY M.RAMO_PROD, M.POLIZA
                ORDER BY M.RAMO_PROD, M.POLIZA DESC, M.documento DESC
            ) AS ult_doc
        FROM Liberty.APOYO.DWH_POLIZAS_PRODUCTO_MODULAR M
    ) P
    WHERE P.ult_doc = 1
),
vencimientos_base AS (
    SELECT
        A.PERIODO_VENCIMIENTO,
        A.LLAVE,
        A.SUCURSAL_LIDER,
        A.RAMO_PROD,
        A.DESC_RAMO_PROD,
        A.POLIZA,
        A.CERTIFICADOS,
        A.VALOR_ASEGURADO_POLIZA,
        A.PRIMA_POLIZA,
        A.FECHA_INI_VIG,
        A.FECHA_FIN_VIG,
        A.CLAVE,
        A.RAZON_SOCIAL_INTERMEDIARIO,
        A.ID_TOMADOR,
        MAX(D.nombre) AS TOMADOR,
        A.MODALIDAD,
        B."2020",
        B."2021",
        B."2022",
        B."2023",
        B.amparos,
        ''::VARCHAR AS OBSERVACIONES,
        ''::VARCHAR AS ESTADO,
        A.Indice_Variable,
        CASE
            WHEN A.ramo_prod IN ('410','900754','463','6071','900748','900758','10001','10000','462','10003') THEN 'Grupo Hogar'
            WHEN A.SUCURSAL_LIDER IN (14,18,19,45,119) THEN 'Grupo I'
            WHEN A.SUCURSAL_LIDER IN (47,87,94,95,220,221,234) THEN 'Grupo II'
            WHEN A.SUCURSAL_LIDER IN (12,15,17,88,143,177,222) THEN 'Grupo III'
            WHEN A.SUCURSAL_LIDER IN (9,11,13,16,21,42,46,49,118,124,125,171) THEN 'Grupo IV'
        END AS GRUPO,
        A.PRIMA_POLIZA / NULLIF(A.CERTIFICADOS, 0) AS PRIMA_PROMEDIO,
        C.POLIZA_LIDER
    FROM vencimientos_unicos A
    LEFT JOIN incurridos B
        ON A.LLAVE = B.LLAVE_POL
    LEFT JOIN poliza_lider C
        ON A.RAMO_PROD = C.RAMO_PROD
       AND A.POLIZA = C.POLIZA
    LEFT JOIN Liberty_Pruebas_Actuaria.dbo.DIM_Persona D
        ON A.ID_TOMADOR = D.ID
       AND A.TIPO_IDENTIFI_TOM = D.tipo_persona
    GROUP BY A.PERIODO_VENCIMIENTO, A.LLAVE, A.SUCURSAL_LIDER, A.RAMO_PROD, A.DESC_RAMO_PROD,
             A.POLIZA, A.CERTIFICADOS, A.VALOR_ASEGURADO_POLIZA, A.PRIMA_POLIZA,
             A.FECHA_INI_VIG, A.FECHA_FIN_VIG, A.CLAVE, A.RAZON_SOCIAL_INTERMEDIARIO,
             A.ID_TOMADOR, A.MODALIDAD, B."2020", B."2021", B."2022", B."2023",
             B.amparos, C.POLIZA_LIDER, A.Indice_Variable
),
conteos AS (
    SELECT
        periodo_vencimiento,
        SUCURSAL_LIDER,
        CLAVE,
        GRUPO,
        COUNT(LLAVE) AS vencimientos,
        ROW_NUMBER() OVER (
            PARTITION BY periodo_vencimiento, SUCURSAL_LIDER, GRUPO
            ORDER BY COUNT(LLAVE)
        ) AS indice
    FROM vencimientos_base
    GROUP BY periodo_vencimiento, SUCURSAL_LIDER, CLAVE, GRUPO
),
distribucion AS (
    SELECT
        periodo_vencimiento,
        sucursal_lider,
        clave,
        GRUPO,
        vencimientos,
        CASE
            WHEN grupo = 'Grupo Hogar' THEN 'Analista ' || ((indice % 2) + 1)::VARCHAR || '_' || GRUPO
            WHEN grupo = 'Grupo I' THEN 'Analista ' || ((indice % 3) + 1)::VARCHAR || '_' || GRUPO
            WHEN grupo = 'Grupo II' THEN 'Analista ' || ((indice % 3) + 1)::VARCHAR || '_' || GRUPO
            WHEN grupo = 'Grupo III' THEN 'Analista ' || ((indice % 4) + 1)::VARCHAR || '_' || GRUPO
            WHEN grupo = 'Grupo IV' THEN 'Analista ' || ((indice % 2) + 1)::VARCHAR || '_' || GRUPO
        END AS analista
    FROM conteos
)
SELECT
    P.*,
    CASE
        WHEN P.GRUPO = 'Grupo Hogar' AND P.SUCURSAL_LIDER IN (9,12,18,42,47,118,221,234) THEN 'david.sanguinetti'
        WHEN P.GRUPO = 'Grupo Hogar' THEN 'german.vargas'
        WHEN P.GRUPO = 'Grupo I' AND Q.ANALISTA = 'Analista 1_Grupo I' THEN 'marco.rodriguez'
        WHEN P.GRUPO = 'Grupo I' AND Q.ANALISTA = 'Analista 2_Grupo I' THEN 'francisco.florez'
        WHEN P.GRUPO = 'Grupo I' AND Q.ANALISTA = 'Analista 3_Grupo I' THEN 'mario.marin'
        WHEN P.GRUPO = 'Grupo II' AND Q.ANALISTA = 'Analista 1_Grupo II' THEN 'fredya.ortiz'
        WHEN P.GRUPO = 'Grupo II' AND Q.ANALISTA = 'Analista 2_Grupo II' THEN 'angelica.toledo'
        WHEN P.GRUPO = 'Grupo II' AND Q.ANALISTA = 'Analista 3_Grupo II' THEN 'fabio.cardenas'
        WHEN P.GRUPO = 'Grupo III' AND Q.ANALISTA = 'Analista 1_Grupo III' THEN 'edgar.lopez'
        WHEN P.GRUPO = 'Grupo III' AND Q.ANALISTA = 'Analista 2_Grupo III' THEN 'marllobis.cabrera'
        WHEN P.GRUPO = 'Grupo III' AND Q.ANALISTA = 'Analista 3_Grupo III' THEN 'daisy.castro'
        WHEN P.GRUPO = 'Grupo III' AND Q.ANALISTA = 'Analista 4_Grupo III' THEN 'anyela.doncels'
        WHEN P.GRUPO = 'Grupo IV' AND Q.ANALISTA = 'Analista 1_Grupo IV' THEN 'cecilia.quinteroq'
        WHEN P.GRUPO = 'Grupo IV' AND Q.ANALISTA = 'Analista 2_Grupo IV' THEN 'nelson.bedoya'
        ELSE 'VALIDAR'
    END AS ANALISTA
FROM vencimientos_base P
LEFT JOIN distribucion Q
    ON P.PERIODO_VENCIMIENTO = Q.PERIODO_VENCIMIENTO
   AND P.CLAVE = Q.CLAVE
   AND P.GRUPO = Q.GRUPO
   AND P.SUCURSAL_LIDER = Q.SUCURSAL_LIDER
WHERE P.PERIODO_VENCIMIENTO = ?