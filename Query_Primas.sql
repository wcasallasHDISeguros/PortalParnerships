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
+           END
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



--Version Axis campo chicharron funcion FF_DESVALORFIJO campo num_certificado
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



----Version Redshift

SELECT 
cer.ncertif AS certificado_asegurado,
cer.sseguro AS sseguro_certificado,
TO_CHAR(cer.fefecto, 'YYYY-MM-DD') AS fecha_inicio_certificado,
TO_CHAR(cer.femisio, 'YYYY-MM-DD') AS fecha_emision_certificado,
dv.tatribu AS estado_certificado,
mov_cer.cmovseg AS ultimo_movimiento_certificado
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
car.sseguro as sseguro_caratula
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
--order by car.sseguro ASC




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








------------------------------------------------------FF_DESAGENTE
----------------------------------------------------------
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






