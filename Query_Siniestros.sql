-------------------------------------------------------------------------------
-----------------------------------SINIESTROS----------------------------------
-------------------------------------------------------------------------------

WITH garant AS(
	SELECT DISTINCT t1.nsinies, t2.CGARANT, t2.TGARANT 
	FROM axis.sin_tramita_reserva t1
	INNER JOIN axis.garangen t2 ON t2.cgarant = t1.CGARANT AND t2.cidioma = 8
)

SELECT
t1.sseguro,
substr(pac_redcomercial.f_busca_padre(12,t1.cagente,NULL,sysdate),length(pac_redcomercial.f_busca_padre(12,t1.cagente,NULL,sysdate))-2,3) AS code_sucursal,
t1.sproduc AS producto,
1 as newcore,
t2.FNOTIFI AS fecha_aviso,
t2.FSINIES AS fecha_ocurrencia,
PAC_AUTOS.f_get_cmatric(t1.sseguro,'POL') placa,
t1.npoliza AS num_poliza,
t1.ncertif AS certificado,
t2.nsinies numero_siniestro,
(case when to_CHAR(t1.sproduc) in('10024','900742','LGP','900746','900747','900774','900776','900751','22','2') then 'EMP'
when to_CHAR(t1.sproduc) in('900753','6031','6048','6033','6034','6047','6039','6042','6046','6049','6045','6043','6035','6038','6041','6036') then 'AUT'
when to_CHAR(t1.sproduc) in ('6071','10003','900758','10001','10000')then 'HOG'
WHEN to_CHAR(t1.SPRODUC) IN('7469','6023','6025','900720','6026','900719','6024','6028','7468','7467','6029','900721','6052')then 'VID'
WHEN to_CHAR(t1.SPRODUC) IN ('E1','ADU','Z1','H1','SE','T1')then 'SAL'
WHEN to_CHAR(t1.SPRODUC) IN ('BO','LB','10004','10005','1') THEN 'CUM'
WHEN to_CHAR(t1.SPRODUC) IN ('TRC','10','70107','70108','900731','TRM','900777','8092','900778')THEN 'TRA'
WHEN to_CHAR(t1.SPRODUC) IN ('DO1','LA1','111715','900775','900752','RCL','RCM','REO','RCP')THEN 'RCE'
WHEN to_CHAR(t1.SPRODUC) IN ('900745','19','900779','17')THEN 'ING'
WHEN to_CHAR(t1.SPRODUC) IN ('900730') THEN 'SOA'
END ) as agrupacion,
(SELECT tt2.tatribu 
FROM axis.sin_movsiniestro tt1 
INNER JOIN axis.detvalores tt2 ON tt2.CIDIOMA = 8 AND tt2.CVALOR = 6 AND tt2.CATRIBU = tt1.CESTSIN 
WHERE tt1.NSINIES = t2.nsinies
AND tt1.NMOVSIN = (SELECT max(nmovsin) FROM axis.sin_movsiniestro tt3 WHERE tt3.NSINIES = tt1.NSINIES)) AS estado_siniestro,
decode(t4.ctipide , 24, 'P.P',33, 'C.E',34,'Tarjeta identidad',35,'Registro civil',36,'C.C',37,'NIT',38,'N.U.I.P',40,'Pasaporte',43,'BIC',44,'Carnet Diplomático',45,'NIT E.',46,'Permiso especial de permanencia',47,'PECP',99,'Identificador simulaciones', 0, 'Identificiacion del sistema', 48, 'P.P.T') AS tipo_identificacion_asegurado,
pac_isqlfor.f_dades_persona(t4.sperson, 1, 8, 'POL') as numero_identificacion_asegurado,
pac_isqlfor.f_dades_persona(t4.sperson, 4, 8, 'POL')||' '||pac_isqlfor.f_dades_persona(t4.sperson, 5, 8, 'POL')  aseg_nombres,
t1.cagente AS clave_intermediario,
pac_isqlfor.f_dades_persona(t5.sperson, 4, 8, 'POL')||' '||pac_isqlfor.f_dades_persona(t5.sperson, 5, 8, 'POL')  nombre_intermediario,
t2.TSINIES AS descripcion_siniestro,
t6.cgarant AS cod_amparo,
t6.tgarant AS descripcion_amparo
FROM seguros t1
INNER JOIN sin_siniestro t2 ON t1.sseguro = t2.SSEGURO
LEFT JOIN asegurados t3 ON t3.SSEGURO = t1.sseguro
LEFT JOIN PER_PERSONAS t4 ON t4.SPERSON = t3.SPERSON
LEFT JOIN AGENTES t5 ON t5.cagente = t1.cagente
LEFT JOIN garant t6 ON t2.nsinies = t6.nsinies
WHERE t1.npoliza IN (27174491, 27174494, 27174496, 27174509,27174510,27174511,27174513, 27174507, 27174635)
