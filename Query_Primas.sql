-------------------------------------------------------------------------------
-----------------------------------PRIMAS--------------------------------------
-------------------------------------------------------------------------------

WITH primas AS (
SELECT car.sseguro as seguro,car.cramo as codramo,car.cagente as agente,car.sproduc as producto,
(CASE WHEN NVL (f_parproductos_v (car.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
'C'
ELSE 'I' END) tipo_poliza, 

DECODE(pac_preguntas.f_get_pregunpolseg_resp(car.sseguro,6117,'POL'),-1,'',pac_preguntas.f_get_pregunpolseg_resp(car.sseguro,6117,'POL')) modalidad,
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
1 as newcore,
pp_tom.NNUMIDE as inden_tomador,
decode(pp_tom.ctipide , 24, 'P.P',33, 'C.E',34,'Tarjeta identidad',35,'Registro civil',36,'C.C',37,'NIT',38,'N.U.I.P',40,'Pasaporte',43,'BIC',44,'Carnet Diplomático',45,'NIT E.',46,'Permiso especial de permanencia',47,'PECP',99,'Identificador simulaciones', 0, 'Identificiacion del sistema', 48, 'P.P.T') as tipo_identomador,
pac_isqlfor.f_dades_persona(pp_tom.sperson, 4, 8, 'POL')||' '||pac_isqlfor.f_dades_persona(pp_tom.sperson, 5, 8, 'POL') tom_nombres,
r.TRAMO ramo,
COALESCE((
    SELECT CASE
             WHEN ff_desvalorfijo(61, 8, cer.csituac) = 'Vigente'
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
car.NPOLIZA num_poliza,
ff_desvalorfijo(61, 8, car.csituac) estado_caratula,
substr(pac_redcomercial.f_busca_padre(12,car.cagente,NULL,sysdate),length(pac_redcomercial.f_busca_padre(12,car.cagente,NULL,sysdate))-2,3)||'-'||ff_desagente(pac_redcomercial.f_busca_padre(12,car.cagente,NULL,sysdate)) sucursal,
TO_CHAR(car.fefecto,'YYYY-MM-DD') fecha_inicio_car,
TO_CHAR (nvl(pac_isqlfor_lcol.F_FVENCIM(car.sseguro, 'POL',NULL),sysdate),'YYYY-MM-DD') fecha_vencimiento_car,
TO_CHAR(car.FEMISIO ,'YYYY-MM-DD') fecha_emision_car,
TO_CHAR(car.FEMISIO ,'YYYY')  ano_periodo_contable_car,
TO_CHAR(car.FEMISIO ,'MM')  mes_periodo_contable_car,
F_SEGPRIMA2(car.sseguro, sysdate) prima_emitida_car,
(SELECT nvl(sum(nvl(V.itotalr,0)),0) prima_total --Este campo se debe obtener del SP de Hugo
 FROM RECIBOS R
 LEFT JOIN VDETRECIBOS V ON R.nrecibo = V.nrecibo
 WHERE R.sseguro = car.sseguro) prima_total_car,
f_por_comi_financiero (car.sseguro, null, car.fefecto, car.cagente, null, 'POL', null) comision,
f_desproducto_t(car.cramo, car.cmodali, car.ctipseg, car.ccolect, 1, 8)  des_producto,
pac_isqlfor.f_dades_persona(aseg_cer.sperson, 1, 8, 'POL')  inden_asegurado,
decode(pp_aseg.ctipide , 24, 'P.P',33, 'C.E',34,'Tarjeta identidad',35,'Registro civil',36,'C.C',37,'NIT',38,'N.U.I.P',40,'Pasaporte',43,'BIC',44,'Carnet Diplomático',45,'NIT E.',46,'Permiso especial de permanencia',47,'PECP',99,'Identificador simulaciones', 0, 'Identificiacion del sistema', 48, 'P.P.T') 
  tipo_idenasegurado,
pac_isqlfor.f_dades_persona(aseg_cer.sperson, 4, 8, 'POL')||' '||pac_isqlfor.f_dades_persona(aseg_cer.sperson, 5, 8, 'POL')  aseg_nombres,
cer.ncertif certif_asegurado,
cer.sseguro sseguro_cert,
PAC_AUTOS.f_get_cmatric(cer.sseguro,'POL') placa,
ff_desvalorfijo(61, 8, cer.csituac) estado_certif,
TO_CHAR(cer.fefecto,'YYYY-MM-DD') fecha_inicio_cer,
TO_CHAR (nvl(pac_isqlfor_lcol.F_FVENCIM(cer.sseguro, 'POL',NULL),sysdate),'YYYY-MM-DD') fecha_vencimiento_cer,
TO_CHAR(cer.FEMISIO ,'YYYY-MM-DD') fecha_emision_cer,
TO_CHAR(cer.FEMISIO ,'YYYY') ano_periodo_contable_cer,
TO_CHAR(cer.FEMISIO ,'MM') mes_periodo_contable_cer,
F_SEGPRIMA2(cer.sseguro, sysdate) prima_emitida_cer,
(SELECT nvl(sum(nvl(V.itotalr,0)),0) prima_total
 FROM RECIBOS R
 LEFT JOIN VDETRECIBOS V ON R.nrecibo = V.nrecibo
 WHERE R.sseguro = cer.sseguro) prima_total_cer,
(SELECT LISTAGG (F_DESRIESGO_T_DWH(sseguro,nriesgo,sysdate,8) , '**RIES:') WITHIN GROUP (
    ORDER BY F_DESRIESGO_T_DWH(sseguro,nriesgo,sysdate,8) ) FROM riesgos WHERE sseguro=cer.sseguro) riesgos,
decode(cer.cramo,104,PAC_IAX_SERVICIOS_EXPRESS.f_estado_poliza(cer.sseguro),'')estado_renovacion,
(CASE WHEN car.cramo=701 or car.sproduc in (900730,7447,10005) then 0 else 1 end) pdf,
to_char(sysdate,'YYYY-MM-DD') fecha_ejecucion_dwh ,
ff_desvalorfijo(16, 8, mov_cer.CMOVSEG) tipo_transaccion,
(
    SELECT CASE
             WHEN ff_desvalorfijo(61, 8, cer.csituac) = 'Vigente'
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
pp.trespue AS nro_cotizacion,
ar.cversion AS cod_fasecolda
FROM seguros car
INNER JOIN ramos r ON r.CRAMO=car.CRAMO AND r.CIDIOMA =8
INNER JOIN TOMADORES t ON t.sseguro=car.sseguro
INNER JOIN PER_PERSONAS pp_tom ON pp_tom.SPERSON=t.SPERSON
INNER JOIN seguros cer ON cer.npoliza=car.npoliza 
INNER JOIN movseguro mov_cer ON mov_cer.SSEGURO=cer.SSEGURO AND mov_cer.NMOVIMI = (SELECT max(nmovimi) FROM movseguro m2 WHERE m2.sseguro=cer.sseguro AND m2.CMOVSEG <> 52)
LEFT JOIN asegurados aseg_cer ON aseg_cer.SSEGURO =cer.sseguro
LEFT JOIN PER_PERSONAS pp_aseg ON pp_aseg.SPERSON=aseg_cer.SPERSON
LEFT JOIN AUTRIESGOS ar ON aseg_cer.SSEGURO =ar.sseguro
LEFT JOIN pregunpolseg pp ON aseg_cer.SSEGURO = pp.sseguro AND pp.cpregun = 795
WHERE
car.sproduc in (900730,10024,900747,6031, 6042, 6041, 6042, 6043, 6044, 6045, 6046, 6047, 6048, 6049, 6048, 6032,6033,6034,6035,6038, 6047, 6039,6045,6024,6025,809,6023,6026,6027,6028,6029,6030,6052,7467,70106,8201,8202,8203,8204,8205,8206,8207,8208,8209,8210,8211,900748,10004,10011,900753,
10012,10013,10014,10015,10016,10017,10018,10019, 10003,6071,900731,10024,900753,900758,10020, 10001, 10000,10000, 7467, 900719,10021,10022,10023,111715,10002,7469,900745,900719,900720,70107,900744,7452,807,808,900720,10009,7468,900755,900719,900759,900762,900774,900776,900775,900778,900777,900779,900771,900746, 10024, 10003,6071, 900742, 900758, 10003, 10001, 10000) 
AND car.npoliza IN (27174632, 27174743, 27174765, 27174770, 27174832, 27174841, 27174844, 27175001, 27175002, 27175003, 27174885, 27174639)
AND car.ncertif=0
)
SELECT * FROM primas



--------------------------------------------------------------------------------------------
------------------Consulta Prima Fuente Ejemplo Detalle Registros se ve duplicidad----------
-------------------------------------------------------------------------------------------
SELECT 
car.sseguro as seguro,
car.cramo as codramo,
car.cagente as agente,
car.sproduc as producto,
(CASE WHEN NVL (axis.f_parproductos_v (car.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
'C'
ELSE 'I' END) tipo_poliza, 
DECODE(axis.pac_preguntas.f_get_pregunpolseg_resp(car.sseguro,6117,'POL'),-1,'',axis.pac_preguntas.f_get_pregunpolseg_resp(car.sseguro,6117,'POL')) modalidad,
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
1 as newcore,
pp_tom.NNUMIDE as inden_tomador,
decode(pp_tom.ctipide , 24, 'P.P',33, 'C.E',34,'Tarjeta identidad',35,'Registro civil',36,'C.C',37,'NIT',38,'N.U.I.P',40,'Pasaporte',43,'BIC',44,'Carnet Diplomático',45,'NIT E.',46,'Permiso especial de permanencia',47,'PECP',99,'Identificador simulaciones', 0, 'Identificiacion del sistema', 48, 'P.P.T') as tipo_identomador,
axis.pac_isqlfor.f_dades_persona(pp_tom.sperson, 4, 8, 'POL')||' '||axis.pac_isqlfor.f_dades_persona(pp_tom.sperson, 5, 8, 'POL') tom_nombres,
r.TRAMO ramo,
cer.ncertif AS certificado_asegurado,
cer.sseguro AS sseguro_certificado,
TO_CHAR(cer.fefecto, 'YYYY-MM-DD') AS fecha_inicio_certificado,
TO_CHAR(cer.femisio, 'YYYY-MM-DD') AS fecha_emision_certificado
FROM AXIS.seguros car
INNER JOIN AXIS.ramos r ON r.CRAMO=car.CRAMO AND r.CIDIOMA =8
INNER JOIN AXIS.TOMADORES t ON t.sseguro=car.sseguro
INNER JOIN AXIS.PER_PERSONAS pp_tom ON pp_tom.SPERSON=t.SPERSON
INNER JOIN AXIS.seguros cer ON cer.npoliza=car.npoliza 
INNER JOIN AXIS.movseguro mov_cer ON mov_cer.SSEGURO=cer.SSEGURO AND mov_cer.NMOVIMI = (SELECT max(nmovimi) FROM AXIS.movseguro m2 WHERE m2.sseguro=cer.sseguro AND m2.CMOVSEG <> 52)
LEFT JOIN AXIS.asegurados aseg_cer ON aseg_cer.SSEGURO =cer.sseguro
LEFT JOIN AXIS.PER_PERSONAS pp_aseg ON pp_aseg.SPERSON=aseg_cer.SPERSON
LEFT JOIN AXIS.AUTRIESGOS ar ON ar.sseguro = aseg_cer.SSEGURO
LEFT JOIN AXIS.pregunpolseg pp ON aseg_cer.SSEGURO = pp.sseguro AND pp.cpregun = 795
Where car.cagente in ('4015907','4096183')
and car.sproduc in ('6071','10003','900753','10024')
--car.sproduc in (900730,10024,900747,6031, 6042, 6041, 6042, 6043, 6044, 6045, 6046, 6047, 6048, 6049, 6048, 6032,6033,6034,6035,6038, 6047, 6039,6045,6024,6025,809,6023,6026,6027,6028,6029,6030,6052,7467,70106,8201,8202,8203,8204,8205,8206,8207,8208,8209,8210,8211,900748,10004,10011,900753,
--10012,10013,10014,10015,10016,10017,10018,10019, 10003,6071,900731,10024,900753,900758,10020, 10001, 10000,10000, 7467, 900719,10021,10022,10023,111715,10002,7469,900745,900719,900720,70107,900744,7452,807,808,900720,10009,7468,900755,900719,900759,900762,900774,900776,900775,900778,900777,900779,900771,900746, 10024, 10003,6071, 900742, 900758, 10003, 10001, 10000) 
--car.npoliza IN (27174491, 27174494, 27174496, 27174509,27174510,27174511,27174513, 27174507, 27174635)
--and 
and car.ncertif=0
--and pp_tom.NNUMIDE=8904059747
order by car.NPOLIZA,cer.ncertif  ASC



----------------------------------------------------------------------------------------
--Version Axis campo chicharron funcion FF_DESVALORFIJO campo num_certificado-----------
----------------------------------------------------------------------------------------
SELECT 
    COALESCE(
        CASE 
            WHEN dv.tatribu = 'Vigente' THEN t2.cantidad_cert
            ELSE 0
        END,
    0) AS num_certificado,
dv_car.tatribu AS estado_caratula    
from gde_adp_ods.axis_seguros car
INNER JOIN gde_adp_ods.axis_ramos r ON r.CRAMO=car.CRAMO AND r.CIDIOMA =8
INNER JOIN gde_adp_ods.axis_TOMADORES t ON t.sseguro=car.sseguro
INNER JOIN gde_adp_ods.axis_PER_PERSONAS pp_tom ON pp_tom.SPERSON=t.SPERSON
INNER JOIN gde_adp_ods.axis_seguros cer ON cer.npoliza=car.npoliza 
INNER JOIN gde_adp_ods.axis_movseguro mov_cer ON mov_cer.SSEGURO=cer.SSEGURO AND mov_cer.NMOVIMI = (SELECT max(nmovimi) FROM gde_adp_ods.axis_movseguro m2 WHERE m2.sseguro=cer.sseguro AND m2.CMOVSEG <> 52)
LEFT JOIN gde_adp_ods.axis_asegurados aseg_cer ON aseg_cer.SSEGURO =cer.sseguro
LEFT JOIN gde_adp_ods.axis_PER_PERSONAS pp_aseg ON pp_aseg.SPERSON=aseg_cer.SPERSON
LEFT JOIN gde_adp_ods.axis_AUTRIESGOS ar ON aseg_cer.SSEGURO =ar.sseguro
LEFT JOIN gde_adp_ods.axis_pregunpolseg pp ON aseg_cer.SSEGURO = pp.sseguro AND pp.cpregun = 795
--Reemplazo de la función ff_desvalorfijo(61, 8, cer.csituac)
LEFT JOIN gde_adp_ods.axis_detvalores dv ON dv.cvalor = 61 AND dv.cidioma = 8 AND dv.catribu = cer.csituac
--Reemplazo de ff_desvalorfijo(61, 8, car.csituac)
LEFT JOIN gde_adp_ods.axis_detvalores dv_car ON dv_car.cvalor = 61 AND dv_car.cidioma = 8 AND dv_car.catribu = car.csituac
-- Conteo previo de certificados por póliza (reemplazo de subconsulta)
LEFT JOIN (
    SELECT npoliza, COUNT(*) AS cantidad_cert
    FROM gde_adp_ods.axis_seguros 
    WHERE ncertif <> 0
    GROUP BY npoliza
) t2 ON car.npoliza = t2.npoliza
WHERE car.ncertif = 0



----------------------------------------------------------------------------------------------
--------------------------------------Version Redshift Final----------------------------------------
----------------------------------------------------------------------------------------------
SELECT 
TO_CHAR(car.fefecto,'YYYY-MM-DD') fecha_inicio_vigencia,
--TO_CHAR (nvl(pac_isqlfor_lcol.F_FVENCIM(car.sseguro, 'POL',NULL),sysdate),'YYYY-MM-DD') fecha_fin_vigencia,
TO_CHAR(car.FEMISIO ,'YYYY-MM-DD') fecha_emision,
decode(pp_tom.ctipide , 24, 'P.P',33, 'C.E',34,'Tarjeta identidad',35,'Registro civil',36,'C.C',37,'NIT',38,'N.U.I.P',40,'Pasaporte',43,'BIC',44,'Carnet Diplomático',45,'NIT E.',46,'Permiso especial de permanencia',47,'PECP',99,'Identificador simulaciones', 0, 'Identificiacion del sistema', 48, 'P.P.T') tipo_documento,
pp_tom.NNUMIDE as numero_identificacion_tomador,
TRIM(NVL(per_det.tapelli1, '') || ' ' || NVL(per_det.tapelli2, '') || ' ' || NVL(per_det.tnombre1, '')) AS nombre_tomador,
car.NPOLIZA numero_poliza,
(case when car.sproduc::varchar in('10024','900742','LGP','900746','900747','900774','900776','900751','22','2') then 'EMP'
when car.sproduc::varchar in('900753','6031','6048','6033','6034','6047','6039','6042','6046','6049','6045','6043','6035','6038','6041','6036') then 'AUT'
when car.sproduc::varchar in ('6071','10003','900758','10001','10000')then 'HOG'
WHEN car.SPRODUC::varchar IN('7469','6023','6025','900720','6026','900719','6024','6028','7468','7467','6029','900721','6052')then 'VID'
WHEN car.SPRODUC::varchar IN ('E1','ADU','Z1','H1','SE','T1')then 'SAL'
WHEN car.SPRODUC::varchar IN ('BO','LB','10004','10005','1') THEN 'CUM'
WHEN car.SPRODUC::varchar IN ('TRC','10','70107','70108','900731','TRM','900777','8092','900778')THEN 'TRA'
WHEN car.SPRODUC::varchar IN ('DO1','LA1','111715','900775','900752','RCL','RCM','REO','RCP')THEN 'RCE'
WHEN car.SPRODUC::varchar IN ('900745','19','900779','17')THEN 'ING'
WHEN car.SPRODUC::varchar IN ('900730') THEN 'SOA'
END ) as ramo,
car.sproduc,
dv_car.tatribu AS estado,
null vistag,
case when lower(car.sproduc) in ('7469','900753','6023','6025','10024','6048','900720','6026','e1','lgp','6047','adu','900747','6024','6042','6046','z1','6029','900774','6049','6045','6043','6041','h1','6071','10003','900752','900731','trm') then 'C' else 'I' end as tipo_poliza,
--substr(pac_redcomercial.f_busca_padre(12,car.cagente,NULL,sysdate),length(pac_redcomercial.f_busca_padre(12,car.cagente,NULL,sysdate))-2,3)||'-'||ff_desagente(pac_redcomercial.f_busca_padre(12,car.cagente,NULL,sysdate)) sucursal,
car.cagente as intermediario,
--f_por_comi_financiero (car.sseguro, null, car.fefecto, car.cagente, null, 'POL', null) comision,
DECODE(1, 1, tp.ttitulo, 2, tp.trotulo) AS riesgos_vigentes,
COALESCE(
        CASE 
           WHEN dv.tatribu = 'Vigente' THEN t2.cantidad_cert
            ELSE 0
        END,0)  AS Riesgos,
pp.trespue AS nro_cotizacion,
--prima_total_car Este campo se debe obtener del SP "sp_insert_dwh_fact_query_renewal"
car.sseguro as sseguro_caratula,
---Estos campos identifican registro unico por poliza
cer.ncertif AS certificado_asegurado,
cer.sseguro AS sseguro_certificado,
TO_CHAR(cer.fefecto, 'YYYY-MM-DD') AS fecha_inicio_certificado,
TO_CHAR(cer.femisio, 'YYYY-MM-DD') AS fecha_emision_certificado,
dv.tatribu AS estado_certificado,
mov_cer.cmovseg AS ultimo_movimiento_certificado
from gde_adp_ods.axis_seguros car
INNER JOIN gde_adp_ods.axis_ramos r ON r.CRAMO=car.CRAMO AND r.CIDIOMA =8
INNER JOIN gde_adp_ods.axis_TOMADORES t ON t.sseguro=car.sseguro
INNER JOIN gde_adp_ods.axis_PER_PERSONAS pp_tom ON pp_tom.SPERSON=t.SPERSON
INNER JOIN gde_adp_ods.axis_seguros cer ON cer.npoliza=car.npoliza 
INNER JOIN gde_adp_ods.axis_movseguro mov_cer ON mov_cer.SSEGURO=cer.SSEGURO 
                                              AND mov_cer.NMOVIMI = (SELECT max(nmovimi)
                                                                     FROM gde_adp_ods.axis_movseguro m2 
                                                                     WHERE m2.sseguro=cer.sseguro 
                                                                     AND m2.CMOVSEG <> 52)
INNER JOIN gde_adp_ods.axis_per_detper per_det ON per_det.sperson = t.sperson --and pp_tom.SPERSON = per_det.sperson
LEFT JOIN gde_adp_ods.axis_asegurados aseg_cer ON aseg_cer.SSEGURO =cer.sseguro
LEFT JOIN gde_adp_ods.axis_PER_PERSONAS pp_aseg ON pp_aseg.SPERSON=aseg_cer.SPERSON
LEFT JOIN gde_adp_ods.axis_AUTRIESGOS ar ON aseg_cer.SSEGURO =ar.sseguro
LEFT JOIN gde_adp_ods.axis_pregunpolseg pp ON aseg_cer.SSEGURO = pp.sseguro 
                                           AND pp.cpregun = 795
-- Reemplazo de la función ff_desvalorfijo(61, 8, cer.csituac)
LEFT JOIN gde_adp_ods.axis_detvalores dv ON dv.cvalor = 61 
                                         AND dv.cidioma = 8 
                                         AND dv.catribu = cer.csituac
--Reemplazo de ff_desvalorfijo(61, 8, car.csituac)
LEFT JOIN gde_adp_ods.axis_detvalores dv_car ON dv_car.cvalor = 61 
                                             AND dv_car.cidioma = 8 
                                             AND dv_car.catribu = car.csituac
-- Conteo previo de certificados por póliza (reemplazo de subconsulta)
LEFT JOIN (
    SELECT npoliza, COUNT(*) AS cantidad_cert
    FROM gde_adp_ods.axis_seguros 
    WHERE ncertif <> 0
    GROUP BY npoliza
) t2 ON car.npoliza = t2.npoliza
-- Reemplazo de la función F_DESPRODUCTO_T adaptada a Redshift mediante LEFT JOIN
LEFT JOIN gde_adp_ods.axis_titulopro tp ON tp.ctipseg = car.ctipseg 
                                        AND tp.cramo = car.cramo 
                                        AND tp.cmodali = car.cmodali 
                                        AND tp.ccolect = car.ccolect 
                                        AND tp.cidioma = 8 
Where car.cagente in ('4015907','4096183')
and car.sproduc in ('6071','10003','900753','10024')
--car.sproduc in (900730,10024,900747,6031, 6042, 6041, 6042, 6043, 6044, 6045, 6046, 6047, 6048, 6049, 6048, 6032,6033,6034,6035,6038, 6047, 6039,6045,6024,6025,809,6023,6026,6027,6028,6029,6030,6052,7467,70106,8201,8202,8203,8204,8205,8206,8207,8208,8209,8210,8211,900748,10004,10011,900753,
--10012,10013,10014,10015,10016,10017,10018,10019, 10003,6071,900731,10024,900753,900758,10020, 10001, 10000,10000, 7467, 900719,10021,10022,10023,111715,10002,7469,900745,900719,900720,70107,900744,7452,807,808,900720,10009,7468,900755,900719,900759,900762,900774,900776,900775,900778,900777,900779,900771,900746, 10024, 10003,6071, 900742, 900758, 10003, 10001, 10000) 
--car.npoliza IN (27174491, 27174494, 27174496, 27174509,27174510,27174511,27174513, 27174507, 27174635)
--and 
and car.ncertif=0
--and pp_tom.NNUMIDE=8904059747
order by car.NPOLIZA,cer.ncertif  ASC




---Funciones a reeemplazar campo sucursal
CREATE OR REPLACE PACKAGE AXIS.pac_redcomercial AUTHID CURRENT_USER IS
/******************************************************************************
   NOMBRE:  pac_redcomercial
   PROPySITO:     funcionalidades para la red comercial.
   REVISIONES:
   Ver        Fecha        Autor             Descripcion
   ---------  ----------  ---------------  ------------------------------------
   1.0        ??/??/????   ???                1. Creacion del objeto.
   2.0        10/10/2016   JMC                2. Previo Renovacion Autos
******************************************************************************/

/*************************************************************************
      Retorna el agente padre del agente que se especifica
      O retorna el agente padre el tipo que se especifica del agente
      return             : null error
                           ID agente padre
   *************************************************************************/
-- Bug 20071 - JTS - 23/12/2011 - se crea la funcion
   FUNCTION f_busca_padre(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pctipage IN NUMBER,
      pfbusca IN DATE)
      RETURN NUMBER;


/*************************************************************************
Retorna el agente padre del agente que se especifica
O retorna el agente padre el tipo que se especifica del agente
return             : null error
ID agente padre
*************************************************************************/
-- Bug 20071 - JTS - 23/12/2011 - se crea la funcion
FUNCTION f_busca_padre(
    pcempres IN NUMBER,
    pcagente IN NUMBER,
    pctipage IN NUMBER,
    pfbusca  IN DATE)
  RETURN NUMBER
IS
  v_padre   NUMBER;
  v_padre2  NUMBER;
  v_ctipage NUMBER := pctipage;
  v_fbusca  DATE   := pfbusca;
BEGIN
  IF pcempres IS NULL OR pcagente IS NULL THEN
    p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_busca_padre', 1, 'Parametros incorrectos', '');
    RETURN NULL;
  END IF;
  IF v_fbusca IS NULL THEN
    v_fbusca  := TRUNC(f_sysdate);
  END IF;
  IF pctipage IS NULL THEN
    BEGIN
      SELECT cpadre
      INTO v_padre
      FROM redcomercial
      WHERE cagente = pcagente
      AND cempres   = pcempres
      AND fmovini  <= v_fbusca
      AND(fmovfin   > v_fbusca
      OR fmovfin   IS NULL);
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --  INI Bug 0034491/0198329 - JMG - 13/02/2015
      BEGIN
        SELECT cpadre,
          ctipage
        INTO v_padre,
          v_ctipage
        FROM redcomercial c
        WHERE c.cagente      = pcagente
        AND TRUNC(c.fmodifi) =
          (SELECT MAX(TRUNC(fmodifi)) FROM redcomercial WHERE cagente = c.cagente
          );
      EXCEPTION
      WHEN OTHERS THEN
        --No tiene padre
        RETURN NULL;
      END;
      --  FIN Bug 0034491/0198329 - JMG - 13/02/2015
    END;
  ELSE
    BEGIN
      SELECT cpadre,
        ctipage
      INTO v_padre,
        v_ctipage
      FROM redcomercial
      WHERE cagente = pcagente
      AND cempres   = pcempres
      AND fmovini  <= v_fbusca
      AND(fmovfin   > v_fbusca
      OR fmovfin   IS NULL);
      IF v_ctipage  = pctipage THEN
        RETURN v_padre;
      END IF;
      WHILE TRUE
      LOOP
        SELECT cpadre,
          ctipage
        INTO v_padre2,
          v_ctipage
        FROM redcomercial
        WHERE cagente = v_padre
        AND cempres   = pcempres
        AND fmovini  <= v_fbusca
        AND(fmovfin   > v_fbusca
        OR fmovfin   IS NULL);
        IF v_ctipage  = pctipage THEN
          RETURN v_padre;
        ELSE
          v_padre := v_padre2;
        END IF;
      END LOOP;
      v_padre := NULL;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --No tiene padre de este tipo
      RETURN NULL;
    END;
  END IF;
  RETURN v_padre;
EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_busca_padre', 2, SQLCODE, SQLERRM);
  RETURN NULL;
END f_busca_padre;
END pac_redcomercial;


---------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------FF_DESAGENTE---------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION AXIS."FF_DESAGENTE" (pcagente IN agentes.cagente%TYPE)
   RETURN VARCHAR2 AUTHID CURRENT_USER
IS
   vobjectname      VARCHAR2 (500) := 'FF_DESAGENTE';
   vparam           VARCHAR2 (500) := 'parámetros - pcagente:' || pcagente;
   vpasexec         NUMBER (5)     := 1;
   vdesagente       VARCHAR2 (500);
   vnum_err         NUMBER;
   e_object_error   EXCEPTION;
   e_param_error    EXCEPTION;
BEGIN
   --Comprovació de paràmetres d'entrada
   IF pcagente IS NULL
   THEN
      RAISE e_param_error;
   END IF;

   vnum_err := f_desagente (pcagente, vdesagente);

   IF vnum_err <> 0
   THEN
      RAISE e_object_error;
   END IF;

   RETURN vdesagente;
EXCEPTION
   WHEN e_param_error
   THEN
      p_tab_error (f_sysdate,
                   f_user,
                   vobjectname,
                   vpasexec,
                   vparam,
                   'Objeto invocado con parámetros erroneos'
                  );
      RETURN '**';
   WHEN e_object_error
   THEN
      p_tab_error (f_sysdate,
                   f_user,
                   vobjectname,
                   vpasexec,
                   vparam,
                   'Error F_DESAGENTE. Num_err:' || vnum_err
                  );
      RETURN '**';
   WHEN OTHERS
   THEN
      p_tab_error (f_sysdate,
                   f_user,
                   vobjectname,
                   vpasexec,
                   vparam,
                   'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                  );
      RETURN '**';
END;


-------------------------------------------------------------------------------------------
----------------------------------- funcion f_desagente------------------------------------
-------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION AXIS."F_DESAGENTE" (
   pcagente   IN       NUMBER,
   ptnombre   IN OUT   VARCHAR2
)
   RETURN NUMBER AUTHID CURRENT_USER
IS
/***********************************************************************
    F_AGENTE: Nombre del Agente.
    ALLIBMFM
***********************************************************************/
   num_err       NUMBER;
BEGIN

   num_err := 100504;                                     -- Agent inexistent
   SELECT f_nombre (sperson, 1, null)
     INTO ptnombre
     FROM agentes
    WHERE cagente = pcagente;

--   num_err := 100534;                                    -- Persona inexistent
   RETURN 0;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN num_err;
END;  


--------------------------------------------------------------------------------------------
--------------------------------- funcion f_nombre------------------------------------------
--------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION AXIS.f_nombre(
   psperson IN NUMBER,
   pnformat IN NUMBER,
   pcagente IN agentes.cagente%TYPE DEFAULT NULL)
   RETURN VARCHAR2 AUTHID CURRENT_USER IS
/****************************************************************************
    F_NOMBRE: DEVUELVE EL NOMBRE DE UNA PERSONA FORMATEADO, SEGÚN EL
            FORMATO DESEADO.
            PNFORMAT = 1 => < APELLIDOS, NOMBRE >
            PNFORMAT = 2 => < NIF   APELLIDOS, NOMBRE >
            PNFORMAT = 3 => < NOMBRE APELLIDOS >
    ALLIBMFM.
    MODIFICO EL FORMAT 2, PER FER-LO UNA MICA MÉS ESPAIAT.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   2.0        01/09/2010   JMF              1. 0015857: ENSA101 - Canvi ordre nom i cognoms en transferencies
   3.0        17/06/2019   CASL             1. 0053334: REQUERIMIENTO SFC - VISITA SARLAFT
   4.0        08/11/2022   GZG              4. AITSSD-2811: PDF Póliz no muestra nombre intermediario
   5.0        21/12/2022   MAV              5. AITSSD-4350: Disminuir llamados a la vista personas en la función f_nombre
****************************************************************************/
   vntraza        NUMBER := 0;
   pnombre        VARCHAR2(2000);-- AITSSD-2811 GZG 08/11/2022
   vnombre        VARCHAR2(2000);-- BUG 0053334 - 17/06/2019 - CASL - Se crea nueva variable
   pnombre2       VARCHAR2(200);
   letra1         VARCHAR2(1);
   pnnumnif       per_personas.nnumide%TYPE;
   -- BUG 0015857 - 01/09/2010 - JMF
   v_tapelli1     per_detper.tapelli1%TYPE;
   v_tapelli2     per_detper.tapelli2%TYPE;
   v_tnombre      per_detper.tnombre%TYPE;
BEGIN
   BEGIN
      vntraza := 1;

      -- PERSONA PÚBLICA
      -- BUG 0015857 - 01/09/2010 - JMF
      SELECT LTRIM(RTRIM(pd.tapelli1)), LTRIM(RTRIM(pd.tapelli2)), LTRIM(RTRIM(pd.tnombre)),
             p.nnumide
        INTO v_tapelli1, v_tapelli2, v_tnombre,
             pnnumnif
        FROM per_personas p, per_detper pd
       WHERE p.sperson = pd.sperson
         AND p.sperson = psperson
         AND p.swpubli = 1   -- Persona Pública, nos da igual el agente.
         -- Bug 29166/160004 - 29/11/2013 - AMC
         /*AND pd.fmovimi = (SELECT MAX(d.fmovimi)
                             FROM per_detper d
                            WHERE d.sperson = pd.sperson)*/
         AND pd.cagente = p.cagente;

      vntraza := 2;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         vntraza := 3;

         IF pcagente IS NOT NULL THEN
            vntraza := 4;

            -- BUG 0015857 - 01/09/2010 - JMF
            SELECT LTRIM(RTRIM(pd.tapelli1)), LTRIM(RTRIM(pd.tapelli2)),
                   LTRIM(RTRIM(pd.tnombre)), p.nnumide
              INTO v_tapelli1, v_tapelli2,
                   v_tnombre, pnnumnif
              FROM per_detper pd, per_personas p
             WHERE pd.sperson = psperson
               AND pd.cagente = ff_agente_cpervisio(pcagente)
               AND pd.sperson = p.sperson;

            vntraza := 5;
         ELSE
            vntraza := 6;
            -- INI MAV AITSSD-4350 21/12/2022
            BEGIN
             -- consulta con las mismas condiciones que la parte 3 de la vista personas
             -- persona no publica del agente que está conectado
             SELECT LTRIM(RTRIM(pd.tapelli1)), LTRIM(RTRIM(pd.tapelli2)), LTRIM(RTRIM(pd.tnombre)),
             pp.nnumide
             INTO v_tapelli1, v_tapelli2, v_tnombre,pnnumnif
             FROM per_personas pp, per_detper pd
             WHERE pp.sperson = pd.sperson
             AND pp.sperson = psperson
             AND pp.swpubli = 0
             AND pd.cagente = ff_agenteprod();
            exception when others then
            -- FIN MAV AITSSD-4350 21/12/2022

            -- BUG 0015857 - 01/09/2010 - JMF
            SELECT LTRIM(RTRIM(pd.tapelli1)), LTRIM(RTRIM(pd.tapelli2)),
                   LTRIM(RTRIM(pd.tnombre)), nnumnif
              INTO v_tapelli1, v_tapelli2,
                   v_tnombre, pnnumnif
              FROM personas pd
             WHERE sperson = psperson;
             -- INI MAV AITSSD-4350 21/12/2022
             END;
             -- FIN MAV AITSSD-4350 21/12/2022

            vntraza := 7;
         END IF;
   END;

   vntraza := 8;

   -- ini BUG 0015857 - 01/09/2010 - JMF
   IF pnformat = 3 THEN
      pnombre := v_tnombre || ' ' || v_tapelli1 || ' ' || v_tapelli2;
   ELSE
      -- Para pnformat 1 y 2.
      IF v_tnombre IS NULL THEN
         pnombre := v_tapelli1 || ' ' || v_tapelli2;
      ELSE
         pnombre := v_tapelli1 || ' ' || v_tapelli2 || ', ' || v_tnombre;
      END IF;
   END IF;
   --
   -- INI BUG 0053334 - 17/06/2019 - CASL - Se obtiene el nombre con carateres especiales
   --
   BEGIN
      --
      SELECT tapenom
        INTO vnombre
        FROM per_detper_ce
       WHERE sperson = psperson;
      --
      pnombre := vnombre;
      --
   EXCEPTION
      WHEN OTHERS
      THEN
         --
         NULL;
         --
   END;
   --
   -- FIN BUG 0053334 - 17/06/2019 - CASL
   --
   -- fin BUG 0015857 - 01/09/2010 - JMF
   IF pnformat IN(1, 3) THEN
      vntraza := 9;
      RETURN pnombre;
   ELSIF pnformat = 2 THEN
      vntraza := 10;

      IF pnnumnif IS NOT NULL THEN
         vntraza := 11;

         --letra1 := SUBSTR (pnnumnif, 1, 1);
         IF SUBSTR(pnnumnif, 1, 2) = 'ZZ' THEN
            vntraza := 12;
            pnombre2 := SUBSTR('            ' || pnombre, 1, 80);
         ELSE
            vntraza := 13;
            pnombre2 := SUBSTR(pnnumnif || '   ' || pnombre, 1, 80);
         END IF;
      END IF;

      vntraza := 14;
      RETURN pnombre2;
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN('**');
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'F_NOMBRE', vntraza,
                  'Parametros - psperson = ' || psperson || '  nformat = ' || pnformat
                  || ' pcagente = ' || pcagente,
                  SQLERRM);
      RETURN('**');
END;


-------------------------------------------------------------------------------------------
--------------------------------------FF_AGENTEPROD----------------------------------------
-------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION AXIS."FF_AGENTEPROD" 
--BUG 12264 07-12-2009 JMC : Eliminar codi superflu
RETURN NUMBER
-- FIN BUG 12264 07-12-2009 JMC
AUTHID CURRENT_USER IS
/***********************************************************************
    MCA 01/2007  Recuperación del usuario guardado
                 en la variable de contexto Usuario
   REVISIONS:
   Ver        Data         Autor             Descripció
   ---------  ----------  ---------------  ----------------------------------
   1.0        02/06/2009   MSR               Optimització
   2.0        07-12-2009   JMC               Se cambia el RETURN de VARCHAR2
                                             a NUMBER
***********************************************************************/
BEGIN
   --BUG9903 02/06/2009 MSR : Eliminar codi superflu
   RETURN to_number(NVL(pac_contexto.f_contextovalorparametro('IAX_AGENTEPROD'),
              pac_contexto.f_contextovalorparametro('IAX_AGENTE')));
--FI BUG9903 02/06/2009 MSR : Eliminar codi superflu
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'FF_AgenteProd', 1,
                  'Error al buscar el atributo contextual Agente Producción', SQLERRM);
      RETURN NULL;
END ff_agenteprod;  





-----------------------------------------------------------------------------------------------
------------------------------------Paquete PAC_CONTEXTO---------------------------------------
-----------------------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE AXIS."PAC_CONTEXTO" AUTHID CURRENT_USER IS
/****************************************************************************
   NOM:       PAC_CONTEXTO
   PROPÒSIT:

   REVISIONS:
   Ver        Data        Autor             Descripció
   ---------  ----------  ---------------  ----------------------------------
   1.0        ??????????
   1.1        27/04/2009   MSR              Optimització
   1.2        02/06/2009   MSR              Posar funcions pel context per defecte
****************************************************************************/
   --BUG9903 27/07/2009 MSR : Es defineix aquesta constant per evitar accedir a F_PARINTALACION_T
   Context_User   CONSTANT VARCHAR2(30)  := F_PARINSTALACION_T('CONTEXT_USER');
--  Tot això no està definit perquè no és compatible amb PAC_IAX_LOGIN
--   cidioma        CONSTANT IDIOMAS.CIDIOMA%TYPE := SYS_CONTEXT (Context_User,'IAX_IDIOMA');
--   cxtusuario     CONSTANT VARCHAR2(100) := SYS_CONTEXT (Context_User,'IAX_USUARIO');
--   cxtagente      CONSTANT VARCHAR2(100) := SYS_CONTEXT (Context_User,'IAX_AGENTE');
--   cempresa       CONSTANT EMPRESAS.CEMPRESA%TYPE) := SYS_CONTEXT (Context_User,'IAX_EMPRESA');
--   cxtagenteprod  CONSTANT VARCHAR2(100) := SYS_CONTEXT (Context_User,'IAX_AGENTEPROD');
--   cxtterminal    CONSTANT VARCHAR2(100) := SYS_CONTEXT (Context_User,'IAX_TERMINAL');
--   nombre         CONSTANT VARCHAR2(100) := SYS_CONTEXT (Context_User,'NOMBRE');
   --FI BUG9903 27/07/2009 MSR : Es defineix aquesta constant per evitar accedir a F_PARINTALACION_T


   PROCEDURE p_contextoasignaparametro (
      pcnomcontexto    IN   VARCHAR2,
      pcnomparametro   IN   VARCHAR2,
      pvalparametro    IN   VARCHAR2);

-- Funcion que devuelve el valor de uno de los parámetros del contexto pasados por parametro
   FUNCTION f_contextovalorparametro (
      pcnomcontexto    IN   VARCHAR2,
      pcnomparametro   IN   VARCHAR2)
      RETURN VARCHAR2;

   --BUG9903 02/06/2009 MSR : Context per defecte
   PROCEDURE p_contextoasignaparametro (
      pcnomparametro   IN   VARCHAR2,
      pvalparametro    IN   VARCHAR2);

   FUNCTION f_contextovalorparametro (
      pcnomparametro   IN   VARCHAR2)
      RETURN VARCHAR2;
   --FI BUG9903 02/06/2009 MSR : Context per defecte


-- *** 0007870: Inicializar atributos contextuales en nuevas sesiones y parametrización de las imágenes para los listados
-- Funcion para inicilizar los atributos contextuales
   FUNCTION F_InicializarCTX (pcusuari IN USUARIOS.CUSUARI%TYPE,pterminal IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
END pac_contexto;

CREATE OR REPLACE PACKAGE BODY AXIS."PAC_CONTEXTO" IS

    --Define las varibles tipos contexto
    cxtidioma  VARCHAR2(100)    :='IAX_IDIOMA';
    cxtusuario VARCHAR2(100)    :='IAX_USUARIO';
    cxtagente  VARCHAR2(100)    :='IAX_AGENTE';
    cxtempresa VARCHAR2(100)    :='IAX_EMPRESA';
    cxtagenteprod VARCHAR2(100) := 'IAX_AGENTEPROD';
    cxtterminal VARCHAR2(100)   := 'IAX_TERMINAL';

   PROCEDURE p_contextoasignaparametro (
      pcnomcontexto    IN   VARCHAR2,
      pcnomparametro   IN   VARCHAR2,
      pvalparametro    IN   VARCHAR2) IS
   BEGIN
-- Funcion que asigna un parametro y un valor al contexto de personas
      DBMS_SESSION.set_context (pcnomcontexto, pcnomparametro, pvalparametro);
      if pcnomparametro = 'nombre' then
          DBMS_APPLICATION_INFO.set_module (pvalparametro,NULL);
          DBMS_APPLICATION_INFO.SET_ACTION('Hora: '||to_char(f_sysdate,'DD/MM/YYYY HH24:MI:SS' )) ;
      end if;
   END p_contextoasignaparametro;

   FUNCTION f_contextovalorparametro (
      pcnomcontexto    IN   VARCHAR2,
      pcnomparametro   IN   VARCHAR2)
      RETURN VARCHAR2 IS
   BEGIN
-- Funcion que devuelve el valor de uno de los parámetros del contexto pasados por parametro
      RETURN SYS_CONTEXT (pcnomcontexto, pcnomparametro);
   END f_contextovalorparametro;


   --BUG9903 02/06/2009 MSR : Contexte per defecte
   PROCEDURE p_contextoasignaparametro (
      pcnomparametro   IN   VARCHAR2,
      pvalparametro    IN   VARCHAR2) IS
   BEGIN
     p_contextoasignaparametro(Context_User,pcnomparametro,pvalparametro);
   END;

   FUNCTION f_contextovalorparametro (
      pcnomparametro   IN   VARCHAR2)
      RETURN VARCHAR2 IS
   BEGIN
     RETURN f_contextovalorparametro(Context_User,pcnomparametro);
   END;
   --FI BUG9903 02/06/2009 MSR : Contexte per defecte


-- *** 0007870:  Inicializar atributos contextuales en nuevas sesiones y parametrización de las imágenes para los listados

-- Funcion para inicilizar los atributos contextuales
   FUNCTION F_InicializarCTX (pcusuari IN USUARIOS.CUSUARI%TYPE, pterminal IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
     v_cidioma IDIOMAS.CIDIOMA%TYPE;
     v_cempres EMPRESAS.CEMPRES%TYPE;
     v_agente  AGENTES.CAGENTE%TYPE;
   BEGIN
     SELECT cidioma,cempres  ,cdelega
     INTO v_cidioma,v_cempres,v_agente
     FROM USUARIOS
     WHERE cusuari = pcusuari;

     --BUG9903 27/07/2009 MSR : Utilitzo la constant Context_User
     p_contextoasignaparametro (Context_User,cxtusuario,pcusuari);
     p_contextoasignaparametro (Context_User,'nombre',pcusuari);
     p_contextoasignaparametro (Context_User,cxtempresa,v_cempres);
     p_contextoasignaparametro (Context_User,'empresa',v_cempres);
     p_contextoasignaparametro (Context_User,'empresasel',v_cempres);
     p_contextoasignaparametro (Context_User,'multiempres',v_cempres);
     p_contextoasignaparametro (Context_User,cxtidioma,v_cidioma);
     p_contextoasignaparametro (Context_User, 'usu_idioma',v_cidioma);
     p_contextoasignaparametro (Context_User,cxtagente,v_agente);
     p_contextoasignaparametro (Context_User,cxtagenteprod,v_agente);
     p_contextoasignaparametro (Context_User,cxtterminal,pterminal);
     --FI BUG9903 27/07/2009 MSR : Utilitzo la constant Context_User

     RETURN 0;
   EXCEPTION
     WHEN OTHERS THEN RETURN SQLCODE;
   END F_InicializarCTX;
END pac_contexto;


------------------------------------------------------------------------------------------
---------------------------------Vista Personas-------------------------------------------
------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW AXIS.PERSONAS
(SPERSON,NNUMIDE,NORDIDE,CTIPIDE,CSEXPER,FNACIMI,CESTPER,FJUBILA,CUSUARI,FMOVIMI,CMUTUALISTA,FDEFUNC,SNIP,CAGENTE,CAGENTEPROD,CIDIOMA,TAPELLI1,TAPELLI2,TAPELLI,TNOMBRE,TSIGLAS,CPROFES,TBUSCAR,CESTCIV,CPAIS,CBANCAR,CTIPBAN,SWPUBLI,CTIPPER,NNUMNIF,CPERTIP,TIDENTI,NNIFDUP,NNIFREP,CESTADO,FINFORM,NEMPLEADO,NNUMSOE,TNOMTOT,TPEROBS,CNIFREP,PDTOINT,CCARGOS,TPERMIS,PRODUCTE,NSOCIO,NHIJOS,CLABORAL,CVIP,SPERCON,FANTIGUE,CTRATO,NUM_CONTRA,TDIGITOIDE,COCUPACION)
AS
SELECT per.sperson, per.nnumide, per.nordide, per.ctipide, per.csexper, per.fnacimi,
          per.cestper, per.fjubila, per.cusuari, per.fmovimi, per.cmutualista, per.fdefunc,
          per.snip, d.cagente, ff_agenteprod() cagenteprod, d.cidioma, d.tapelli1, d.tapelli2,
          --Bug 29738/166355 - 14/02/2014 - AMC
          d.tapelli1 || ' ' || d.tapelli2 tapelli,
                                                  --Bug 29738/166355 - 14/02/2014 - AMC
    A                                                                                          -- Se deberá quitar el substr cuando se prepare base de datos
                                                  d.tnombre tnombre,
                                                                    -- Se deberá quitar el substr cuando se prepare base de datos
                                                                    d.tsiglas,
                                                                              -- Se deberá quitar el substr cuando se prepare base de datos
                                                                                           --Bug 29738/166355 - 14/02/2014 - AMC
                                                                              d.cprofes,
          d.tbuscar, d.cestciv, d.cpais, c.cbancar, c.ctipban, per.swpubli, per.ctipper,
          -- Los siguientes campos están obsolotes, se deberán quitar cuando desaparezcan completamente los forms ...  En base de datos no se deben utilizar.
          per.nnumide nnumnif, per.ctipper cpertip, per.ctipide tidenti, per.nordide nnifdup,
          per.nordide nnifrep, per.cestper cestado, per.fmovimi finform, NULL nempleado,
          NULL nnumsoe, NULL tnomtot, NULL tperobs, NULL cnifrep, NULL pdtoint, NULL ccargos,
          NULL tpermis, NULL producte, NULL nsocio, NULL nhijos, NULL claboral, NULL cvip,
          NULL spercon, NULL fantigue, NULL ctrato, NULL num_contra, per.tdigitoide,
          d.cocupacion   -- Bug 25456/133727 - 16/01/2013 - AMC
     FROM per_personas per, per_detper d, per_ccc c, personas_publicas pp
    WHERE per.sperson = d.sperson
      AND c.sperson(+) = d.sperson
      AND c.cagente(+) = d.cagente
      AND c.cdefecto(+) = 1   -- cuenta bacaria por defecto
      AND per.sperson = pp.sperson   -- La persona es pública y estoy autorizado a verla
      AND per.cagente = d.cagente   --Bug 29166/160004 - 29/11/2013 - AMC
   UNION
   SELECT per.sperson, per.nnumide, per.nordide, per.ctipide, per.csexper, per.fnacimi,
          per.cestper, per.fjubila, per.cusuari, per.fmovimi, per.cmutualista, per.fdefunc,
          per.snip, d.cagente, ff_agenteprod() cagenteprod, d.cidioma, d.tapelli1, d.tapelli2,
          --Bug 29738/166355 - 14/02/2014 - AMC
          d.tapelli1 || ' ' || d.tapelli2 tapelli,
                                                  --Bug 29738/166355 - 14/02/2014 - AMC
                                                                                          -- Se deberá quitar el substr cuando se prepare base de datos
                                                  d.tnombre tnombre,   -- Se deberá quitar el substr cuando se prepare base de datos
                                                                    d.tsiglas,
                                                                              -- Se deberá quitar el substr cuando se prepare base de datos
                                                                                           --Bug 29738/166355 - 14/02/2014 - AMC
                                                                              d.cprofes,
          d.tbuscar, d.cestciv, d.cpais, c.cbancar, c.ctipban, per.swpubli, per.ctipper,
          -- Los siguientes campos están obsolotes, se deberán quitar cuando desaparezcan completamente los forms.-- En base de datos no se deben utilizar.
          per.nnumide nnumnif, per.ctipide cpertip, per.ctipide tidenti, per.nordide nnifdup,
          per.nordide nnifrep, per.cestper cestado, per.fmovimi finform, NULL nempleado,
          NULL nnumsoe, NULL tnomtot, NULL tperobs, NULL cnifrep, NULL pdtoint, NULL ccargos,
          NULL tpermis, NULL producte, NULL nsocio, NULL nhijos, NULL claboral, NULL cvip,
          NULL spercon, NULL fantigue, NULL ctrato, NULL num_contra, per.tdigitoide,
          d.cocupacion   -- Bug 25456/133727 - 16/01/2013 - AMC
     FROM per_personas per, per_detper d, per_ccc c
    WHERE per.sperson = d.sperson
      AND c.sperson(+) = d.sperson
      AND c.cagente(+) = d.cagente
      AND c.cdefecto(+) = 1   -- cuenta bacaria por defecto
      AND per.swpubli = 0
      AND d.cagente != ff_agenteprod()
      AND NOT EXISTS(SELECT 1
                       FROM per_detper dd
                      WHERE dd.sperson = per.sperson
                        AND dd.cagente = ff_agenteprod())
      -- La persona es privada y miramos si tenemos acceso a ver estos datos.
      AND d.fmovimi = (SELECT MAX(fmovimi)
                         FROM per_detper dd, agentes_agente aa2
                        WHERE dd.sperson = d.sperson
                          AND dd.cagente = aa2.cagente)
   UNION
   SELECT per.sperson, per.nnumide, per.nordide, per.ctipide, per.csexper, per.fnacimi,
          per.cestper, per.fjubila, per.cusuari, per.fmovimi, per.cmutualista, per.fdefunc,
          per.snip, d.cagente, ff_agenteprod() cagenteprod, d.cidioma, d.tapelli1, d.tapelli2,
          --Bug 29738/166355 - 14/02/2014 - AMC
          d.tapelli1 || ' ' || d.tapelli2 tapelli,
                                                  --Bug 29738/166355 - 14/02/2014 - AMC
                                                                                          -- Se deberá quitar el substr cuando se prepare base de datos
                                                  d.tnombre tnombre,   -- Se deberá quitar el substr cuando se prepare base de datos
                                                                    d.tsiglas,
                                                                              -- Se deberá quitar el substr cuando se prepare base de datos
                                                                                        --Bug 29738/166355 - 14/02/2014 - AMC
                                                                              d.cprofes,
          d.tbuscar, d.cestciv, d.cpais, c.cbancar, c.ctipban, per.swpubli, per.ctipper,
          -- Los siguientes campos están obsolotes, se deberán quitar cuando desaparezcan completamente los forms.-- En base de datos no se deben utilizar.
          per.nnumide nnumnif, per.ctipide cpertip, per.ctipide tidenti, per.nordide nnifdup,
          per.nordide nnifrep, per.cestper cestado, per.fmovimi finform, NULL nempleado,
          NULL nnumsoe, NULL tnomtot, NULL tperobs, NULL cnifrep, NULL pdtoint, NULL ccargos,
          NULL tpermis, NULL producte, NULL nsocio, NULL nhijos, NULL claboral, NULL cvip,
          NULL spercon, NULL fantigue, NULL ctrato, NULL num_contra, per.tdigitoide,
          d.cocupacion   -- Bug 25456/133727 - 16/01/2013 - AMC
     FROM per_personas per, per_detper d, per_ccc c
    WHERE per.sperson = d.sperson
      AND c.sperson(+) = d.sperson
      AND c.cagente(+) = d.cagente
      AND c.cdefecto(+) = 1   -- cuenta bacaria por defecto
      AND per.swpubli = 0
      AND d.cagente = ff_agenteprod();







SUCURSAL
  │
  ├── PAC_REDCOMERCIAL.F_BUSCA_PADRE()
  │       │
  │       └── REDCOMERCIAL
  │
  └── FF_DESAGENTE()
          │
          └── F_DESAGENTE()
                  │
                  ├── AGENTES
                  │
                  └── F_NOMBRE()
                          │
                          ├── PER_PERSONAS
                          ├── PER_DETPER
                          └── PER_DETPER_CE
						  
F_NOMBRE()
    │
    └── FF_AGENTEPROD()
            │
            └── PAC_CONTEXTO
                    │
                    ├── IAX_AGENTEPROD
                    └── IAX_AGENTE	






--------------------------------------------------------------------------------------------
---------------------------Consulta principal probar ---------------------------------------
--------------------------------------------------------------------------------------------
 
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


/* =====================================================================
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
)
select * from nombre_persona


/* =====================================================================
   9. TAPENOM
      F_NOMBRE primero construye el nombre y posteriormente:

          SELECT tapenom
          FROM per_detper_ce
          WHERE sperson = psperson

      Si existe TAPENOM, reemplaza el nombre construido.
   ===================================================================== */
tapenom AS (    
    SELECT
        CAST(NULL AS BIGINT) AS sperson,
        CAST(NULL AS VARCHAR(500)) AS tapenom,
        CAST(NULL AS INTEGER) AS rn
    WHERE 1 = 0
    
    --SELECT
    --    ce.sperson,
    --    TRIM(ce.tapenom) AS tapenom,
    --    ROW_NUMBER() OVER (
    --        PARTITION BY ce.sperson
    --        ORDER BY ce.sperson
    --    ) AS rn
    --FROM gde_adp_ods.axis_per_detper_ce ce
    --WHERE ce.tapenom IS NOT NULL
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


    car.sproduc,


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


    pp.trespue AS nro_cotizacion,


    car.sseguro AS sseguro_caratula,


    cer.ncertif AS certificado_asegurado,


    cer.sseguro AS sseguro_certificado,


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


INNER JOIN gde_adp_ods.axis_movseguro mov_cer
    ON mov_cer.sseguro = cer.sseguro
   AND mov_cer.nmovimi = (
        SELECT MAX(m2.nmovimi)
        FROM gde_adp_ods.axis_movseguro m2
        WHERE m2.sseguro = cer.sseguro
          AND m2.cmovseg <> 52
   )


INNER JOIN gde_adp_ods.axis_per_detper per_det
    ON per_det.sperson = t.sperson


LEFT JOIN gde_adp_ods.axis_asegurados aseg_cer
    ON aseg_cer.sseguro = cer.sseguro


LEFT JOIN gde_adp_ods.axis_per_personas pp_aseg
    ON pp_aseg.sperson = aseg_cer.sperson


LEFT JOIN gde_adp_ods.axis_autriesgos ar
    ON aseg_cer.sseguro = ar.sseguro


LEFT JOIN gde_adp_ods.axis_pregunpolseg pp
    ON aseg_cer.sseguro = pp.sseguro
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
   SUCURSAL
   ================================================================ */

LEFT JOIN sucursal_agente sa
    ON sa.cagente = car.cagente


WHERE car.cagente IN (
    '4015907',
    '4096183'
)

AND car.sproduc IN (
    '6071',
    '10003',
    '900753',
    '10024'
)

AND car.ncertif = 0


ORDER BY
    car.npoliza,
    cer.ncertif ASC;                    














