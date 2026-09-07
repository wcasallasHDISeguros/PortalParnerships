-- DROP PROCEDURE non_gde_adp_dwh.sp_insert_dwh_fact_query_renewal();

CREATE OR REPLACE PROCEDURE non_gde_adp_dwh.sp_insert_dwh_fact_query_renewal()
	LANGUAGE plpgsql
AS $$
		
begin
	--Tabla de trabajo staging
    drop table if exists non_gde_adp_dwh.dwh_fact_query_renewal_stg2;
	
	create table non_gde_adp_dwh.dwh_fact_query_renewal_stg2
	(
		id INT IDENTITY,
		sseguro_car VARCHAR (255),
		codramo VARCHAR (40),
		agente VARCHAR (500),
		producto VARCHAR (30),
		tipo_poliza VARCHAR (1),
		modalidad VARCHAR (10),
		agrupacion VARCHAR (30),
		newcore VARCHAR (1),
		iden_tomador VARCHAR (20),
		tipo_iden_tomador VARCHAR (10),
		nombre_tomador VARCHAR (1502),
		ramo VARCHAR (90),
		num_certificado VARCHAR (100),
		num_poliza VARCHAR (50),
		estado_caratula VARCHAR (1000),
		sucursal VARCHAR (313),
		fecha_inicio_car DATE,
		fecha_vencimiento_car DATE,
		fecha_emision_car DATE,
		ano_periodo_contable_car VARCHAR (11),
		mes_periodo_contable_car VARCHAR (11),
		prima_emitida_car FLOAT8,
		prima_total_car FLOAT8,
		comision VARCHAR (255),
		des_producto VARCHAR (300),
		inden_asegurado VARCHAR (20),
		tipo_iden_asegurado VARCHAR (10),
		nombre_asegurado VARCHAR (852),
		num_certificado_aseg VARCHAR (100),
		sseguro_cert VARCHAR (255),
		placa VARCHAR (500),
		estado_cert VARCHAR (1000),
		fecha_inicio_cert DATE,
		fecha_vencimiento_cert DATE,
		fecha_emision_cert DATE,
		ano_periodo_contable_cert VARCHAR (11),
		mes_periodo_contable_cert VARCHAR (11),
		prima_emitida_cert FLOAT8,
		prima_total_cert FLOAT8,
		riesgos VARCHAR (200),
		policy_sk INT8,
		recibo VARCHAR (200),
		mov VARCHAR(20),
		mov_rec VARCHAR(20),
		modificaciones INT4,
		anulacion INT4,
		renovacion_aut INT4,
		slip_renovacion VARCHAR (1),
		estado_renovacion VARCHAR (255),
		prima_renovacion_car VARCHAR (1),
		prima_renovacion_cert VARCHAR (1),
		pdf INT4,
		fecha_ejecucion_dwh DATE,
		code_sucursal VARCHAR (15),
		transaction_delta_billed_premium_amount FLOAT8,
		transaction_delta_commission_amount FLOAT8,
		tipo_transaccion VARCHAR (1000),
		cod_tipo_transaccion VARCHAR (50),
		usuario_mov VARCHAR (60),
		dir_tomador VARCHAR (255),
		cod_dane_tom VARCHAR (90),
		municipio_ciudad_tom VARCHAR (50),
		departamento_tom VARCHAR (50),
		pais_tom VARCHAR (50),
		tipo_afinidad VARCHAR (50),
		usos_permitidos VARCHAR (150),
		tipo_riesgo VARCHAR (50),
		cod_resp_macroplan FLOAT8,
		resp_macroplan VARCHAR(300),
		forma_pago INT2,
		modalidad_caratula VARCHAR(30)
		);
	
	drop table if exists #stg;

	select * 
	into #stg
	from non_gde_adp_dwh.dwh_fact_query_renewal_stg2;
	
	--Consulta de las vistas oficiales se obtiene data de los productos indicados de IAXIS y AS400 para un rango de 15 dias, de acuerdo a la estructura indicada en el requerimiento.
	insert into #stg (sseguro_car, codramo, agente, producto, tipo_poliza, modalidad, agrupacion, newcore, iden_tomador, tipo_iden_tomador, nombre_tomador, ramo, num_certificado, num_poliza, estado_caratula, sucursal, fecha_inicio_car, fecha_vencimiento_car, fecha_emision_car, ano_periodo_contable_car, mes_periodo_contable_car, prima_emitida_car, prima_total_car, comision, des_producto, inden_asegurado, tipo_iden_asegurado, nombre_asegurado, num_certificado_aseg, sseguro_cert, placa, estado_cert, fecha_inicio_cert, fecha_vencimiento_cert, fecha_emision_cert, ano_periodo_contable_cert, mes_periodo_contable_cert, prima_emitida_cert, prima_total_cert, riesgos, policy_sk, recibo, mov, mov_rec, modificaciones, anulacion, renovacion_aut, slip_renovacion, estado_renovacion, prima_renovacion_car, prima_renovacion_cert, pdf, fecha_ejecucion_dwh, code_sucursal, transaction_delta_billed_premium_amount, transaction_delta_commission_amount, tipo_transaccion, cod_tipo_transaccion, usuario_mov)
	select distinct		
		  case
		    when lower(t1.source_system) = 'co_iaxis' then split_part(t2.risk_id,'-',1) 
		    else ''
		  end as SSEGURO_CAR				
		, case when t7.product_code in ('E1', 'ADU', 'Z1', 'H1', 'SE', 'T1') then 'SAL'
		  	   when t7.product_code in ('BO','LB', '1') then 'CUM'
		  	   when t7.product_code in ('LGP','22', '2') then 'EMP'
		  	   when t7.product_code in ('19','17') then 'ING'
		  	   when t7.product_code in ('DO1','LA1','RCL','RCM','REO','RCP') then 'REC'
		  	   when t7.product_code in ('TRC','10','TRM') then 'TRA'
		  	   else t5.lob_code 
		  end CODRAMO
		, t3.producer_id as AGENTE
		, t7.product_code as PRODUCTO
		, case when lower(t7.product_code) in ('7469','900753','6023','6025','10024','6048','900720','6026','e1','lgp','6047','adu','900747','6024','6042','6046','z1','6029','900774','6049','6045','6043','6041','h1','6071','10003','900752','900731','trm') then 'C' else 'I' end as TIPO_POLIZA
		, cast('' as varchar(10)) as MODALIDAD               
		, t13.group_code as AGRUPACION
		, case lower(t1.source_system) 
		    when 'co_iaxis' then '1' 
		    when 'co_as400' then '0'
		  end as NEWCORE 
		, t6.customer_identification_number as IDEN_TOMADOR     
		, cast('' as varchar(10)) as TIPO_IDEN_TOMADOR
		/*, ltrim(rtrim(coalesce(customer_first_name,'')||' '
		  ||coalesce(customer_middle_name,'')||' '
		  ||coalesce(customer_last_name, ''))) as NOMBRE_TOMADOR*/
		, cast('' as varchar(255)) as NOMBRE_TOMADOR		
		, case when t7.product_code in ('E1', 'ADU', 'Z1', 'H1', 'SE', 'T1') then 'SALUD'
		  	   when t7.product_code in ('BO','LB', '1') then 'CUMPLIMIENTO'
		       when t7.product_code in ('LGP','22', '2') then 'EMPRESARIALES'
		  	   when t7.product_code in ('19','17') then 'INGENIERIA'
		       when t7.product_code in ('DO1','LA1','RCL','RCM','REO','RCP') then 'RESPONSABILIDAD CIVIL'
		  	   when t7.product_code in ('TRC','10','TRM') then 'TRANSPORTES'
		  	   else t5.lob_description 
		  end RAMO
		, t2.risk_number as NUM_CERTIFICADO
		, t2.policy_number as NUM_POLIZA
		, case when t2.risk_status_description = 'Cancelado' then 'Anulada' else t2.risk_status_description end as ESTADO_CARATULA
		, (case when t9.branch_name not like reverse(substring(reverse('000' + t9.branch_code), 1,3)) + '%' then reverse(substring(reverse('000' + t9.branch_code), 1,3)) + '-' + t9.branch_name else t9.branch_name end) as SUCURSAL
		, t2.risk_effective_date as FECHA_INICIO_CAR
		, t2.risk_expiration_date as FECHA_VENCIMIENTO_CAR        
		, case 
		    when lower(t1.source_system) = 'co_iaxis' then cast(t2.inception_date as date)
		  else cast(t2.origin_ts as date)        		
		  end as FECHA_EMISION_CAR
		, substring(t4.accountable_period, 1, 4) as ANO_PERIODO_CONTABLE_CAR
		, substring(t4.accountable_period, 5, 6) as MES_PERIODO_CONTABLE_CAR
		, cast(0 as float) as PRIMA_EMITIDA_CAR
		, cast(0 as float) as PRIMA_TOTAL_CAR
		, case
		    when sum(t1.transaction_delta_billed_premium_amount)=0 then '0'
		    when abs(sum(t1.transaction_delta_commission_amount)) < abs(sum(t1.transaction_delta_billed_premium_amount)) then cast(abs(sum(t1.transaction_delta_commission_amount)/sum(t1.transaction_delta_billed_premium_amount) * 100) as VARCHAR(255))
		  else '0'
		  end as comision
		, t7.product_description as DES_PRODUCTO
		,cast(t11.insured_identification_number AS varchar(20)) as INDEN_ASEGURADO
		, cast('' as varchar(10)) as TIPO_IDEN_ASEGURADO
		/*, ltrim(rtrim(coalesce(insured_first_name,'')||' '
		  ||coalesce(insured_middle_name,'')||' '
		  ||coalesce(insured_last_name,''))) as NOMBRE_ASEGURADO*/
		, cast('' as varchar(255)) as NOMBRE_ASEGURADO
		, t2.risk_number as NUM_CERTIFICADO_ASEG
		, case
		    when lower(t1.source_system) = 'co_iaxis' then split_part(t2.risk_id,'-',1) 
		    else ''
		    end as SSEGURO_CERT
		, case t12.vehicle_registration_number
		    when 'Unknown' then ''
		    else t12.vehicle_registration_number
		  end as PLACA
		, case when t2.risk_status_description = 'Cancelado' then 'Anulada' else t2.risk_status_description end as ESTADO_CERT
		, t2.risk_effective_date as FECHA_INICIO_CERT
		, t2.risk_expiration_date as FECHA_VENCIMIENTO_CERT
		, case 
		    when lower(t1.source_system) = 'co_iaxis' then cast(t2.inception_date as date)
		  else cast(t2.origin_ts as date)
		  end as FECHA_EMISION_CERT
		, substring(t4.accountable_period, 1, 4) as ANO_PERIODO_CONTABLE_CERT
		, substring(t4.accountable_period, 5, 6) as MES_PERIODO_CONTABLE_CERT
		, sum(t1.transaction_delta_billed_premium_amount) as PRIMA_EMITIDA_CERT
		, sum(t1.transaction_delta_net_written_premium_amount) as PRIMA_TOTAL_CERT
		, cast('' as varchar(200)) as RIESGOS
		, t1.policy_sk
		, case when lower(t1.source_system) = 'co_iaxis' then split_part(t1.audit_transaction_id,'-',1) else split_part(t2.risk_id,'-',5) end recibo
		, case when lower(t1.source_system) = 'co_iaxis' then split_part(t2.risk_id,'-',2) else split_part(t2.risk_id,'-',5) end mov
		, case when lower(t1.source_system) = 'co_iaxis' then split_part(t1.audit_transaction_id,'-',4) else '' end mov_rec
		, case 
		    when t7.product_code in (6034, 6039, 6031, 6033, 6038, 6035) then 1 
		    else 0 
		  end as MODIFICACIONES
		, case 
		    when t7.product_code in (6034, 6039, 6031, 6033, 6038, 6035) then 1 
		    else 0 
		  end as ANULACION
		, case 
		    when t7.product_code in (6034, 6039, 6031, 6033, 6038, 6035) then 1 
		    else 0 
		  end as RENOVACION_AUT
		, '' as SLIP_RENOVACION
		, cast('' as varchar(255)) as ESTADO_RENOVACION
		, '' as PRIMA_RENOVACION_CAR            
		, '' as PRIMA_RENOVACION_CERT
		, case 
		    when lower(t1.source_system) = 'co_iaxis' and lower(t7.product_code) not in ('1', '10004', '10005', 'lb', 'bo', 'ao', '15', 's30', 'u61', '900730') then 1 
		    else 0
		  end as PDF
		,(t4.full_date + 1) as FECHA_EJECUCION_DWH
		, t9.branch_code as CODE_SUCURSAL
		, sum(t1.transaction_delta_billed_premium_amount) as transaction_delta_billed_premium_amount
		, sum(t1.transaction_delta_commission_amount) as transaction_delta_commission_amount
		, t2.activity_type_description as TIPO_TRANSACCION
		, t2.activity_type as COD_TIPO_TRANSACCION
		, t2.risk_updated_by AS USUARIO_MOV
	from gde_adp_dwh_vw_general.vw_fact_policy_transaction_movement t1
	inner join gde_adp_dwh_vw_general.vw_dim_risk t2 on t1.risk_sk = t2.risk_sk AND t2.risk_sk <> -1  
	inner join gde_adp_dwh_vw_general.vw_dim_producer t3 on t1.producer_sk = t3.producer_sk AND t3.producer_sk <> -1
	inner join gde_adp_dwh_vw_general.vw_reference_accounting_period t4 on t1.transaction_date_sk = t4.date_sk and lower(t4.country) =  'colombia'
	inner join gde_adp_dwh_vw_general.vw_dim_product t7 on t1.product_sk = t7.product_sk AND t7.product_sk <> -1
	left join gde_adp_dwh_vw_general.vw_dim_lob t5 on t1.lob_sk = t5.lob_sk
	left join gde_adp_dwh_vw_general.vw_dim_customer t6 on t1.customer_sk = t6.customer_sk AND t6.customer_sk <> -1
	left join gde_adp_dwh_vw_general.vw_reference_code t8 on t7.product_code = t8.reference_code and t8.reference_code_type = 'SBU_Tecnica'
	left join gde_adp_dwh_vw_general.vw_dim_branch_office t9 on t1.branch_sk = t9.branch_sk AND t9.branch_sk <> -1
	left join gde_adp_dwh_vw_general.vw_dim_insured t11 on t1.insured_sk = t11.insured_sk AND t11.insured_sk <> -1
	left join gde_adp_dwh_vw_general.vw_dim_vehicle t12 on t1.vehicle_sk = t12.vehicle_sk
	left join non_gde_adp_dwh.dwh_dim_groupcode t13 on lower(t7.product_code) = lower(t13.product_code)
	where t1.current_record_flag = 1
	and lower(t1.source_system) in ('co_iaxis','co_as400')	
	and lower(t7.product_code) in ('1','2','10','17','19','22','6023','6024','6025','6026','6028','6029','6031','6033','6034','6035','6036','6038','6039','6041','6042','6043','6045','6046','6047','6048','6049','6052','6071','7467','7468','7469','8092','10000','10001','10003','10004','10005','10024','70107','70108','111715','900719','900720','900721','900730','900731','900742','900745','900746','900747','900751','900752','900753','900758','900774','900775','900776','900777','900778','900779','adu','bo','do1','e1','h1','la1','lb','lgp','rcl','rcm','rcp','reo','se','t1','trc','trm','z1')
	and t1.transaction_date_sk >= to_char(getdate() - 15, 'yyyymmdd')
	group by t2.risk_id
			, t3.producer_id
			, t7.product_code
			, t13.group_code
			, t6.customer_identification_number
			, t6.customer_first_name
			, t6.customer_middle_name
			, t6.customer_last_name
			, t5.lob_description
			, t2.risk_status_description
			, t2.risk_effective_date
			, t2.risk_expiration_date
			, t2.inception_date
			, t9.branch_name
			, t5.lob_code
			, t2.policy_number
			, t2.risk_number
			, t1.source_system
			, t4.accountable_period
			, t7.product_description
			, t6.customer_identification_number
			, t11.insured_first_name
			, t11.insured_middle_name
			, t11.insured_last_name
			, t12.vehicle_registration_number
			, t9.branch_code 
			, t2.activity_type
			, t2.activity_type_description
			, t2.origin_ts
			, t1.policy_sk
			, split_part(t1.audit_transaction_id,'-',1)
			, split_part(t1.audit_transaction_id,'-',4)
			, t11.insured_identification_number
			, t4.full_date
		    , t2.risk_updated_by;
    
	--Insercion de log de seguimiento
	insert into non_gde_adp_dwh.dwh_log_seguimiento_renewal
    select getdate() fecha_actual, producto, num_poliza, num_certificado_aseg, 1 step
    from #stg;
		   
	drop table if exists #repro;
	
	--Control de registros duplicados
	select * 
	into #repro 
	from #stg t1
	where not exists (select 1 from non_gde_adp_dwh.dwh_fact_query_renewal t2 where t2.producto = t1.producto and t2.num_poliza = t1.num_poliza and t2.certif_asegurado = t1.num_certificado_aseg and t2.recibo = t1.recibo AND t2.mov = t1.mov AND t2.mov_rec = t1.mov_rec);

	insert into non_gde_adp_dwh.dwh_fact_query_renewal_stg2 (sseguro_car, codramo, agente, producto, tipo_poliza, modalidad, agrupacion, newcore, iden_tomador, tipo_iden_tomador, nombre_tomador, ramo, num_certificado, num_poliza, estado_caratula, sucursal, fecha_inicio_car, fecha_vencimiento_car, fecha_emision_car, ano_periodo_contable_car, mes_periodo_contable_car, prima_emitida_car, prima_total_car, comision, des_producto, inden_asegurado, tipo_iden_asegurado, nombre_asegurado, num_certificado_aseg, sseguro_cert, placa, estado_cert, fecha_inicio_cert, fecha_vencimiento_cert, fecha_emision_cert, ano_periodo_contable_cert, mes_periodo_contable_cert, prima_emitida_cert, prima_total_cert, riesgos, policy_sk, recibo, mov, mov_rec, modificaciones, anulacion, renovacion_aut, slip_renovacion, estado_renovacion, prima_renovacion_car, prima_renovacion_cert, pdf, fecha_ejecucion_dwh, code_sucursal, transaction_delta_billed_premium_amount, transaction_delta_commission_amount, tipo_transaccion, cod_tipo_transaccion, usuario_mov)
	select sseguro_car, codramo, agente, producto, tipo_poliza, modalidad, agrupacion, newcore, iden_tomador, tipo_iden_tomador, nombre_tomador, ramo, num_certificado, num_poliza, estado_caratula, sucursal, fecha_inicio_car, fecha_vencimiento_car, fecha_emision_car, ano_periodo_contable_car, mes_periodo_contable_car, prima_emitida_car, prima_total_car, comision, des_producto, inden_asegurado, tipo_iden_asegurado, nombre_asegurado, num_certificado_aseg, sseguro_cert, placa, estado_cert, fecha_inicio_cert, fecha_vencimiento_cert, fecha_emision_cert, ano_periodo_contable_cert, mes_periodo_contable_cert, prima_emitida_cert, prima_total_cert, riesgos, policy_sk, recibo, mov, mov_rec, modificaciones, anulacion, renovacion_aut, slip_renovacion, estado_renovacion, prima_renovacion_car, prima_renovacion_cert, pdf, fecha_ejecucion_dwh, code_sucursal, transaction_delta_billed_premium_amount, transaction_delta_commission_amount, tipo_transaccion, cod_tipo_transaccion, usuario_mov	
	from #repro;
	
	drop table if exists #repro;

	--Insercion de log de seguimiento
	insert into non_gde_adp_dwh.dwh_log_seguimiento_renewal
    select getdate() fecha_actual, producto, num_poliza, num_certificado_aseg, 2 step
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2;
	
   	--Desde este punto se complementan los datos descargados de las vistas oficiales con las tablas de ODS. 
    --Actualizacion sucursal IAXIS
    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2 
    set sucursal = case when t3.branch_name not like reverse(substring(reverse('000' + t3.branch_code), 1,3)) + '%' then reverse(substring(reverse('000' + t3.branch_code), 1,3)) + '-' + t3.branch_name else t3.branch_name end,
        code_sucursal = t3.branch_code
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
    inner join (select t2.cagente, cast(t2.cpadre as bigint) as cpadre
                from (select cagente, max(fmovini) as fmovini
                      from gde_adp_ods.axis_redcomercial 
                      group by cagente) t1
                inner join gde_adp_ods.axis_redcomercial t2 on t1.cagente = t2.cagente and t1.fmovini = t2.fmovini) t2
          on cast(t1.agente as bigint) = cast(t2.cagente as bigint)
    inner join gde_adp_dwh_vw_general.vw_dim_branch_office t3
          on cast(right(cast(t2.cpadre as varchar(10)),3) as bigint) = t3.branch_code and lower(t3.source_system) = 'co_iaxis';
                    
    --Actualizacion primas e impuestos IAXIS
    drop table if exists #impuestos_axis;
    drop table if exists #prima_axis;
	drop table if exists #mov_rec;
	
	select distinct recibo, sseguro_cert, max(mov_rec) mov_rec  --desde aqui se comienza a calcular el valor de la prima
	into #mov_rec 
	from non_gde_adp_dwh.dwh_fact_query_renewal_stg2
	where newcore = 1
	group by recibo, sseguro_cert;
    
	select distinct sseguro_cert, c.recibo, sum(d.iconcep_monpol) prima, r.cestaux, a.descripcion, c.tipo_poliza, c.num_certificado_aseg
    into #prima_axis
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 c
    inner join gde_adp_ods.axis_recibos r on c.sseguro_cert = r.sseguro and c.recibo = r.nrecibo
    inner join gde_adp_ods.axis_detrecibos d on d.nrecibo = r.nrecibo and d.cconcep in (0)
    left join non_gde_adp_dwh.dwh_dim_admin_agrup a ON a.producto = c.producto
    where c.newcore = 1
	and exists (select 1 from #mov_rec m where m.recibo = c.recibo and m.sseguro_cert = c.sseguro_cert and m.mov_rec = c.mov_rec)
    group by sseguro_cert, c.recibo,r.cestaux, a.descripcion, c.tipo_poliza, c.num_certificado_aseg;
    
    --Certificado 0 de las polizas administradas colectivas debe tener prima 0
    update #prima_axis
    set prima = 0
    where cestaux = 2
    and descripcion = 'administrada'
    and tipo_poliza = 'C'
    and num_certificado_aseg = 0;
    
    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    set prima_emitida_cert = prima
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 c
    inner join #prima_axis p on p.sseguro_cert = c.sseguro_cert and c.recibo = p.recibo
    where c.newcore = 1;
    
    drop table if exists #recibos;

    select distinct recibo, sseguro_cert, producto, tipo_poliza, num_certificado_aseg
    into #recibos 
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    where newcore = 1;
	
   	--Obtencion de impuestos de los conceptos (4, 90, 88, 86, 14) ---Aqui se calcula los impuestos
	select distinct sseguro_cert, c.recibo, isnull(sum(d.iconcep_monpol),0) impuestos, r.cestaux, a.descripcion, c.tipo_poliza, c.num_certificado_aseg
    into #impuestos_axis
    from #recibos c
    inner join gde_adp_ods.axis_recibos r on c.sseguro_cert = r.sseguro and c.recibo = r.nrecibo
    left join gde_adp_ods.axis_detrecibos d on d.nrecibo = r.nrecibo and d.cconcep in (4, 90, 88, 86, 14)
    left join non_gde_adp_dwh.dwh_dim_admin_agrup a ON a.producto = c.producto    
    group by sseguro_cert, c.recibo,r.cestaux, a.descripcion, c.tipo_poliza, c.num_certificado_aseg;
	
   	--Certificado 0 de las polizas administradas colectivas debe tener impuestos 0
	update #impuestos_axis
    set impuestos = 0
    where cestaux = 2
    and descripcion = 'administrada'
    and tipo_poliza = 'C'
    and num_certificado_aseg = 0;
    
    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2    
	set prima_emitida_cert = abs(c.prima_emitida_cert)
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 c
    inner join #impuestos_axis p on p.sseguro_cert = c.sseguro_cert and c.recibo = p.recibo
    where c.newcore = 1;
    
   	--Primas totales
    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2  --Aqui se calcula el valor de la prima
    set prima_total_cert = (c.prima_emitida_cert + p.impuestos)
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 c
    inner join #impuestos_axis p on p.sseguro_cert = c.sseguro_cert and c.recibo = p.recibo
    where c.newcore = 1;
    
   	--Los recibos que posean el campo cestrec en 2 deben tener los valores de prima negativos
	update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
	set prima_emitida_cert = abs(t1.prima_emitida_cert) * -1,
		prima_total_cert = abs(t1.prima_total_cert) * -1
	from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
	inner join gde_adp_ods.axis_movrecibo t2 on t1.recibo = t2.nrecibo and t1.mov_rec = t2.smovrec and t2.cestrec = 2
	where t1.newcore = 1;
	
	--Los recibos que posean el campo ctiprec en 9 deben tener los valores de prima negativos
	update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
	set prima_emitida_cert = t1.prima_emitida_cert * -1,
		prima_total_cert = t1.prima_total_cert * -1
	from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
	inner join gde_adp_ods.axis_recibos t2 on t1.recibo = t2.nrecibo and t2.ctiprec = 9;
	
    --Primas certificado AS400
    drop table if exists #primas;
    
    select t1.producto, t1.num_poliza, t1.num_certificado, /*t1.code_sucursal,*/ t2.documento, t1.inden_asegurado, sum(vr_prima_pesos) prima_emitida, (sum(vr_prima_pesos) + sum(vr_iva_pesos)) prima_total
    into #primas
    from  non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1 
    inner join gde_adp_ods.as400_dwh_pol_aseg t2
            on t1.producto = t2.ramo_prod and t1.num_poliza = t2.poliza and t1.num_certificado = t2.certificado /*and t2.sucursal_prod = t1.code_sucursal*/ and t1.recibo = t2.documento AND t1.inden_asegurado = t2.nro_identifi_aseg
    where t1.newcore = 0
    group by t1.producto, t1.num_poliza, t1.num_certificado, /*t1.code_sucursal,*/ t2.documento, t1.inden_asegurado;
    
    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    set prima_emitida_cert = prima_emitida,
            prima_total_cert = prima_total
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
    inner join #primas t2
            on t1.producto = t2.producto and t1.num_poliza = t2.num_poliza and t1.num_certificado = t2.num_certificado and /*t2.code_sucursal = t1.code_sucursal and*/ t1.recibo = t2.documento AND t1.inden_asegurado = t2.inden_asegurado
    where t1.newcore = 0;
	
    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    set ano_periodo_contable_cert = substring(t3.accountable_period, 1, 4), 
    	mes_periodo_contable_cert = substring(t3.accountable_period, 5, 6)
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
    inner join gde_adp_ods.axis_movrecibo t2 on t1.recibo = t2.nrecibo and t1.mov_rec = t2.smovrec
    inner join gde_adp_dwh_vw_general.vw_reference_accounting_period t3 on t3.date_sk = to_char(t2.fcontab, 'yyyymmdd') and lower(t3.country) =  'colombia'
    where t1.newcore = 1;   
    
	--Borrado de registros en cero
	delete from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 where prima_emitida_cert = 0 and prima_total_cert = 0;
	
	--Log de inserciones
	insert into non_gde_adp_dwh.dwh_log_query_renewal
	select cast(getdate() AS date), fecha_ejecucion_dwh, count(1) 
	from non_gde_adp_dwh.dwh_fact_query_renewal_stg2
	group by fecha_ejecucion_dwh;	
	
	--Insercion de log de seguimiento
	insert into non_gde_adp_dwh.dwh_log_seguimiento_renewal
    select getdate() fecha_actual, producto, num_poliza, num_certificado_aseg, 3 step
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2;

    drop table if exists #final;
    drop table if exists #minimo;
    drop table if exists #renovaciones;
    drop table if exists #borrar;
    drop table if exists #borrarm;        
    
    --Actualizacion de campos de caratula
   	--Obtencion del minimo movimiento de la caratula de poliza el cual debe ser emision o renovacion
	select distinct t1.producto, t1.code_sucursal, t1.num_poliza, '1' as newcore
            , cast(t2.risk_number as bigint) as certificado_car, cast(split_part(t2.risk_id,'-',2) as bigint) as mov 
    into #minimo
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
    left join gde_adp_dwh_vw_general.vw_dim_risk t2
            on t2.policy_number = t1.num_poliza and t1.producto = t2.product_code AND t2.risk_number = 0
    where t2.activity_type in (0,2) 
    and lower(t2.source_system) in ('co_iaxis')
    union 
    select distinct t1.producto, t1.code_sucursal, t1.num_poliza, '0' as newcore         
        , cast(t2.risk_number AS bigint) as certificado_car, max(cast(split_part(t2.risk_id,'-',5) as bigint)) as mov
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
    left join gde_adp_dwh_vw_general.vw_dim_risk t2
            on t2.policy_number = t1.num_poliza and t1.producto = t2.product_code AND t1.code_sucursal = split_part(t2.risk_id,'-',1)
    where t2.activity_type in (0,1,2,7) 
    and lower(t2.source_system) in ('co_as400')
	and t1.newcore = 0
	group by t1.producto, t1.num_poliza, t1.code_sucursal, cast(t2.risk_number AS bigint);
    
	--Depuracion de registros
    select *
    into #borrarm
    from #minimo t1
    where exists (select 1 from #minimo t2 where t1.producto = t2.producto and t1.code_sucursal = t2.code_sucursal and t1.num_poliza = t2.num_poliza and t1.certificado_car > t2.certificado_car)
    and t1.newcore = '1'
    union
    select *    
    from #minimo t1
	where exists (select 1 from #minimo t2 where t1.producto = t2.producto and t1.code_sucursal = t2.code_sucursal and t1.num_poliza = t2.num_poliza and t1.mov < t2.mov)
    and t1.newcore = '0';
    
    delete from #minimo
    using  #borrarm
    where #minimo.producto = #borrarm.producto and #minimo.code_sucursal = #borrarm.code_sucursal and #minimo.num_poliza = #borrarm.num_poliza and #borrarm.certificado_car = #minimo.certificado_car and #borrarm.mov = #minimo.mov;
    
    insert into #borrarm
    select *
    from #minimo t1
    where exists (select 1 from #minimo t2 where t1.producto = t2.producto and t1.code_sucursal = t2.code_sucursal and t1.num_poliza = t2.num_poliza and t2.certificado_car = t1.certificado_car and t1.mov < t2.mov)
    and t1.newcore = '1'
    union
    select *
    from #minimo t1
	where exists (select 1 from #minimo t2 where t1.producto = t2.producto and t1.code_sucursal = t2.code_sucursal and t1.num_poliza = t2.num_poliza and t1.certificado_car > t2.certificado_car)
    and t1.newcore = '0';
         
    delete from #minimo
    using  #borrarm
    where #minimo.producto = #borrarm.producto and #minimo.code_sucursal = #borrarm.code_sucursal and #minimo.num_poliza = #borrarm.num_poliza and #borrarm.certificado_car = #minimo.certificado_car and #borrarm.mov = #minimo.mov;
            
	
    select distinct t1.producto, t1.code_sucursal, t1.num_poliza, t1.newcore, t1.certificado_car, t1.mov, '0' as activity_type, sum(t2.prima_emitida_cert) as prima_emitida_car, sum(t2.prima_total_cert) as prima_total_car 
    into #final
    from #minimo t1
    left join non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t2
            on t1.producto = t2.producto and t1.code_sucursal = t2.code_sucursal and t1.num_poliza = t2.num_poliza and t1.certificado_car = t2.num_certificado and cast(t2.mov as int) >= t1.mov
    group by t1.producto, t1.code_sucursal, t1.num_poliza, t1.certificado_car, t1.mov, t1.newcore;
    
   	--Actualizacion de los valores de la caratula de la poliza IAXIS
    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    set sseguro_car = split_part(t3.risk_id,'-',1),
        estado_caratula = case when t3.risk_status_description = 'Cancelado' then 'Anulada' else t3.risk_status_description end,
        fecha_inicio_car = t8.fefecto, 
        fecha_vencimiento_car =  t6.fcaranu,
        fecha_emision_car = t8.fmovimi,
        ano_periodo_contable_car =  substring(t7.accountable_period, 1, 4),
        mes_periodo_contable_car = substring(t7.accountable_period, 5, 6),
        prima_emitida_car = isnull(t2.prima_emitida_car,0),
        prima_total_car = isnull(t2.prima_total_car,0)
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1 
    inner join #final t2 on t1.producto = t2.producto and t1.num_poliza = t2.num_poliza and t1.code_sucursal = t2.code_sucursal
    inner join gde_adp_dwh_vw_general.vw_dim_risk t3 on t3.policy_number = t1.num_poliza and t1.producto = t3.product_code and t3.risk_number = t2.certificado_car and split_part(t3.risk_id,'-',2) = t2.mov
    inner join gde_adp_ods.axis_seguros t6 on t6.sseguro = cast(split_part(t3.risk_id,'-',1) as int)
    inner join gde_adp_ods.axis_movseguro t8 on t8.sseguro = t6.sseguro AND t8.nmovimi = t2.mov
    inner join gde_adp_dwh_vw_general.vw_reference_accounting_period t7 on t7.date_sk = to_char(t8.fmovimi, 'yyyymmdd') and lower(t7.country) =  'colombia'        
    where t2.newcore = '1';
        
   	--Actualizacion de los valores de la caratula de la poliza AS400
    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    set sseguro_car = '',
        estado_caratula = case when t2.activity_type = '4' then 'Anulada' else 'Vigente' end,
        fecha_inicio_car = cast(t5.fi_certificado as date),
        fecha_vencimiento_car = cast(t5.ff_certificado as date),
        fecha_emision_car = cast(t5.fecha_expe as date),
        ano_periodo_contable_car =  substring(t6.accountable_period, 1, 4),
        mes_periodo_contable_car = substring(t6.accountable_period, 5, 6),
        prima_emitida_car = isnull(t2.prima_emitida_car,0),
        prima_total_car = isnull(t2.prima_total_car,0)
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1     
    inner join #final t2 on t1.producto = t2.producto and t1.num_poliza = t2.num_poliza and t1.code_sucursal = t2.code_sucursal
    inner join gde_adp_dwh_vw_general.vw_dim_risk t3 on t3.policy_number = t1.num_poliza and t1.producto = t3.product_code and t3.risk_number = t2.certificado_car AND split_part(t3.risk_id,'-',5) = t2.mov
    inner join gde_adp_ods.as400_dwh_pol_n01 t5 on t5.poliza = t1.num_poliza and t2.certificado_car = t5.certificado and t5.documento = t2.mov and t5.ramo_prod = t2.producto
    inner join gde_adp_dwh_vw_general.vw_reference_accounting_period t6 on t6.date_sk = to_char(cast(t5.fecha_expe AS date), 'yyyymmdd') and lower(t6.country) =  'colombia'
    where t2.newcore = '0';     
	
   --Actualizacion campos certificado
    drop table if exists #max_risk;
   
    --Obtencion del maximo movimiento del certificado de poliza el cual debe ser emision o renovacion
    select distinct t1.producto, t1.code_sucursal, t1.num_poliza, '1' as newcore
               ,cast(t2.risk_number as bigint) as certificado_cert, max(cast(split_part(t2.risk_id,'-',2) as bigint)) as mov
    into #max_risk
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
    inner join gde_adp_dwh_vw_general.vw_dim_risk t2
            on t2.policy_number = t1.num_poliza and t1.producto = t2.product_code AND t1.num_certificado = t2.risk_number
    where t2.activity_type in (0,2)
    and lower(t2.source_system) in ('co_iaxis')
    group by  producto, code_sucursal, num_poliza, t2.source_system, t2.risk_number
    union 
    select distinct t1.producto, t1.code_sucursal, t1.num_poliza, '0' as newcore
               ,cast(t2.risk_number as bigint) as certificado_cert, max(cast(split_part(t2.risk_id,'-',5) as bigint)) as mov
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
    inner join gde_adp_dwh_vw_general.vw_dim_risk t2
            on t2.policy_number = t1.num_poliza and t1.producto = t2.product_code AND t1.num_certificado = t2.risk_number AND t1.code_sucursal = split_part(t2.risk_id,'-',1)
    where t2.activity_type in (0,2,7)
    and lower(t2.source_system) in ('co_as400')
    group by producto, code_sucursal, num_poliza, t2.source_system, t2.risk_number;
    
   	--Actualizacion de los valores del certificado de la poliza IAXIS
    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    set fecha_inicio_cert = t5.fefecto,
            fecha_vencimiento_cert = t4.fcaranu,
            fecha_emision_cert = t5.fmovimi
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
    inner join #max_risk t2 on t1.num_poliza = t2.num_poliza and t1.producto = t2.producto and t1.code_sucursal = t2.code_sucursal and t1.num_certificado = t2.certificado_cert    
    inner join gde_adp_ods.axis_seguros t4 on t4.sseguro = t1.sseguro_cert
    inner join gde_adp_ods.axis_movseguro t5 on t5.sseguro = t4.sseguro AND t5.nmovimi = t2.mov
    where t1.newcore = '1';
    
   	--Actualizacion de los valores del certificado de la poliza AS400
    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
	set fecha_inicio_cert = cast(t4.fi_certificado as date),
		fecha_vencimiento_cert = cast(t4.ff_certificado as date),
		fecha_emision_cert = cast(t4.fecha_expe as date)
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1 
    inner join #max_risk t2 on t1.producto = t2.producto and t1.num_poliza = t2.num_poliza and t1.code_sucursal = t2.code_sucursal and t1.num_certificado = t2.certificado_cert    
    inner join gde_adp_ods.as400_dwh_pol_n01 t4 on t4.poliza = t1.num_poliza and t2.certificado_cert = t4.certificado and t4.documento = t2.mov AND t4.ramo_prod = t2.producto
    where t2.newcore = '0';
    
    --primas caratula as400
    drop table if exists #primas_car;
    
    select t1.producto, t1.num_poliza, t1.certificado_car, t1.code_sucursal, t2.documento, sum(vr_prima_pesos) prima_emitida, (sum(vr_prima_pesos) + sum(vr_iva_pesos)) prima_total
    into #primas_car
    from  #final t1 
    inner join gde_adp_ods.as400_dwh_pol_n01 t2
            on t1.producto = t2.ramo_prod and t1.num_poliza = t2.poliza and t1.certificado_car = t2.certificado and t2.sucursal_prod = t1.code_sucursal AND t1.mov = t2.documento
    where t1.newcore = 0
    group by t1.producto, t1.num_poliza, t1.certificado_car, t1.code_sucursal, t2.documento;
    
    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    set prima_emitida_car = prima_emitida,
            prima_total_car = prima_total
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
    inner join #primas_car t2
            on t1.producto = t2.producto and t1.num_poliza = t2.num_poliza and t2.code_sucursal = t1.code_sucursal 
    where t1.newcore = 0;
    
   	--Certificado cero para los movimientos sin recibo
	drop table if exists #cero;
	
	select distinct sseguro_car, codramo, agente, producto, tipo_poliza, modalidad, agrupacion, newcore, iden_tomador, tipo_iden_tomador, nombre_tomador, ramo, NULL num_certificado, 
	num_poliza, NULL estado_caratula, sucursal, fecha_inicio_car, fecha_vencimiento_car, fecha_emision_car, ano_periodo_contable_car, mes_periodo_contable_car, prima_emitida_car, 
	prima_total_car, comision, des_producto, '' inden_asegurado, '' tipo_iden_asegurado, '' nombre_asegurado, 0 num_certificado_aseg, sseguro_car sseguro_cert, '' placa, NULL estado_cert, fecha_inicio_car fecha_inicio_cert, 
	fecha_vencimiento_car fecha_vencimiento_cert, fecha_emision_car fecha_emision_cert, ano_periodo_contable_car ano_periodo_contable_cert, mes_periodo_contable_car mes_periodo_contable_cert, 0 prima_emitida_cert, 0 prima_total_cert, 
	'' riesgos, NULL recibo, 1 mov, NULL mov_rec, estado_renovacion,  pdf, 'Nueva producción' tipo_transaccion, 0 cod_tipo_transaccion, getdate() fecha_ejecucion_dwh, (getdate() - 1) fecha_actualizacion, CAST(NULL AS VARCHAR(60)) usuario_mov
	into #cero
	from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1 
	where not exists (select 1 from non_gde_adp_dwh.dwh_fact_query_renewal t2 where t2.producto = t1.producto and t2.num_poliza = t1.num_poliza and t2.certif_asegurado = 0)
	and t1.num_certificado_aseg = (select max(num_certificado_aseg) from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t3 where t3.producto = t1.producto and t3.num_poliza = t1.num_poliza)
	and t1.newcore = 1
	and t1.num_certificado_aseg <> 0;
	
	update #cero
	set fecha_ejecucion_dwh = '1990-01-01';
	
	update #cero
	set usuario_mov = cusumov
	from #cero t1
	inner join gde_adp_ods.axis_movseguro t2 ON t1.sseguro_cert = t2.sseguro AND t1.mov = t2.nmovimi
	where t1.newcore = 1;
	
	insert into non_gde_adp_dwh.dwh_fact_query_renewal_stg2 (sseguro_car, codramo, agente, producto, tipo_poliza, modalidad, agrupacion, newcore, iden_tomador, tipo_iden_tomador, nombre_tomador, ramo, num_certificado, num_poliza, estado_caratula, sucursal, fecha_inicio_car, fecha_vencimiento_car, fecha_emision_car, ano_periodo_contable_car, mes_periodo_contable_car, prima_emitida_car, prima_total_car, comision, des_producto, inden_asegurado, tipo_iden_asegurado, nombre_asegurado, num_certificado_aseg, sseguro_cert, placa, estado_cert, fecha_inicio_cert, fecha_vencimiento_cert, fecha_emision_cert, ano_periodo_contable_cert, mes_periodo_contable_cert, prima_emitida_cert, prima_total_cert, riesgos, recibo, mov, mov_rec, estado_renovacion, pdf, tipo_transaccion, cod_tipo_transaccion, fecha_ejecucion_dwh, usuario_mov)
	select sseguro_car, codramo, agente, producto, tipo_poliza, modalidad, agrupacion, newcore, iden_tomador, tipo_iden_tomador, nombre_tomador, ramo, num_certificado, num_poliza, estado_caratula, sucursal, fecha_inicio_car, fecha_vencimiento_car, fecha_emision_car, ano_periodo_contable_car, mes_periodo_contable_car, prima_emitida_car, prima_total_car, comision, des_producto, inden_asegurado, tipo_iden_asegurado, nombre_asegurado, num_certificado_aseg, sseguro_cert, placa, estado_cert, fecha_inicio_cert, fecha_vencimiento_cert, fecha_emision_cert, ano_periodo_contable_cert, mes_periodo_contable_cert, prima_emitida_cert, prima_total_cert, riesgos, recibo, mov, mov_rec, estado_renovacion, pdf, tipo_transaccion, cod_tipo_transaccion, fecha_ejecucion_dwh, usuario_mov
	from #cero;
   
    --Estado_renovacion
    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    set estado_renovacion = 'managerenewal'
    where codramo <> 104;    
   
    --Actualizacion riesgos
    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    set riesgos = case when t3.policy_item_type = '1' then cast(t1.iden_tomador as varchar(200))
                                       when t3.policy_item_type in ('2','3') then cast(t3.location_address_1 as varchar(200))
                                       when t3.policy_item_type = '5' then cast(t1.placa as varchar(200))
                                       else ''
                              end
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
    inner join gde_adp_dwh_vw_general.vw_dim_risk t2 on t1.policy_sk = t2.policy_sk and t2.risk_number = t1.num_certificado_aseg
    inner join gde_adp_dwh_vw_general.vw_dim_policy_item t3 on t1.policy_sk = t3.policy_sk AND t2.risk_sk = t3.risk_sk;
    
    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    set riesgos = cast(tdomici as varchar(166)) + ' ' + cast(tpoblac as varchar(15))+ ' - ' + cast(tprovin as varchar(15))
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
    inner join gde_adp_ods.axis_sitriesgo t2 on t1.sseguro_cert = t2.sseguro
    inner join gde_adp_ods.axis_poblaciones t3 on t2.cpoblac = t3.cpoblac and t2.cprovin = t3.cprovin
    inner join gde_adp_ods.axis_provincias t4 on t2.cprovin = t4.cprovin
    WHERE t1.newcore = '1';
    
   	--El regiso para las poliza de auto individual es la placa del vehiculo 
    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    set riesgos = cast(placa as varchar(200))
    where ramo = 'AUTOS INDIVIDUAL' and (riesgos is null or riesgos = '');
    
    --Actualizacion de la comision de acuerdo a la definicion del area IAXIS
    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    set comision = round(cast(comision as float),2);
    
    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    set comision = case when comision like '%.%' then split_part(comision,'.',1) + '.' + cast(split_part(comision,'.',2) as char(2)) else comision end;             

    drop table if exists #comis;
    
    select distinct codramo, producto, num_poliza, code_sucursal, comision
    into #comis
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    where comision <> 0;
    
    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    set comision = t2.comision
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
    inner join #comis t2 on t1.codramo = t2.codramo and t1.producto = t2.producto and t1.num_poliza = t2.num_poliza and t1.code_sucursal = t2.code_sucursal;       
    
    drop table if exists #comis_axis;

	select qr.sseguro_cert, pcomisi
	into #comis_axis
	from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 qr
	inner join gde_adp_ods.axis_seguros s on qr.sseguro_cert = s.sseguro 
	inner join gde_adp_ods.axis_comisionsegu c on c.sseguro=s.sseguro 
	and s.nanuali between nvl(c.ninialt,0) and nvl(c.nfinalt,0)
	and c.nmovimi = (select max(nmovimi) from gde_adp_ods.axis_comisionsegu c2 where c2.sseguro=s.sseguro)
	where s.ctipcom in (90,92)
	and qr.newcore = '1'
	union 
	select qr.sseguro_cert, cp.pcomisi 
	from  non_gde_adp_dwh.dwh_fact_query_renewal_stg2 qr
	inner join gde_adp_ods.axis_seguros s on qr.sseguro_cert = s.sseguro 
	inner join gde_adp_ods.axis_comisionvig_agente vg on vg.cagente = s.cagente 
	inner join gde_adp_ods.axis_codicomisio c on c.ccomisi = vg.ccomisi and c.ctipo = 1 and vg.ffinvig is null
	inner join gde_adp_ods.axis_comisionvig v on v.ccomisi = c.ccomisi and v.cestado = 2 and v.ffinvig is null
	inner join gde_adp_ods.axis_descomision d on d.ccomisi = c.ccomisi and d.cidioma = 8
	inner join gde_adp_ods.axis_comisionprod cp on cp.ccomisi = c.ccomisi and cp.sproduc = s.sproduc and  s.nanuali between nvl(cp.ninialt,0) and nvl(cp.nfinalt,0) 
	where nvl(s.ctipcom,0) = 0
	and qr.newcore = '1';
	
	update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
	set comision = t2.pcomisi
	from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
	inner join #comis_axis t2 on t1.sseguro_cert = t2.sseguro_cert;
	
	--Libera espacio tempdb
    drop table if exists #impuestos_axis;
    drop table if exists #prima_axis;
    drop table if exists #primas;
    drop table if exists #final;
    drop table if exists #minimo;
    drop table if exists #renovaciones;
    drop table if exists #borrar;
    drop table if exists #borrarm;
    drop table if exists #max_risk;
    drop table if exists #primas_car;
    drop table if exists #pol;
    drop table if exists #pol2;
    drop table if exists #comis;
    drop table if exists #estado;
    drop table if exists #comis_axis;
    
     --Actualizacion de datos generales de IAXIS
    drop table if exists #upd_axis;
    
    select *
    into #upd_axis
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    where newcore = 1;       
            
    --Actualizacion datos asegurado y tomador AXIS
    update #upd_axis        
     set iden_tomador = case when (t1.iden_tomador = '' or t1.iden_tomador is null) then cast(t4.nnumide as varchar(20)) else t1.iden_tomador end,
        tipo_iden_tomador = case when t4.ctipide = 0 then 'I.S.'
                                 when t4.ctipide IN (24,40) then 'P.P.'
                                 when t4.ctipide = 33 then 'C.E.'
                                 when t4.ctipide = 34 then 'T.I.'
                                 when t4.ctipide = 35 then 'R.C.'
                                 when t4.ctipide = 36 then 'C.C.'
                                 when t4.ctipide = 37 then 'NIT'
                                 when t4.ctipide = 38 then 'N.U.I.P.'
                                 when t4.ctipide = 43 then 'BIC'
                                 when t4.ctipide = 44 then 'C.D.'
                                 when t4.ctipide = 45 then 'NIT E.'
                                 when t4.ctipide = 46 then 'P.E.P.'
                                 when t4.ctipide = 47 then 'PECP'
                                 when t4.ctipide = 48 then 'P.P.T.'
                                 when t4.ctipide = 99 then 'I.SIM.'
                                 else ''
                             end,
        nombre_tomador = case when (t1.nombre_tomador = '' or t1.nombre_tomador is null) then rtrim(ltrim(coalesce(t3.tapelli1,'')||' '||coalesce(t3.tapelli2,'')||' '||coalesce(t3.tnombre1,''))) else t1.nombre_tomador end 
    from #upd_axis t1 
    inner join gde_adp_ods.axis_tomadores t2
            on t2.sseguro = t1.sseguro_cert
    inner join gde_adp_ods.axis_per_detper t3
            on t3.sperson = t2.sperson
    inner join gde_adp_ods.axis_per_personas t4
            on t4.sperson = t3.sperson and (case when t1.iden_tomador is not null or t1.iden_tomador <> '' then t4.nnumide = t1.iden_tomador else t4.nnumide = t4.nnumide end)
    where t1.newcore = 1;
    
    update #upd_axis
    set inden_asegurado = case when (t1.inden_asegurado = '' or t1.inden_asegurado is null) then cast(t4.nnumide as varchar(20)) else t1.inden_asegurado end,
        tipo_iden_asegurado = case when t4.ctipide = 0 then 'I.S.'
                                 when t4.ctipide IN (24,40) then 'P.P.'
                                 when t4.ctipide = 33 then 'C.E.'
                                 when t4.ctipide = 34 then 'T.I.'
                                 when t4.ctipide = 35 then 'R.C.'
                                 when t4.ctipide = 36 then 'C.C.'
                                 when t4.ctipide = 37 then 'NIT'
                                 when t4.ctipide = 38 then 'N.U.I.P.'
                                 when t4.ctipide = 43 then 'BIC'
                                 when t4.ctipide = 44 then 'C.D.'
                                 when t4.ctipide = 45 then 'NIT E.'
                                 when t4.ctipide = 46 then 'P.E.P.'
                                 when t4.ctipide = 47 then 'PECP'
                                 when t4.ctipide = 48 then 'P.P.T.'
                                 when t4.ctipide = 99 then 'I.SIM.'
                                 else ''
                             end,
        nombre_asegurado = case when (t1.nombre_asegurado = '' or t1.nombre_asegurado is null) then ltrim(rtrim(coalesce(t3.tapelli1,'')||' '||coalesce(t3.tapelli2,'')||' '||coalesce(t3.tnombre1,''))) else t1.nombre_asegurado end 
    from #upd_axis t1
    inner join gde_adp_ods.axis_asegurados t2
            on t2.sseguro = t1.sseguro_cert
    inner join gde_adp_ods.axis_per_detper t3
            on t3.sperson = t2.sperson
    inner join gde_adp_ods.axis_per_personas t4
            on t4.sperson = t3.sperson and (case when t1.inden_asegurado is not null or t1.inden_asegurado <> '' then t4.nnumide = t1.inden_asegurado else t4.nnumide = t4.nnumide end)
    where t1.newcore = 1;    
    
    update #upd_axis
    set tipo_iden_asegurado = case when t4.ctipide = 0 then 'I.S.'
                                   when t4.ctipide IN (24,40) then 'P.P.'
                                   when t4.ctipide = 33 then 'C.E.'
                                   when t4.ctipide = 34 then 'T.I.'
                                   when t4.ctipide = 35 then 'R.C.'
                                   when t4.ctipide = 36 then 'C.C.'
                                   when t4.ctipide = 37 then 'NIT'
                                   when t4.ctipide = 38 then 'N.U.I.P.'
                                   when t4.ctipide = 43 then 'BIC'
                                   when t4.ctipide = 44 then 'C.D.'
                                   when t4.ctipide = 45 then 'NIT E.'
                                   when t4.ctipide = 46 then 'P.E.P.'
                                   when t4.ctipide = 47 then 'PECP'
                                   when t4.ctipide = 48 then 'P.P.T.'
                                   when t4.ctipide = 99 then 'I.SIM.'
                                   else ''
                              end
    from #upd_axis t1
    inner join gde_adp_ods.axis_per_personas t4
            on t1.inden_asegurado = t4.nnumide
    where t1.newcore = 1; 
               
    --Actualización modalidad IAXIS
    drop table if exists #modalidad;
    create table #modalidad
    (
            producto	varchar(10),
            pregunta	int
    );
    
    insert into #modalidad values('900742', 6117);
    insert into #modalidad values('900753', 9235);
    insert into #modalidad values('10024', 6117);
    insert into #modalidad values('900745', 9816);
    insert into #modalidad values('70107', 9343);
    insert into #modalidad values('7468', 9929);
    insert into #modalidad values('7469', 9929);
    insert into #modalidad values('6024', 4816); 
    insert into #modalidad values('900731', 9890);
    insert into #modalidad values('70108', 9878);
    insert into #modalidad values('900719', 9623);
    insert into #modalidad values('900720', 7988);
    insert into #modalidad values('900744', 9855);
    insert into #modalidad values('900751', 9691);
    insert into #modalidad values('900775', 9623);
    insert into #modalidad values('900752', 9623);
    insert into #modalidad values('111715', 9623);
    
    update #upd_axis
    set modalidad = t2.crespue
    from gde_adp_ods.axis_seguros t
    inner join #upd_axis t1
            on t.npoliza = t1.num_poliza and t.sproduc = t1.producto
    inner join gde_adp_ods.axis_pregunseg t2
            on t.sseguro = t2.sseguro
    inner join #modalidad t3
            on t2.cpregun = t3.pregunta and t3.producto = t.sproduc
    where t1.newcore = 1;
    
    update #upd_axis
    set modalidad = t2.crespue
    from gde_adp_ods.axis_seguros t
    inner join #upd_axis t1
            on t.npoliza = t1.num_poliza and t.sproduc = t1.producto
    inner join gde_adp_ods.axis_pregunpolseg t2
            on t.sseguro = t2.sseguro
    inner join #modalidad t3
            on t2.cpregun = t3.pregunta and t3.producto = t.sproduc
    where t1.newcore = 1;
    
    update #upd_axis
    set modalidad = t2.cmodalidad
    from gde_adp_ods.axis_seguros t
    inner join #upd_axis t1
            on t.npoliza = t1.num_poliza and t.sproduc = t1.producto
    inner join gde_adp_ods.axis_riesgos t2
            on t.sseguro = t2.sseguro
    where t1.producto in (900721, 7467)
    and t1.newcore = 1;
    
    update #upd_axis
    set modalidad = 0
    where producto = 8092
    and newcore = 1;
    
    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    set sucursal = t2.sucursal,
            code_sucursal = t2.code_sucursal,
            iden_tomador = t2.iden_tomador,
            tipo_iden_tomador = t2.tipo_iden_tomador,
            nombre_tomador = t2.nombre_tomador,
            inden_asegurado = t2.inden_asegurado,
            tipo_iden_asegurado = t2.tipo_iden_asegurado,
            nombre_asegurado = t2.nombre_asegurado,
            modalidad = t2.modalidad
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
    inner join #upd_axis t2 on t1.id = t2.id;
            
    drop table if exists #upd_axis;
    drop table if exists #modalidad;
    
    --Actualizacion de datos generales de AS400
    drop table if exists #upd_as400;
    
    select *
    into #upd_as400
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    where newcore = 0;
    
    --Actualizacion de estado de caratula y certificado
    update #upd_as400
    set estado_caratula = case when fecha_vencimiento_car < getdate() then 'Vencida' else 'Vigente' end,
        estado_cert = case when fecha_vencimiento_cert < getdate() then 'Vencida' else 'Vigente' end
    where newcore = 0;
   
	--Actualizacion tipo poliza
	update #upd_as400
	set tipo_poliza = upper(t2.tipo_poliza)
	from #upd_as400 t1
	inner join gde_adp_ods.as400_dwh_pol_n01 t2 on t1.num_poliza = t2.poliza and t2.ramo_prod = t1.producto and t1.num_certificado_aseg = t2.certificado and t1.mov = documento and t1.code_sucursal = t2.sucursal_prod;
 	
 	--Actualizacion comision AS400
	update #upd_as400
	set comision = vr_p_c_inter_lider
	from #upd_as400 t1
	inner join gde_adp_ods.as400_dwh_pol_n01 t2 on t1.num_poliza = t2.poliza and t2.ramo_prod = t1.producto and t1.num_certificado_aseg = t2.certificado and t1.mov = documento and t1.code_sucursal = t2.sucursal_prod
 	where (t1.comision is null or t1.comision = '' or t1.comision = '0');				 
 
    --Actualizacion información del asegurado AS400
    update #upd_as400
    set tipo_iden_asegurado = case when t3.tipo_identifi_clie = 'C' then 'C.C.'
                                   when t3.tipo_identifi_clie = 'E' then 'C.E.'
                                   when t3.tipo_identifi_clie IN ('N','I') then 'NIT'
                                   when t3.tipo_identifi_clie = 'T' then 'T.I.'
                                   when t3.tipo_identifi_clie = 'R' then 'R.C.'
                                   when t3.tipo_identifi_clie = 'P' then 'P.P.'
                                   else ''
                              end, 
            inden_asegurado = t3.nro_identifi_clie,
            nombre_asegurado = ltrim(rtrim(coalesce(coalesce(t3.razon_social, t3.apellido_1),'')||' '||coalesce(t3.nombre_1,'')))
    from  #upd_as400 t1 
    inner join gde_adp_ods.as400_dwh_pol_aseg t2
            on t1.producto = t2.ramo_prod and t1.num_poliza = t2.poliza and t1.num_certificado_aseg = t2.certificado and t2.sucursal_prod = t1.code_sucursal AND t1.mov = t2.documento AND t1.inden_asegurado = t2.nro_identifi_aseg
    inner join gde_adp_ods.as400_dwh_clientes t3
            on t3.tipo_identifi_clie = t2.tipo_identifi_aseg and t3.nro_identifi_clie = t2.nro_identifi_aseg
    where t1.newcore = 0
    and (t1.nombre_asegurado = '' or t1.nombre_asegurado is null or t1.tipo_iden_asegurado = '' or t1.tipo_iden_asegurado is NULL or t1.inden_asegurado = '' OR t1.inden_asegurado IS NULL);
    
    
    update #upd_as400 
    set tipo_iden_asegurado = case when t2.tipo_identifi_clie = 'C' then 'C.C.'
                                   when t2.tipo_identifi_clie = 'E' then 'C.E.'
                                   when t2.tipo_identifi_clie IN ('N','I') then 'NIT'
                                   when t2.tipo_identifi_clie = 'T' then 'T.I.'
                                   when t2.tipo_identifi_clie = 'R' then 'R.C.'
                                   when t2.tipo_identifi_clie = 'P' then 'P.P.'
                                   else ''
                              END,
            nombre_asegurado = case when (t1.nombre_asegurado = '' or t1.nombre_asegurado is null) then ltrim(rtrim(coalesce(coalesce(t2.razon_social, t2.apellido_1),'')||' '||coalesce(t2.nombre_1,''))) else t1.nombre_asegurado end
    from #upd_as400 t1
    inner join gde_adp_ods.as400_dwh_clientes t2
            on t1.inden_asegurado =t2.nro_identifi_clie and t2.tipo_identifi_clie in ('C','E','N','I','T','R','P')
    where (t1.nombre_asegurado = '' or t1.nombre_asegurado is null or t1.tipo_iden_asegurado = '' or t1.tipo_iden_asegurado is null)
    and t1.newcore = 0;
    
    update #upd_as400 
    set nombre_asegurado = ltrim(rtrim(coalesce(coalesce(t2.razon_social, t2.apellido_1),'')||' '||coalesce(t2.nombre_1,'')))--t2.razon_social
    from #upd_as400 t1
    inner join gde_adp_ods.as400_dwh_clientes t2
            on t1.inden_asegurado =t2.nro_identifi_clie
    where (t1.nombre_asegurado = '' or t1.nombre_asegurado is null)
    and t1.newcore = 0;
    
    update #upd_as400 
    set nombre_asegurado  = ltrim(rtrim(coalesce(replace(t2.bi4ma, chr(46),''),'')||' '||coalesce(t2.bpka,'')))
    from #upd_as400 t1
    inner join gde_adp_ods.as400_bifclien t2
            on t2.bciden = t1.inden_asegurado
    where (t1.nombre_asegurado = '' or t1.nombre_asegurado is null)
    and t1.newcore = 0;    
    
    update #upd_as400 
    set     iden_tomador = t2.nro_identifi_tom, 
            tipo_iden_tomador = case when t2.tipo_identifi_tom = 'C' then 'C.C.'
                                   when t2.tipo_identifi_tom = 'E' then 'C.E.'
                                   when t2.tipo_identifi_tom IN ('N','I') then 'NIT'
                                   when t2.tipo_identifi_tom = 'T' then 'T.I.'
                                   when t2.tipo_identifi_tom = 'R' then 'R.C.'
                                   when t2.tipo_identifi_tom = 'P' then 'P.P.'
                                   else ''
                              end,
            nombre_tomador = ltrim(rtrim(coalesce(coalesce(t3.razon_social, t3.apellido_1),'')||' '||coalesce(t3.nombre_1,'')))
    from  #upd_as400 t1 
    inner join gde_adp_ods.as400_dwh_pol_n01 t2
            on t1.producto = t2.ramo_prod and t1.num_poliza = t2.poliza and t1.num_certificado_aseg = t2.certificado and t2.sucursal_prod = t1.code_sucursal
    inner join gde_adp_ods.as400_dwh_clientes t3
                    on t3.tipo_identifi_clie = t2.tipo_identifi_tom and t2.nro_identifi_tom = substring(t3.nro_identifi_clie,1,9)
    where t1.newcore = 0 AND t3.tipo_identifi_clie = 'N';
    
    update #upd_as400 
    set     iden_tomador = t2.nro_identifi_tom, 
            tipo_iden_tomador = case when t2.tipo_identifi_tom = 'C' then 'C.C.'
                                   when t2.tipo_identifi_tom = 'E' then 'C.E.'
                                   when t2.tipo_identifi_tom IN ('N','I') then 'NIT'
                                   when t2.tipo_identifi_tom = 'T' then 'T.I.'
                                   when t2.tipo_identifi_tom = 'R' then 'R.C.'
                                   when t2.tipo_identifi_tom = 'P' then 'P.P.'
                                   else ''
                              end,
            nombre_tomador = ltrim(rtrim(coalesce(coalesce(t3.razon_social, t3.apellido_1),'')||' '||coalesce(t3.nombre_1,'')))
    from  #upd_as400 t1 
    inner join gde_adp_ods.as400_dwh_pol_n01 t2
            on t1.producto = t2.ramo_prod and t1.num_poliza = t2.poliza and t1.num_certificado_aseg = t2.certificado and t2.sucursal_prod = t1.code_sucursal
    inner join gde_adp_ods.as400_dwh_clientes t3
                    on t3.tipo_identifi_clie = t2.tipo_identifi_tom and t2.nro_identifi_tom = t3.nro_identifi_clie
    where t1.newcore = 0;        
    
    update #upd_as400
    set     iden_tomador = t2.nro_identifi_tom, 
            tipo_iden_tomador = case when t2.tipo_identifi_tom = 'C' then 'C.C.'
                                   when t2.tipo_identifi_tom = 'E' then 'C.E.'
                                   when t2.tipo_identifi_tom IN ('N','I') then 'NIT'
                                   when t2.tipo_identifi_tom = 'T' then 'T.I.'
                                   when t2.tipo_identifi_tom = 'R' then 'R.C.'
                                   when t2.tipo_identifi_tom = 'P' then 'P.P.'
                                   else ''
                              end,
            nombre_tomador = ltrim(rtrim(coalesce(replace(t3.bi4ma, chr(46),''),'')||' '||coalesce(t3.bpka,'')))
    from  #upd_as400 t1
    inner join gde_adp_ods.as400_dwh_pol_n01 t2
            on t1.producto = t2.ramo_prod and t1.num_poliza = t2.poliza and t1.num_certificado_aseg = t2.certificado and t2.sucursal_prod = t1.code_sucursal
    inner join gde_adp_ods.as400_bifclien  t3
            on t3.s13z6ma = t2.tipo_identifi_tom and t3.bciden= t2.nro_identifi_tom
    where t1.newcore = 0 and t1.iden_tomador is null;
         
    update #upd_as400 
    set nombre_tomador = ltrim(rtrim(coalesce(coalesce(t2.razon_social, t2.apellido_1),'')||' '||coalesce(t2.nombre_1,''))) --t2.razon_social
    from #upd_as400 t1
    inner join gde_adp_ods.as400_dwh_clientes t2
            on t1.iden_tomador = substring(t2.nro_identifi_clie,1,9)
    where (t1.nombre_tomador = '' or t1.nombre_tomador is null)
    and t1.newcore = 0
    and t1.tipo_iden_tomador = 'NIT';
    
    update #upd_as400 
    set nombre_tomador = ltrim(rtrim(coalesce(coalesce(t2.razon_social, t2.apellido_1),'')||' '||coalesce(t2.nombre_1,''))) --t2.razon_social
    from #upd_as400 t1
    inner join gde_adp_ods.as400_dwh_clientes t2
            on t1.iden_tomador = t2.nro_identifi_clie
    where (t1.nombre_tomador = '' or t1.nombre_tomador is null)
    and t1.newcore = 0
    and t2.tipo_identifi_clie IN ('C','E','N','I','T','R','P');
    
    --Actualizacion agente AS400
    update #upd_as400 
    set agente = 4000000 + cast(agente as numeric(20))
    where newcore = 0;

    update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
    set estado_caratula = t2.estado_caratula,
            estado_cert = t2.estado_cert,	            
            tipo_iden_asegurado = t2.tipo_iden_asegurado,	
            inden_asegurado = t2.inden_asegurado,	
            nombre_asegurado = t2.nombre_asegurado,	
            iden_tomador = t2.iden_tomador,
            tipo_iden_tomador = t2.tipo_iden_tomador,
            nombre_tomador = t2.nombre_tomador,
            agente = t2.agente
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
    inner join #upd_as400 t2 on t1.id = t2.id;
    
    drop table if exists #upd_as400;
    
   --Actualizacion de campos flotas   
   --Tomador
	drop table if exists #tomador;
	
	select distinct t1.sseguro_cert, t3.tdomici as dir_tomador, t3.cpostal as cod_dane_tom, t4.tpoblac as municipio_ciudad_tom,	t5.tprovin as departamento_tom, t6.tpais as pais_tom
	into #tomador
	from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
	inner join gde_adp_ods.axis_tomadores t2 on t1.sseguro_cert = t2.sseguro
	left join gde_adp_ods.axis_per_direcciones t3 on t2.sperson = t3.sperson and t2.cdomici = t3.cdomici
	left join gde_adp_ods.axis_poblaciones t4 on t3.cprovin = t4.cprovin and t3.cpoblac = t4.cpoblac
	left join gde_adp_ods.axis_provincias t5 on t3.cprovin = t5.cprovin
	left join gde_adp_ods.axis_paises t6 on t5.cpais = t6.cpais
	where t1.newcore = '1';	
	
	update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
	set dir_tomador = t2.dir_tomador,
		cod_dane_tom = t2.cod_dane_tom,
		municipio_ciudad_tom = t2.municipio_ciudad_tom,
		departamento_tom = t2.departamento_tom,
		pais_tom = t2.pais_tom
	from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
	inner join #tomador t2 on t1.sseguro_cert = t2.sseguro_cert;
	
	--Tipo afinidad
	update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
	set tipo_afinidad = t3.trespue
	from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
	inner join gde_adp_ods.axis_pregunpolseg t2 on t1.sseguro_cert = t2.sseguro and t2.cpregun = 9104
	inner join gde_adp_ods.axis_respuestas  t3 on t2.cpregun = t3.cpregun and t2.crespue = t3.crespue and t3.cidioma = 8
	where t2.nmovimi = (select max(t4.nmovimi)
						from gde_adp_ods.axis_pregunpolseg t4
						where t4.sseguro = t2.sseguro
						and t4.cpregun = t2.cpregun)
	and t1.newcore = '1';
	
	--Usos permitidos
	update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
	set usos_permitidos = t3.tuso
	from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
	inner join gde_adp_ods.axis_autriesgos t2 on t1.sseguro_cert = t2.sseguro
	inner join gde_adp_ods.axis_aut_desuso t3 on t3.cuso = t2.cuso and t3.cidioma = 8
	where t1.newcore = '1';
	
	--Tipo riesgo
	update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
	set tipo_riesgo = t3.trespue
	from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
	inner join gde_adp_ods.axis_pregunseg t2 on t1.sseguro_cert = t2.sseguro and t2.cpregun = 9235
	inner join gde_adp_ods.axis_respuestas t3 on t3.cpregun = t2.cpregun and t3.crespue = t2.crespue and t3.cidioma = 8
	where t2.nmovimi = (select max(t4.nmovimi)
						from gde_adp_ods.axis_pregunseg t4
						where t4.sseguro = t2.sseguro
						and t4.cpregun = t2.cpregun)
	and t1.newcore = '1';
	
	--Macroplan
	update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
	set cod_resp_macroplan = t3.crespue,
		resp_macroplan = t3.trespue
	from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
    inner join gde_adp_ods.axis_pregunpolseg t2 on t1.sseguro_car = t2.sseguro
	inner join gde_adp_ods.axis_respuestas t3 on t2.crespue = t3.crespue and t3.cidioma = 8 and t2.cpregun = t3.cpregun
	where t2.cpregun = 8796
	and t1.num_certificado = 0
	and t1.newcore = '1';
	
	--Forma de pago
	update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
	set forma_pago = t2.cforpag
	from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
    inner join gde_adp_ods.axis_seguros t2 on t1.sseguro_car = t2.sseguro
	where t1.num_certificado = 0
	and t1.newcore = '1';

	--Modalidad caratula
	update non_gde_adp_dwh.dwh_fact_query_renewal_stg2
	set modalidad_caratula = t2.cmodalidad
	from non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t1
    inner join gde_adp_ods.axis_riesgos t2 on t1.sseguro_car = t2.sseguro
	where t1.num_certificado = 0
	and t1.newcore = '1';

    --delete non_gde_adp_dwh.dwh_fact_query_renewal where to_char(fecha_ejecucion_dwh, 'yyyymmdd') = to_char(getdate(), 'yyyymmdd');
    
	--Insercion tabla final
    insert into non_gde_adp_dwh.dwh_fact_query_renewal (seguro, codramo, agente, producto, tipo_poliza, modalidad, agrupacion, newcore, inden_tomador, tipo_identomador, tom_nombres, ramo, num_certificado, num_poliza, estado_caratula, sucursal, fecha_inicio_car, fecha_vencimiento_car, fecha_emision_car, ano_periodo_contable_car, mes_periodo_contable_car, prima_emitida_car, prima_total_car, comision, des_producto, inden_asegurado, tipo_idenasegurado, aseg_nombres, certif_asegurado, sseguro_cert, placa, estado_certif, fecha_inicio_cer, fecha_vencimiento_cer, fecha_emision_cer, ano_periodo_contable_cer, mes_periodo_contable_cer, prima_emitida_cer, prima_total_cer, riesgos, recibo, mov, mov_rec, estado_renovacion, pdf, tipo_transaccion, cod_tipo_transaccion, fecha_ejecucion_dwh, fecha_actualizacion, usuario_mov, dir_tomador, cod_dane_tom, municipio_ciudad_tom, departamento_tom, pais_tom, tipo_afinidad, usos_permitidos, tipo_riesgo, cod_resp_macroplan, resp_macroplan, forma_pago, modalidad_caratula)
    select  SSEGURO_CAR as seguro
            , CODRAMO as codramo
            , AGENTE as agente
            , PRODUCTO as producto
            , TIPO_POLIZA as tipo_poliza
            , MODALIDAD as modalidad
            , AGRUPACION as agrupacion
            , NEWCORE as newcore
            , IDEN_TOMADOR as inden_tomador
            , replace(replace(replace(replace(replace(replace(TIPO_IDEN_TOMADOR, chr(10), ''),chr(13), ''),chr(9), ''),chr(11), ''),chr(59), ''),chr(44), '') as tipo_identomador
            , replace(replace(replace(replace(replace(replace(NOMBRE_TOMADOR, chr(10), ''),chr(13), ''),chr(9), ''),chr(11), ''),chr(59), ''),chr(44), '') as tom_nombres
            , RAMO as ramo
            , NUM_CERTIFICADO as num_certificado
            , CAST(NUM_POLIZA AS bigint) as num_poliza
            , ESTADO_CARATULA as estado_caratula
            , SUCURSAL as sucursal
            , FECHA_INICIO_CAR as fecha_inicio_car
            , FECHA_VENCIMIENTO_CAR as fecha_vencimiento_car
            , FECHA_EMISION_CAR as fecha_emision_car
            , ANO_PERIODO_CONTABLE_CAR as ano_periodo_contable_car
            , MES_PERIODO_CONTABLE_CAR as mes_periodo_contable_car
            , PRIMA_EMITIDA_CAR as prima_emitida_car
            , PRIMA_TOTAL_CAR as prima_total_car
            , comision as comision
            , DES_PRODUCTO as des_producto
            , replace(replace(replace(replace(replace(replace(INDEN_ASEGURADO, chr(10), ''),chr(13), ''),chr(9), ''),chr(11), ''),chr(59), ''),chr(44), '') as inden_asegurado
            , TIPO_IDEN_ASEGURADO as tipo_idenasegurado
            , replace(replace(replace(replace(replace(replace(NOMBRE_ASEGURADO, chr(10), ''),chr(13), ''),chr(9), ''),chr(11), ''),chr(59), ''),chr(44), '') as aseg_nombres
            , CAST(NUM_CERTIFICADO_ASEG AS bigint) as certif_asegurado
            , SSEGURO_CERT as sseguro_cert
            , PLACA as placa
            , ESTADO_CERT as estado_certif
            , FECHA_INICIO_CERT as fecha_inicio_cer
            , FECHA_VENCIMIENTO_CERT as fecha_vencimiento_cer
            , FECHA_EMISION_CERT as fecha_emision_cer
            , ANO_PERIODO_CONTABLE_CERT as ano_periodo_contable_cer
            , MES_PERIODO_CONTABLE_CERT as mes_periodo_contable_cer
            , PRIMA_EMITIDA_CERT as prima_emitida_cer
            , PRIMA_TOTAL_CERT as prima_total_cer
            , replace(replace(replace(replace(replace(replace(RIESGOS, chr(10), ''),chr(13), ''),chr(9), ''),chr(11), ''),chr(59), ''),chr(44), '') as riesgos
			, RECIBO as recibo
            , MOV as mov
			, MOV_REC as mov_rec
            --, MODIFICACIONES as modificaciones
            --, ANULACION as anulacion
            --, RENOVACION_AUT as renovacion_aut
            --, SLIP_RENOVACION as slip_renovacion
            , ESTADO_RENOVACION as estado_renovacion
            --, PRIMA_RENOVACION_CAR as prima_renovacion_car
            --, PRIMA_RENOVACION_CERT as prima_renovacion_cert
            , PDF as pdf
            , TIPO_TRANSACCION as tipo_transaccion
            , COD_TIPO_TRANSACCION as cod_tipo_transaccion
            , FECHA_EJECUCION_DWH as fecha_ejecucion_dwh
            , cast(GETDATE() - 1 as date) as fecha_actualizacion
            , USUARIO_MOV AS usuario_mov
            , DIR_TOMADOR AS dir_tomador 
			, COD_DANE_TOM AS cod_dane_tom
			, MUNICIPIO_CIUDAD_TOM AS municipio_ciudad_tom
			, DEPARTAMENTO_TOM AS departamento_tom
			, PAIS_TOM AS pais_tom
			, TIPO_AFINIDAD AS tipo_afinidad
			, USOS_PERMITIDOS AS usos_permitidos
			, TIPO_RIESGO AS tipo_riesgo
			, COD_RESP_MACROPLAN AS cod_resp_macroplan
			, RESP_MACROPLAN AS resp_macroplan
			, FORMA_PAGO AS forma_pago
			, MODALIDAD_CARATULA AS modalidad_caratula
    from non_gde_adp_dwh.dwh_fact_query_renewal_stg2;
    
   	--La fecha de actualizacion debe tener la fecha del dia anterior
    update non_gde_adp_dwh.dwh_fact_query_renewal
    set fecha_actualizacion = cast(getdate() - 1 as date);
    
	--Actualizacion de datos de la caratula para toda la poliza
    update non_gde_adp_dwh.dwh_fact_query_renewal
    set fecha_inicio_car = t2.fecha_inicio_car,
    	fecha_vencimiento_car = t2.fecha_vencimiento_car, 
    	fecha_emision_car = t2.fecha_emision_car, 
    	ano_periodo_contable_car = t2.ano_periodo_contable_car, 
    	mes_periodo_contable_car = t2.mes_periodo_contable_car, 
    	prima_emitida_car = t2.prima_emitida_car, 
    	prima_total_car = t2.prima_total_car
    from non_gde_adp_dwh.dwh_fact_query_renewal t1
    inner join non_gde_adp_dwh.dwh_fact_query_renewal_stg2 t2 on t1.producto = t2.producto and t1.num_poliza = t2.num_poliza;
	
    --Actualizacion de estados de caratula y certificados
	drop table if exists #polizas;
	drop table if exists #cycles;
    drop table if exists #estado0;
    drop table if exists #estado1;
    drop table if exists #estado2;
    drop table if exists #estado3;
    drop table if exists #estado4;
	
	select distinct producto, num_poliza, certif_asegurado, fecha_vencimiento_cer
	into #polizas
	from non_gde_adp_dwh.dwh_fact_query_renewal;
	
	select * 
	into #cycles
	from gde_adp_dwh_vw_general.vw_policy_cycles_dates;
	
	select policy_number, risk_number, product_code, cycle_start_date, cycle_end_date --case when cycle_end_date > fecha_vencimiento_cer then cycle_end_date else fecha_vencimiento_cer end cycle_end_date
	into #estado0
	from #cycles t1
	inner join #polizas t2 on cast(t1.policy_number as varchar) = t2.num_poliza and cast(t1.product_code as varchar) = t2.producto and cast(t1.risk_number as varchar) = t2.certif_asegurado;  
	
    select distinct policy_number, risk_number, product_code, max(cycle_end_date) cycle_end_date
    into #estado1
    from non_gde_adp_dwh.dwh_fact_query_renewal t1
    inner join #estado0 t2 on cast(t2.policy_number as varchar )= t1.num_poliza and cast(t2.risk_number as varchar) = t1.certif_asegurado and cast(t2.product_code as varchar) = t1.producto    
    group by policy_number, risk_number, product_code
    union
    select distinct policy_number, risk_number, product_code, max(cycle_end_date) cycle_end_date
    from non_gde_adp_dwh.dwh_fact_query_renewal t1
    inner join #estado0 t2 on cast(t2.policy_number as varchar )= t1.num_poliza and cast(t2.risk_number as varchar) = '0' and cast(t2.product_code as varchar) = t1.producto    
    group by policy_number, risk_number, product_code;  
	
   	--Se realiza cambio de estado de las polizas canceladas a anuladas de acuerdo a definicion
    --select distinct t1.num_poliza, t3.risk_number, t1.producto, case when t4.risk_status_description = 'Cancelado' then 'Anulada' else t4.risk_status_description end estado
	select distinct t1.num_poliza, t3.risk_number, t1.producto, 
    case when t4.risk_status_description = 'Cancelado' and t4.activity_type <> 1 then 'Anulada' 
    	 when t4.risk_status_description = 'Cancelado' and t4.activity_type = 1 then 'Vigente' -- AITSSD-6591 (1	Suplemento	991	Anulacion programada inmediata)
    else t4.risk_status_description end estado
    into #estado2
    from non_gde_adp_dwh.dwh_fact_query_renewal t1
    inner join #estado1 t3 on t3.policy_number = t1.num_poliza and t3.risk_number = t1.certif_asegurado and t3.product_code = t1.producto
    inner join gde_adp_dwh_vw_general.vw_dim_risk t4 on t4.policy_number = t3.policy_number and t4.product_code = t3.product_code and t4.risk_number = t3.risk_number and lower(t4.risk_status_description) not in ('vigente','vencida')
	and t4.risk_updated_ts = (select max(t5.risk_updated_ts) from gde_adp_dwh_vw_general.vw_dim_risk t5 where t4.policy_number = t5.policy_number and t4.product_code = t5.product_code and t4.risk_number = t5.risk_number);    

    delete from #estado1 
    using #estado2
    where #estado1.policy_number = #estado2.num_poliza and #estado1.risk_number = #estado2.risk_number and #estado1.product_code = #estado2.producto;
    
   	--Calculo del estado de la poliza de acuerdo a sus fechas de vigencia 
   	select distinct t1.num_poliza, t3.risk_number, t1.producto, (case when t3.cycle_end_date::date < (sysdate - 1)::date then 'Vencida' else 'Vigente' end) estado    
   	into #estado3
    from non_gde_adp_dwh.dwh_fact_query_renewal t1
    inner join #estado1 t3 on t3.policy_number = t1.num_poliza and t3.risk_number = t1.certif_asegurado and t3.product_code = t1.producto;
    
    select * 
    into #estado4
    from #estado2
    union
    select * 
    from #estado3;
	
    --Actualizacion estado certificado IAXIS
    update non_gde_adp_dwh.dwh_fact_query_renewal
    set estado_certif = estado
    from non_gde_adp_dwh.dwh_fact_query_renewal t1
    inner join #estado4 t2 on t2.num_poliza = t1.num_poliza and t2.risk_number = t1.certif_asegurado and t2.producto = t1.producto;
    
    --Actualizacion estado caratula IAXIS
    update non_gde_adp_dwh.dwh_fact_query_renewal
    set estado_caratula = estado
    from non_gde_adp_dwh.dwh_fact_query_renewal t1
    inner join #estado4 t2 on t2.num_poliza = t1.num_poliza and t2.risk_number = 0 and t2.producto = t1.producto;
    
	--Actualizacion estado AS400
    drop table if exists #est_cer;
    drop table if exists #est_car;
    
    select producto, num_poliza, certif_asegurado, max(fecha_vencimiento_cer) fecha_vencimiento_cer
    into #est_cer
    from non_gde_adp_dwh.dwh_fact_query_renewal
    where newcore = '0'
    group by producto, num_poliza, certif_asegurado;
	
	select producto, num_poliza, max(fecha_vencimiento_car) fecha_vencimiento_car
	into #est_car
    from non_gde_adp_dwh.dwh_fact_query_renewal
    where newcore = '0'
    group by producto, num_poliza;
	
   	--Calculo del estado de la caratula de la poliza de acuerdo a sus fechas de vigencia 
    update non_gde_adp_dwh.dwh_fact_query_renewal
    set estado_caratula = case when t2.fecha_vencimiento_car < getdate() - 1 then 'Vencida' else 'Vigente' end
    from non_gde_adp_dwh.dwh_fact_query_renewal t1
    inner join #est_car t2 on t1.producto = t2.producto and t1.num_poliza = t2.num_poliza
    where t1.newcore = '0';
    
   	--Calculo del estado del certificado de la poliza de acuerdo a sus fechas de vigencia
    update non_gde_adp_dwh.dwh_fact_query_renewal
    set estado_certif = case when t2.fecha_vencimiento_cer < getdate() - 1 then 'Vencida' else 'Vigente' end
    from non_gde_adp_dwh.dwh_fact_query_renewal t1
    inner join #est_cer t2 on t1.producto = t2.producto and t1.num_poliza = t2.num_poliza and t1.certif_asegurado = t2.certif_asegurado
    where t1.newcore = '0';
   
    --Conteo de certificados vigentes
    drop table if exists #pol;
    drop table if exists #pol2;
	
    select distinct codramo, producto, num_poliza, certif_asegurado, tipo_poliza, estado_certif
    into #pol
    from non_gde_adp_dwh.dwh_fact_query_renewal;
    
    select codramo, producto, num_poliza, tipo_poliza, count(1) cont
    into #pol2
    from #pol
    where lower(estado_certif) = 'vigente'
    and tipo_poliza = 'I'
    group by codramo, producto, num_poliza, tipo_poliza
    union
    select codramo, producto, num_poliza, tipo_poliza, count(1) cont
    from #pol
    where lower(estado_certif) = 'vigente'
    and tipo_poliza = 'C' AND certif_asegurado <> 0
    group by codramo, producto, num_poliza, tipo_poliza;
    
    update non_gde_adp_dwh.dwh_fact_query_renewal
    set num_certificado = cont
    from non_gde_adp_dwh.dwh_fact_query_renewal t1
    inner join #pol2 t2 on t1.codramo = t2.codramo and t1.producto = t2.producto and t1.num_poliza = t2.num_poliza;
    
    update non_gde_adp_dwh.dwh_fact_query_renewal
    set num_certificado = 0
    from non_gde_adp_dwh.dwh_fact_query_renewal t1
    where not exists (select 1 from #pol2 t2 where t2.codramo = t1.codramo and t2.producto = t1.producto and t2.num_poliza = t1.num_poliza);    
    
   	--Para las polizas individuales la cantidad de certificados vigentes es 1 
    update non_gde_adp_dwh.dwh_fact_query_renewal
    set num_certificado = 1		
    from non_gde_adp_dwh.dwh_fact_query_renewal t1
    where t1.tipo_poliza = 'I' and num_certificado > 1;
    
	--Actualizacion del campo estado de renovacion
   	update non_gde_adp_dwh.dwh_fact_query_renewal
	set estado_renovacion = '';

   	update non_gde_adp_dwh.dwh_fact_query_renewal
	set estado_renovacion = 'managerenewal'
	where codramo <> 104;	
	
	--Marcacion de polizas renovadas IAXIS
	drop table if exists #renov;
	
	select t2.npoliza, t2.sproduc, max(t3.nmovimi) nmovimi
	into #renov
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	inner join gde_adp_ods.axis_seguros t2 on t2.npoliza = t1.num_poliza and t2.sproduc = t1.producto
	inner join gde_adp_ods.axis_movseguro t3 on t3.sseguro = t2.sseguro and t3.cmovseg = 2 and t3.femisio between date_trunc('month', getdate()) and date_trunc('month', dateadd(month, 2, getdate()))
	group by t2.npoliza, t2.sproduc;
	
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set estado_renovacion = 'RENOVADA'
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	inner join #renov t2 ON t2.npoliza = t1.num_poliza AND t1.producto = t2.sproduc;
	
	--Actualizacion de datos flotas
	--Primas acumuladas
	drop table if exists #pol;
	drop table if exists #primas_acum;
	
	select distinct producto, num_poliza 
	into #pol
	from non_gde_adp_dwh.dwh_fact_query_renewal;
	
	select t0.num_poliza, t0.producto, nvl(sum(nvl(t2.iprianu, 0)), 0) prima_acum
	into #primas_acum
	from #pol t0
	inner join gde_adp_ods.axis_seguros t1 on t0.num_poliza = t1.npoliza and t0.producto = t1.sproduc and t1.ncertif <> 0 and t1.creteni not in (3,4) and (t1.csituac not in (2,3) or (t1.creteni not in (3,4) and t1.csituac = 4))
	inner join gde_adp_ods.axis_garanseg t2 on t2.sseguro = t1.sseguro and t2.ffinefe is null
	inner join non_gde_adp_dwh.dwh_par_garan_pro t3 on t3.cgarant = t2.cgarant and (t3.basegar = 1 and t3.basepro = 1 or t3.basegar = 0 and t3.basepro = 0)
	group by t0.num_poliza, t0.producto;
	
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set total_primas_acum = t2.prima_acum
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	inner join #primas_acum t2 on t1.num_poliza = t2.num_poliza and t1.producto = t2.producto;
	
	--Primas emitidas
	drop table if exists #primas_emi;
	
	select t0.num_poliza, t0.producto, sum(t3.iconcep_monpol) prima_emi
	into #primas_emi
	from #pol t0
	inner join gde_adp_ods.axis_seguros t1 on t0.num_poliza = t1.npoliza and t0.producto = t1.sproduc and t1.ncertif <> 0 and (t1.csituac <> 2 or (t1.csituac = 4 and t1.creteni not in (3,4)))
	inner join gde_adp_ods.axis_recibos t2 on t2.sseguro = t1.sseguro
	inner join gde_adp_ods.axis_detrecibos t3 on t3.nrecibo = t2.nrecibo and t3.cconcep = 0
	group by t0.num_poliza, t0.producto;
	
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set total_primas_emi = t2.prima_emi
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	inner join #primas_emi t2 on t1.num_poliza = t2.num_poliza and t1.producto = t2.producto;
	
	/*insert into non_gde_adp_dwh.dwh_fact_query_renewal_20230914 
	select *
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	where not exists (select 1 from non_gde_adp_dwh.dwh_fact_query_renewal_20230914 t2 where t2.producto = t1.producto and t2.num_poliza = t1.num_poliza and t2.certif_asegurado = t1.certif_asegurado and t2.recibo = t1.recibo and t2.mov = t1.mov and t2.mov_rec = t1.mov_rec)
	and fecha_ejecucion_dwh <> '1/1/1990 12:00:00 am';
	
	insert into non_gde_adp_dwh.dwh_fact_query_renewal_20230914 
	select *
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	where not exists (select 1 from non_gde_adp_dwh.dwh_fact_query_renewal_20230914 t2 where t2.sseguro_cert = t1.sseguro_cert AND t2.mov = t1.mov)
	and fecha_ejecucion_dwh = '1/1/1990 12:00:00 am'
	and newcore = 1;*/

	--Actualizacion por cambio de agente
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set agente = cast(cast(t2.cagente as bigint) as varchar(10))
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	inner join gde_adp_ods.axis_seguros t2 on t1.sseguro_cert = t2.sseguro
	where isnull(t1.agente,'') <> cast(cast(t2.cagente as bigint) as varchar(10))
	and t1.newcore = 1;

	drop table if exists #agente;
	
	select distinct t1.num_poliza, t1.producto, t1.agente, cast(cast(t2.cagente as bigint) as varchar(10)) agente_cero
	into #agente
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	inner join gde_adp_ods.axis_seguros t2 on t1.seguro = t2.sseguro
	where t1.newcore = 1;

	/*select distinct num_poliza, producto, agente, (select distinct t2.agente from non_gde_adp_dwh.dwh_fact_query_renewal t2 where t2.producto = t1.producto and t2.num_poliza = t1.num_poliza and t2.certif_asegurado = 0 and fecha_ejecucion_dwh <> '1990-01-01') agente_cero
	into #agente 
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	where newcore = 1;*/
	
	drop table if exists #agente2;
	
	select num_poliza, producto, agente_cero, count(*)
	into #agente2
	from #agente
	group by num_poliza, producto, agente_cero
	having count(1) > 1;
	
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set agente = t2.agente_cero
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	inner join #agente2 t2 on t1.producto = t2.producto and t1.num_poliza = t2.num_poliza
	where t1.newcore = 1;
	
	--Poliza anterior
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set num_pol_anterior = t2.polissa_ini
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	inner join gde_adp_ods.axis_cnvpolizas t2 on t1.seguro = t2.sseguro
	where t1.producto in (900719, 900720,900758,10024,900742);
	
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set sseguro_anterior = cast(cast(t3.sseguro as int8) as varchar(20))
	from non_gde_adp_dwh.dwh_fact_query_renewal t2
	inner join gde_adp_ods.axis_seguros t3 on t3.npoliza = t2.num_pol_anterior and t3.ncertif = 0
	where length(t2.num_pol_anterior) = regexp_count(t2.num_pol_anterior, '[0-9]') and t2.num_pol_anterior <> '';
	
	--Poliza anterior modificada
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set num_pol_anterior_mod = ltrim(rtrim(regexp_replace(num_pol_anterior, '[^0-9]', '')))
	from non_gde_adp_dwh.dwh_fact_query_renewal
	where num_pol_anterior not like '%-%';
	
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set num_pol_anterior_mod = ltrim(rtrim(split_part(num_pol_anterior,'-',1)))
	from non_gde_adp_dwh.dwh_fact_query_renewal
	where num_pol_anterior like '%-%';
	
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set num_pol_anterior_mod = ltrim(rtrim(split_part(num_pol_anterior,'  ',1)))
	from non_gde_adp_dwh.dwh_fact_query_renewal
	where num_pol_anterior like '%  %';
	
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set num_pol_anterior_mod = ltrim(rtrim(split_part(num_pol_anterior,'/',1)))
	from non_gde_adp_dwh.dwh_fact_query_renewal
	where num_pol_anterior like '%/%';
	
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set num_pol_anterior_mod = null
	from non_gde_adp_dwh.dwh_fact_query_renewal
	where num_pol_anterior_mod = '';
	
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set num_pol_anterior_mod = ltrim(rtrim(split_part(num_pol_anterior,'-',2)))
	from non_gde_adp_dwh.dwh_fact_query_renewal
	where regexp_count(num_pol_anterior, '[A-Z]-') > 0;
	
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set num_pol_anterior_mod = ltrim(rtrim(split_part(num_pol_anterior,'-',2)))
	from non_gde_adp_dwh.dwh_fact_query_renewal
	where regexp_count(num_pol_anterior, '[A-Z] -') > 0;
	
	update non_gde_adp_dwh.dwh_fact_query_renewal 
	set num_pol_anterior_mod = null
	from non_gde_adp_dwh.dwh_fact_query_renewal 
	where length(num_pol_anterior_mod) <> regexp_count(num_pol_anterior_mod, '[0-9]');
	
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set sseguro_anterior = cast(cast(t3.sseguro as int8) as varchar(20))
	from non_gde_adp_dwh.dwh_fact_query_renewal t2
	inner join gde_adp_ods.axis_seguros t3 on t3.npoliza = t2.num_pol_anterior_mod and t3.ncertif = 0
	where length(t2.num_pol_anterior_mod) = regexp_count(t2.num_pol_anterior_mod, '[0-9]')
	and t2.sseguro_anterior is null;

	--Poliza nueva
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set poliza_nueva = t2.num_poliza
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	inner join non_gde_adp_dwh.dwh_fact_query_renewal t2 on t1.num_poliza = t2.num_pol_anterior_mod
	where t1.newcore = '1' and t2.num_pol_anterior_mod is not null;
	
	--Estado de movimiento
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set estado_mov = 'Vigente'
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	where t1.fecha_vencimiento_cer::date >= (sysdate)::date 
	and t1.newcore = '1';
	
	--anulado: cuando el ultimo movimiento del certificado corresponda a una anulación   ( excepto tipos ; anulación por vencimiento de la póliza , anulación programada al vencimiento) y la fecha de efecto sea menor a hoy.
	drop table if exists #anul;
	
	select t1.num_poliza, t1.producto, t1.certif_asegurado, max(cast(split_part(t2.risk_id,'-',2) as int)) max_mov
	into #anul
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	inner join gde_adp_dwh_vw_general.vw_dim_risk t2 on t1.num_poliza = t2.policy_number and t1.producto = t2.product_code and t1.certif_asegurado = t2.risk_number
	where t1.newcore = '1'
	group by t1.num_poliza, t1.producto, t1.certif_asegurado;
	
	drop table if exists #anul2;
	
	select distinct t1.num_poliza, t1.producto, t1.certif_asegurado, cast(t2.max_mov as int) mov, t3.activity_type_reason, case when t3.activity_type_reason = 306 then cast(t4.fefecto as date) else cast(dateadd(year,-1,t4.fcaranu) as date) end as fi_certificado
	     ,case when t3.activity_type_reason = 306 then cast(dateadd(year,1,t4.fefecto) as date) else cast(t4.fcaranu as date) end as ff_certificado
	into #anul2
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	inner join #anul t2 on t1.num_poliza = t2.num_poliza and t1.producto = t2.producto and t1.certif_asegurado = t2.certif_asegurado
	inner join gde_adp_dwh_vw_general.vw_dim_risk t3 on t1.num_poliza = t3.policy_number and t1.producto = t3.product_code and t1.certif_asegurado = t3.risk_number and split_part(t3.risk_id,'-',2) = t2.max_mov
	inner join gde_adp_ods.axis_seguros t4 on t4.sseguro = t1.sseguro_cert
	where t1.newcore = '1'
	and t3.activity_type_description = 'Anulación';

	update non_gde_adp_dwh.dwh_fact_query_renewal
	set estado_mov = 'Anulado'
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	inner join #anul2 t2 on t1.num_poliza = t2.num_poliza and t1.producto = t2.producto and t1.certif_asegurado = t2.certif_asegurado and t1.fecha_inicio_cer between t2.fi_certificado and t2.ff_certificado
	where t2.activity_type_reason not in ('221','322','664')
	and t1.fecha_inicio_cer::date < (sysdate)::date
	and t1.newcore = '1';
	
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set estado_mov = 'Anulación al vencimiento'
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	inner join #anul2 t2 on t1.num_poliza = t2.num_poliza and t1.producto = t2.producto and t1.certif_asegurado = t2.certif_asegurado and t1.fecha_inicio_cer between t2.fi_certificado and t2.ff_certificado
	where t2.activity_type_reason in ('221','322','664')
	and t1.newcore = '1';
	
	--vencido: cuando la fecha fin del certificado es menor a hoy y no tienen movimiento de cancelación.
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set estado_mov = 'Vencido'
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	where t1.fecha_vencimiento_cer::date < (sysdate)::date
	and (t1.estado_mov not in ('Anulado', 'Anulación al vencimiento') or estado_mov is null)
	and t1.newcore = '1';
	
	drop table if exists #anul;
	drop table if exists #anul2;
	
	update non_gde_adp_dwh.dwh_fact_query_renewal
	set placa = t2.cmatric
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	inner join gde_adp_ods.axis_autriesgos t2 on t1.sseguro_cert = cast(cast(t2.sseguro as int) as varchar(20)) and t1.placa <> t2.cmatric
	where t2.nmovimi = (select max(nmovimi) from gde_adp_ods.axis_autriesgos t3 where t3.sseguro = t2.sseguro);

	update non_gde_adp_dwh.dwh_fact_query_renewal 
	set conteo_riesgos = case 
	                        when t1.estado_certif = 'Vigente' then t2.cantidad_riesgos 
	                        else 0 
	                     end 
	from non_gde_adp_dwh.dwh_fact_query_renewal t1
	inner join (select sseguro, count(0) "cantidad_riesgos" from gde_adp_ods.axis_riesgos group by sseguro) t2
	        on t1.seguro::bigint = t2.sseguro::bigint
	where t1.producto = 900742;
		
	drop table if exists non_gde_adp_dwh.dwh_fact_query_renewal_stg2;
    
	--Actualizacion de vistas materializadas
	/*REFRESH MATERIALIZED VIEW non_gde_adp_dwh.vw_renewal_dashboard_consultas;
	REFRESH MATERIALIZED VIEW non_gde_adp_dwh.vw_renewal_dashboard_renovaciones;
	REFRESH MATERIALIZED VIEW non_gde_adp_dwh.vw_renewal_filtros_consulta;
	REFRESH MATERIALIZED VIEW non_gde_adp_dwh.vw_renewal_filtros_renovaciones;*/

	call non_gde_adp_dwh.refresh_mv_renewal();
END;

$$
;

-- Permissions

GRANT ALL ON PROCEDURE non_gde_adp_dwh.sp_insert_dwh_fact_query_renewal() TO michaelgamba;
GRANT ALL ON PROCEDURE non_gde_adp_dwh.sp_insert_dwh_fact_query_renewal() TO adp_db_admin;
GRANT ALL ON PROCEDURE non_gde_adp_dwh.sp_insert_dwh_fact_query_renewal() TO cosvcprocons;
GRANT ALL ON PROCEDURE non_gde_adp_dwh.sp_insert_dwh_fact_query_renewal() TO hugojaramillo;
