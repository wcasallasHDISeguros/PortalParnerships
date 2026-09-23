CREATE OR REPLACE PACKAGE AXIS.pac_autos AS
/******************************************************************************
   NOMBRE:       PAC_AUTOS
   PROPÓSITO:  Funciones para realizar una conexión
               a base de datos de la capa de negocio

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/03/2009   XVM               1. Creación del package.
   2.0        07/01/2013   MDS               2. 0025458: LCOL_T031-LCOL - AUT - (ID 279) Tipos de placa (matr?cula)
   3.0        31/01/2013   DCT               3. 0025628: LCOL_T031-LCOL - AUT - (ID 278 id 85) Control duplicidad matriculas
   4.0        15/03/2013   DCT               4. 0026435: LCOL - TEC - control de duplicidad
   5.0        26/03/2013   ECP               6. 0025202: LCOL_T031 - Adaptar pantalla riesgo - autos. Id 428
   6.0        12/07/2016   AGP               6. BUG 0026011 - Se adiciona funcion f_get_cmatric
   7.0        01/09/2018   FPP               7. QT46059: Se añade la función f_valida_ctipmat en la especificación
   8.0        31/01/2020   Inforcol          8. 0058290: colectivo aws - riesgos no acordes al plan
   9.0        09/06/2020   JMC               9. 0061433: PUAC - Validacion Vigentes (Coomeva)
  10.0        08/04/2020   IGIL             10. 0065595: notificación amparo rc lesiones
******************************************************************************/

   /*************************************************************************
      FUNCTION f_valida_version
         Funció que valida determinats conceptes de la versió
         param in pcmarca   : Codi de la marca
         param in pcmodelo  : Codi del modelo
         param in pctipveh  : Codi tipo vehícle
         param in pcclaveh  : Codi classe vehícle
         param in pcversion : Codi de la versió
         param in ptversion : Descripció versió
         param in ptvarian  : Complement a la versió (en 2ª categoria)
         param in pnpuerta  : Número de portes totals en turismes
         param in pnpuertl  : Número de portes laterals dels furgons
         param in pnpuertt  : Número de portes del darrera dels furgons
         param in pflanzam  : Data del llançament. Format mes/any (mm/aaaa)
         param in pntara    : Pes en buit
         param in pnpma     : Pes Màxim Admès
         param in pnvolcar  : Volum de carga en els furgons
         param in pnlongit  : Longitud del vehícle
         param in pnvia     : Via davantera
         param in pnneumat  : Amplada de pneumàtic davanter
         param in pcvehcha  : Descripció xassis
         param in pcvehlog  : Descripció longitud
         param in pcvehacr  : Descripció tacament
         param in pcvehcaj  : Descripció de caixa
         param in pcvehtec  : Descripció de sostre
         param in pcmotor   : Tipus de motor (Gasolina, Diesel,  Elèctric, etc)
         param in pncilind  : Cilindrada del motor
         param in pnpotecv  : Poténcia del vehícle
         param in pnpotekw  : Poténcia del vehícle
         param in pnplazas  : Número màxim de places
         param in pnace100  : Temps d'acceleració de 0 a 100 Km/h.
         param in pnace400  : Temps d'acceleració de 0 a 400 metres
         param in pnveloc   : Velocitat màxima
         param in pcvehb7   : Indica si ve de base set o no
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_valida_version(
      pcmarca IN VARCHAR2,
      pcmodelo IN VARCHAR2,
      pctipveh IN VARCHAR2,
      pcclaveh IN VARCHAR2,
      pcversion IN VARCHAR2,
      ptversion IN VARCHAR2,
      pnpuerta IN NUMBER,
      pflanzam IN DATE,
      pntara IN NUMBER,
      pnpma IN NUMBER,
      pcmotor IN VARCHAR2,
      pncilind IN NUMBER,
      pnpotecv IN NUMBER,
      pnpotekw IN NUMBER,
      pnplazas IN NUMBER,
      pcvehb7 IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_rieauto(
      psseguro IN NUMBER,   -- Código identificativo del seguro
      pnriesgo IN NUMBER,   --  Numero De Riesgo
      pcversion IN VARCHAR2,   -- En Este Campo Tiene La Siguiente Estructura:
      -- 5 Primeras Posiciones = Marca Del Auto.
      -- Posición 6-7-8 = Modelo Del Auto.
      -- Posición 9-10-11 = Versión Del Auto.
      pcmodelo IN VARCHAR2,   -- Código Del Modelo Del Auto.( Se Corresponde Con El Campo Autmodelos.Smodelo)
      pcmarca IN VARCHAR2,   -- Los Cinco Primeros Caracteres Del Campo Cversion.
      pctipveh IN VARCHAR2,   -- Código Del Tipo De Vehículo
      pcclaveh IN VARCHAR2,   -- Código De La Clase De Vehiculo.
      pcmatric IN VARCHAR2,   -- Matricula Vehiculo. No Se Informa Si  Ctipmat = 2, Sin Matricula
      pctipmat IN NUMBER,   -- Tipo De Matricula. Tipo De Patente
      pcuso IN VARCHAR2,   -- Codigo Uso Del Vehiculo
      pcsubuso IN VARCHAR2,   -- Codigo Subuso Del Vehiculo
      pfmatric IN DATE,   -- Fecha de primera matriculación
      pnkilometros IN NUMBER,   -- Número de kilómetros anuales. Valor fijo = 295
      pivehicu IN NUMBER,   --  Importe Vehiculo
      pnpma IN NUMBER,   --  Peso Máximo Autorizado
      pntara IN NUMBER,   --  Tara
      pnpuertas IN NUMBER,   --  Numero de puertas del vehiculo
      pnplazas IN NUMBER,   --  Numero de plazas del vehiculo
      pcmotor IN VARCHAR2,   -- Tipo combustible(Tipo de motor (Gasolina, Diesel,etc))
      pcgaraje IN NUMBER,   -- Utiliza garaje. Valor fijo = 296
      pcvehb7 IN NUMBER,   -- Indica si procede de base siete o no. Valor fijo = 108
      pcusorem IN NUMBER,   --Utiliza remolque . Valor fijo =108 ( si o no )
      pcremolque IN NUMBER,   -- Descripción del remolque. Valor fijo =297
      pccolor IN NUMBER,   --  Código color vehículo. Valor fijo = 440
      pcvehnue IN VARCHAR2,   -- Indica si el vehículo es nuevo o no.
      pnbastid IN VARCHAR2,
      pcchasis IN VARCHAR2,   -- Código de chasis
      pcodmotor IN VARCHAR2,   -- Código del motor
      psproduc IN NUMBER,   --Código del producto
      pfefecto IN DATE,   --Fecha de Efecto
      panyo IN NUMBER)   --Anyo del vehiculo
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_set_version
         Funció que inserta en AUT_VERSIONES
         param in pcmarca   : Codi de la marca
         param in pcmodelo  : Codi del modelo
         param in pctipveh  : Codi tipo vehícle
         param in pcclaveh  : Codi classe vehícle
         param in pcversion : Codi de la versió
         param in ptversion : Descripció versió
         param in ptvarian  : Complement a la versió (en 2ª categoria)
         param in pnpuerta  : Número de portes totals en turismes
         param in pnpuertl  : Número de portes laterals dels furgons
         param in pnpuertt  : Número de portes del darrera dels furgons
         param in pflanzam  : Data del llançament. Format mes/any (mm/aaaa)
         param in pntara    : Pes en buit
         param in pnpma     : Pes Màxim Admès
         param in pnvolcar  : Volum de carga en els furgons
         param in pnlongit  : Longitud del vehícle
         param in pnvia     : Via davantera
         param in pnneumat  : Amplada de pneumàtic davanter
         param in pcvehcha  : Descripció xassis
         param in pcvehlog  : Descripció longitud
         param in pcvehacr  : Descripció tacament
         param in pcvehcaj  : Descripció de caixa
         param in pcvehtec  : Descripció de sostre
         param in pcmotor   : Tipus de motor (Gasolina, Diesel,  Elèctric, etc)
         param in pncilind  : Cilindrada del motor
         param in pnpotecv  : Poténcia del vehícle
         param in pnpotekw  : Poténcia del vehícle
         param in pnplazas  : Número màxim de places
         param in pnace100  : Temps d'acceleració de 0 a 100 Km/h.
         param in pnace400  : Temps d'acceleració de 0 a 400 metres
         param in pnveloc   : Velocitat màxima
         param in pcvehb7   : Indica si ve de base set o no
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_set_version(
      pcmarca IN VARCHAR2,
      pcmodelo IN VARCHAR2,
      pctipveh IN VARCHAR2,
      pcclaveh IN VARCHAR2,
      pcversion IN VARCHAR2,
      ptversion IN VARCHAR2,
      pnpuerta IN NUMBER,
      pflanzam IN DATE,
      pntara IN NUMBER,
      pnpma IN NUMBER,
      pcmotor IN VARCHAR2,
      pncilind IN NUMBER,
      pnpotecv IN NUMBER,
      pnpotekw IN NUMBER,
      pnplazas IN NUMBER,
      pcvehb7 IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_desversion
         Funcion que busca la descripcion de la version de un vehiculo
         param in pcversion : Codigo de la version
         return             : descripcion de la version
   *************************************************************************/
   FUNCTION f_desversion(pcversion IN VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_desmodelo
         Funcion que busca la descripcion del modelo de un vehiculo
         param in pcmodelo : Codigo del modelo
         param in pcmarca : Codigo de la marca
         return            : descripcion del modelo
   *************************************************************************/
   FUNCTION f_desmodelo(pcmodelo IN VARCHAR2, pcmarca IN VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_desmarca
         Funcion que busca la descripcion de la marca de un vehiculo
         param in pcmarca : Codigo de la marca
         return            : descripcion de la marca
   *************************************************************************/
   FUNCTION f_desmarca(pcmarca IN VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_destipveh
         Funcion que busca la descripcion del tipo de un vehiculo
         param in pctipveh : Codigo del tipo de vehiculo
         param in pcidioma : Idioma de la descripcion
         return            : descripcion del tipo
   *************************************************************************/
   FUNCTION f_destipveh(pctipveh IN VARCHAR2, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_desclaveh
         Funcion que busca la descripcion de la clase de un vehiculo
         param in pcclaveh : Codigo de la clase de vehiculo
         param in pcidioma : Idioma de la descripcion
         return            : descripcion del tipo
   *************************************************************************/
   FUNCTION f_desclaveh(pcclaveh IN VARCHAR2, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_desuso
         Funcion que busca la descripcion del uso de un vehiculo
         param in pcuso : Codigo del uso de vehiculo
         param in pcidioma : Idioma de la descripcion
         return            : descripcion del uso
   *************************************************************************/
   FUNCTION f_desuso(pcuso IN VARCHAR2, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_dessubuso
         Funcion que busca la descripcion del subuso de un vehiculo
         param in pcuso : Codigo del subuso de vehiculo
         param in pcidioma : Idioma de la descripcion
         return            : descripcion del subuso
   *************************************************************************/
   FUNCTION f_dessubuso(pcsubuso IN VARCHAR2, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- BUG 0025412 - FAL - 11/01/2013
   FUNCTION f_get_digitverif_matric(pctipmat IN NUMBER, pcmatric IN VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_controlduplicidad
         Funcion que valida si la matrícula y/o bastidor y/o código motor no esten duplicados
         param in psseguro  Secuencia de la póliza
         param in pcmatric: Codigo de la matrícula
         param in pnbastid : Codigo del bastidor
         param in pcodmotor: Codigo del motor
         param in psproduc:  Codigo del producto
         param in pfefecto:  Fecha efecto
         param in pcchasis:  Código del chasis
         return: 0(OK) x(error)
   *************************************************************************/
   FUNCTION f_controlduplicidad(
      psseguro IN NUMBER,
      pcmatric IN VARCHAR2,
      pnbastid IN VARCHAR2,
      pcodmotor IN VARCHAR2,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pcchasis IN VARCHAR2 DEFAULT NULL,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      pctipmat IN NUMBER DEFAULT NULL)   -- Tipo Matricula   --   43206/26797 --ECP -- 01/08/2016)
      RETURN NUMBER;

    -- BUG 0025202 -  ECP  - 15/02/2013
   /*************************************************************************
      FUNCTION f_despeso
         Funcion que busca la descripcion del peso de un vehiculo
         param in pcpeso : Codigo del peso
         return            : descripcion del peso
   *************************************************************************/
   FUNCTION f_despeso(psproduc IN NUMBER, pcpeso IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_get_valorauto
         Funcion que busca el valor de una version
         param in psseguro : Codigo del seguro
         param in pnriesgo : Numero de riesgo
         param in psproces : Codigo del proceso
         param in pcversion : Código de la versión
         param out pvalorcomercial : valor comercial
         param out pvalorcomercial_nuevo : nuevo valor comercial
         return  0 - Ok 1 Ko

         Bug 26638/160933 - 11/12/2013 - AMC
   *************************************************************************/
   FUNCTION f_get_valorauto(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psproces IN NUMBER,
      pcversion IN VARCHAR2,
      pdonde IN NUMBER,
      pvalorcomercial OUT NUMBER,
      pvalorcomercial_nuevo OUT NUMBER)
      RETURN NUMBER;
--INICIO --BUG 0026011- AGP -12/07/2016: Se adiciona Funcion f_get_cmatric
   /*************************************************************************
         Funcion que retorna la placa informando el seguro.

           param  in     psseguro : Id. seguro
           param  in     ptablas  : 'EST', 'POL'
           return        trespue  : Descripcion del texto de una pregunta
    *************************************************************************/
   FUNCTION f_get_cmatric(psseguro IN seguros.sseguro%TYPE, ptablas IN VARCHAR2)
      RETURN VARCHAR2;
--FIN --BUG 0026011- AGP -12/07/2016: Se adiciona Funcion f_get_cmatric

--INI FPP 01/09/2018 - QT46059
    FUNCTION f_valida_ctipmat(
                pctipmat  IN NUMBER,
                pcmatric  IN VARCHAR2,
                pcversion IN VARCHAR2,
                pctipveh  IN VARCHAR2)
            RETURN NUMBER;
--FIN FPP 01/09/2018 - QT46059
-- INICIO - 31/01/2020 - Inforcol - 0058290: colectivo aws - riesgos no acordes al plan
/*************************************************************************
Funcion valida que la clase de riesgo este permitida al emitir un certificado
para productos de autos colectivo
param  in     psseguro : Id. seguro
param  in     pctipveh : clase de riesgo
param  OUT     mensajes : mensajes de iAXIS
return        NUMBER   : 0 valida ok -  otro valor: vr. de mensaje literal
*************************************************************************/
FUNCTION f_val_ctipveh_aut_col(
    pctipveh IN NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER;
-- FIN - 31/01/2020 - Inforcol - 0058290: colectivo aws - riesgos no acordes al plan
--INI  09/06/2020  JMC  QT61433
FUNCTION f_excepcion_agente (
    pssegcot IN NUMBER,
    pagepol  IN NUMBER,
    ptablas  IN VARCHAR2)
  RETURN NUMBER;
--FIN  09/06/2020  JMC  QT61433
--INI  18/03/2021  IGIL  QT65595
PROCEDURE p_notificacion_rc (psseguro IN NUMBER, pnriesgo IN NUMBER, pnmovimi IN NUMBER, pfsinies IN DATE, pccausin IN NUMBER, pcmotsin IN VARCHAR, pnproducto IN NUMBER,
pnsinies IN VARCHAR2, pntramit IN NUMBER, pctipres IN NUMBER, pnmovres IN NUMBER, pcgarant IN NUMBER,  vireserva IN NUMBER  );
--FIN  09/06/2020  IGIL  QT65595
END pac_autos;

CREATE OR REPLACE PACKAGE BODY AXIS.pac_autos
AS
  /******************************************************************************
  NOMBRE:       PAC_AUTOS
  PROPÿSITO:  Funciones para realizar una conexión
  a base de datos de la capa de negocio
  REVISIONES:
  Ver        Fecha        Autor             Descripción
  ---------  ----------  ---------------  ------------------------------------
  1.0        02/03/2009   XVM               1. Creación del package.
  2.0        07/01/2013   MDS               2. 0025458: LCOL_T031-LCOL - AUT - (ID 279) Tipos de placa (matr?cula)
  3.0        17/01/2013   DCT               3. 0025546: LCOL_T031- LCOL - AUT - (id 322) identificaci?n vehicular (vin)
  4.0        18/01/2013   DCT               4. 0025625: LCOL - AUT - (id 427) Número de motor
  5.0        31/01/2013   DCT               5. 0025628: LCOL_T031-LCOL - AUT - (ID 278 id 85) Control duplicidad matriculas
  6.0        15/03/2013   DCT               6. 0026435: LCOL - TEC - control de duplicidad
  7.0        02/04/2013   DCT               7. 0026419: LCOL - TEC - Revisión Q-Trackers Fase 3A
  8.0        26/03/2013   ECP               6. 0025202: LCOL_T031 - Adaptar pantalla riesgo - autos. Id 428
  9.0        26/04/2013   FAL               9. 0026785: RSAG101 - Producto RC Argentina. Incidencias (22/4)
  10.0       28/10/2013   RCL               10. 0028455: LCOL_T031- TEC - Revisión Q-Trackers Fase 3A II
  11.0       18/12/2013   JDS               11. 0029315: LCOL_T031-Revisi?n Q-Trackers Fase 3A III
  12.0       15/05/2014   ECP               12. 0031204/0012636: ESTRUCTURA PLACA MT
  13.0       18/06/2014   ECP               13. 0031650/0013061: Estructura Placa motocarro
  14.0       30/07/2014   ECP               14. 0032013/0013821: LONGITUD PLACA EXTRANJERA
  15.0       20/03/2015   JRN               15. 0017327: Formato placa para motocarros 3 letras 2 números
  16.0       13/05/2015   CAS               16. 0018167: Optimización: Mejoramiento en Búsquedas para Evidenciar Desbloqueos de Placas
  17.0       26/05/2015   HRE               16. QT-0017909: Nueva estructura para placas de remolques.
  18.0       27/07/2015   RCM              18. 0018167: Optimización: Mejoramiento en Búsquedas para Evidenciar Desbloqueos de Placas
  19.0       14/10/2015   ECP              19. 0021720: Estructura placa uso diplomatico
  20.0       14/04/2016   ECP              20. 41372/0025353: La póliza 38485 no se puede rehabilitar
  21.0       14/06/2016   ECP              21. 43026/0025265: Placas atadas a pólizas vencidas
  22.0       11/07/2016   DCT              22. 0025263: NO permite emitir póliza con la misma placa
  23.0       12/07/2016   AGP              23. BUG 0026011 - Se adiciona funcion f_get_cmatric
  24.0       18/07/2016   ECP              24. 43206/26797: Nuevo formato de placa Diplomatica
  25.0       05/09/2016   ECP              25. 0028050: El sistema no permite realizar suplemento arroja mensaje "Placa ya existente con el mismo uso."
  26.0       20/01/2017   ECP              26. 0030453: Duplicidad placa IVW074
  27.0       29/03/2017   CASL             27. 0032287: Error al Rehabilitar pólizas
  28.0       17/04/2017   CSI              28. QT - 0032648: Vehiculo placa VEU645, vigente en Poliza TT 150136 -141 y otro intermediaro pudo generar cotización.
  29.0       22/06/2017   ECP              29. 0031139: Actualizar informacion del riesgo segun ficheros
  31.0       26/04/2018   ECP              31. 0041722: Placa MU5053 el sistema no valida por tipo de placa solo por placa
  32.0       17/05/2018   AGP              32. 0043148: sistema no permite realizar suplementos pólizas individuales
  33.0       25/04/2018   ECP              30. 0041723: Estructura de tipo de placa diplomática
  34.0       08/05/2018   ECP              32. 043105: Validación de placas en TP y SRC al reactivar
  33.0       08/08/2018   ECP              33. 0045385: no bloqueo placa en simulación y emisión en pólizas vigentes
  34.0       06/11/2018   ECP              34. 0047475: Error al generar cobro en un certificado "la placa esta siendo usada en póliza vigente"
  35.0       27/11/2018   ECP              35. 0047909: Duplicidad de Placa vigente permitió cotizar en póliza express
  36.0       04/12/2018   SPV              36. 0047761: Error al generar cobro en un certificado "la placa esta siendo usada en póliza vigente" (diferenciar colectivo de individuales)
  37.0       11/12/2018   SPV       37. 0047761: Error al generar cobro en un certificado "la placa esta siendo usada en póliza vigente" (corregir error VIN usado pol. vigente)
  38.0       28/12/2018   ECP              38. 0048619: VIN en póliza vigente
  39.0       28/01/2019   SPV              39. 0049158: iAxis permite cotizar placas con póliza vigente
  40.0       29/05/2019   DV               40. 0051836: mejora de consulta de validaciones placa, motor, chasis, en la validacion de fechas para polizas de autos existentes.
  41.0       13/06/2019   RCM              41. 0052378: placas en póliza vigente no bloqueadas.
  42.0       17/06/2019   JGB              42. 0052436: No es posible correr los cobro para la póliza No. 243238 certificado 1837785
  43.0       18/07/2019   SOTO             43. 0052909: No permite generar cobros para la póliza No. 305557 certif 1 placa WLX766 // SRC-Solo RC
  44.0       20/08/2019   Inforcol         44. 0053492: Error en la generación de emisiones masivas para BBVA (PUAC) póliza 299834.
  45.0       16/10/2019   GZG              45. 0055282: Dos pólizas vigentes placas JDK834
  46.0       30/01/2020   Inforcol         46. 0058290: colectivo aws - riesgos no acordes al plan
  47.0       27/04/2020   Inforcol         47. 0060276: validación VIN en póliza vigente
  48.0       31/03/2020   Inforcol         48. 0059482: AWS - TOTAL CAR - 317483 ,298342 ,303014 y 318809 - No esta dejando cotizar aun cuando las clases se encuentran en plan
  49.0       29/05/2020   CASL             49. 0061331: Reversar bug 60276
  50.0       29/06/2020   ASN              50. 0061570: Error en control de duplicidad póliza 324303 (excluir SOAT)
  51.0       09/06/2020   JMC              51. 0061433: PUAC - Validacion Vigentes (Coomeva)
  52.0       23/09/2020   CASL             52. 0063717: Autos - No esta permitiendo la emisión futura - de AWL A PUAC
  53.0       08/04/2021   IGIL             53. 0065595: notificación amparo rc lesiones
  54.0       30/06/2021	  GZG              54. 0069313: Programada anulación póliza 395355 no permite emitir póliza nueva
  55.0       20/07/2021   JMC              55. 0069419: Emision de pólizas nuevas no valida fin de vigencia de póliza anterior
  56.0       25/11/2021   DV               56. 0072107: cliente tiene una poliza vigente y otra con inicio de vigencia futura,el servicio responde que no tiene poliza vigente D &||D
  57.0       17/11/2021   JMC              57. 0072215: Placas con dos pólizas vigentes
  58.0       13/05/2022   DV               58. QT 0074952: Ajustar Estructura de placa diplomatica
  59.0       01/07/2022   DV               59. QT 0074849: Cotizacion placa con poliza vigente
  60.0       27/10/2022   DV               60. QT AITSSD-2587 sistema no permite cotizar placas vigentes con la misma clave intermediario
  61.0       18/11/2022   DV               61. QT AITSSD-3143 Póliza en estado Propuesta cartera / Prop. Cartera Pdte. Autor. permite emitir póliza nueva con misma placa
  62.0       16/12/2022   DV               62. QT AITSSD-4183 No permite cotizar / emitir error "La placa está siendo usada en una póliza vigente" rollback de la instalacion del ticket 3143
  63.0       07/02/2023   DV               63. QT AITSSD-5624 Emision doble póliza PUAC Falabella para misma placa RDT812
  64.0       28/03/2023   DV               64. QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
  65.0       29/03/2023   DV               65. QT AITSSD-6311 Cotización con la misma clave intermediario indica La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
  66.0       09/04/2024   DMRL             66. Activar control en la cotización para no permitir cotizar con el mismo intermediario una placa que ya se encuentra en una póliza vigente.
  67.0       08/01/2025   DV               67. AITSSD-23780 Emisión póliza  en estado Inspección rechazada genera bloqueo de placa
  68.0       14/07/2025   AMANTIUM         68. AITSSD-4245 INCONSISTENCIA TIPO DE PLACA PARA CLASE DE RIESGO CUATRIMOTO
  69.0       24/03/2026   FSE              69. LIB_LCOL_CRILS_597 implementacion de trazas del CRILS-597 para la funcion f_valida_chasis
  ******************************************************************************/
  /*************************************************************************
  FUNCTION f_valida_version
  Funció que valida determinats conceptes de la versió
  param in pcmarca   : Codi de la marca
  param in pcmodelo  : Codi del modelo
  param in pctipveh  : Codi tipo vehícle
  param in pcclaveh  : Codi classe vehícle
  param in pcversion : Codi de la versió
  param in ptversion : Descripció versió
  param in ptvarian  : Complement a la versió (en 2ª categoria)
  param in pnpuerta  : Número de portes totals en turismes
  param in pnpuertl  : Número de portes laterals dels furgons
  param in pnpuertt  : Número de portes del darrera dels furgons
  param in pflanzam  : Data del llançament. Format mes/any (mm/aaaa)
  param in pntara    : Pes en buit
  param in pnpma     : Pes Màxim Admès
  param in pnvolcar  : Volum de carga en els furgons
  param in pnlongit  : Longitud del vehícle
  param in pnvia     : Via davantera
  param in pnneumat  : Amplada de pneumàtic davanter
  param in pcvehcha  : Descripció xassis
  param in pcvehlog  : Descripció longitud
  param in pcvehacr  : Descripció tacament
  param in pcvehcaj  : Descripció de caixa
  param in pcvehtec  : Descripció de sostre
  param in pcmotor   : Tipus de motor (Gasolina, Diesel,  Elèctric, etc)
  param in pncilind  : Cilindrada del motor
  param in pnpotecv  : Poténcia del vehícle
  param in pnpotekw  : Poténcia del vehícle
  param in pnplazas  : Número màxim de places
  param in pnace100  : Temps d'acceleració de 0 a 100 Km/h.
  param in pnace400  : Temps d'acceleració de 0 a 400 metres
  param in pnveloc   : Velocitat màxima
  param in pcvehb7   : Indica si ve de base set o no
  return             : 0 -> Tot correcte
  1 -> S'ha produit un error
  *************************************************************************/
FUNCTION f_valida_version(
    pcmarca   IN VARCHAR2,
    pcmodelo  IN VARCHAR2,
    pctipveh  IN VARCHAR2,
    pcclaveh  IN VARCHAR2,
    pcversion IN VARCHAR2,
    ptversion IN VARCHAR2,
    pnpuerta  IN NUMBER,
    pflanzam  IN DATE,
    pntara    IN NUMBER,
    pnpma     IN NUMBER,
    pcmotor   IN VARCHAR2,
    pncilind  IN NUMBER,
    pnpotecv  IN NUMBER,
    pnpotekw  IN NUMBER,
    pnplazas  IN NUMBER,
    pcvehb7   IN NUMBER)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_AUTOS.f_valida_version';
  vparam      VARCHAR2(500) := 'parámetros - pcmarca: ' || pcmarca || ' pcmodelo:' || pcmodelo || ' pctipveh:' || pctipveh || ' pcclaveh:' || pcclaveh || ' pcversion:' || pcversion || ' ptversion:' || ptversion || ' pnpuerta:' || pnpuerta || ' pflanzam:' || pflanzam || ' pntara:' || pntara || ' pnpma:' || pnpma || ' pcmotor:' || pcmotor || ' pncilind:' || pncilind || ' pnpotecv:' || pnpotecv || ' pnpotekw:' || pnpotekw || ' pnplazas:' || pnplazas || ' pcvehb7:' || pcvehb7;
  vpasexec    NUMBER(5)     := 1;
BEGIN
  IF pcmarca IS NULL THEN
    RETURN 9000995; -- Marca de vehícle no informat
  ELSIF pcmodelo IS NULL THEN
    RETURN 9000996; -- Model de vehícle no informat
  ELSIF ptversion IS NULL THEN
    RETURN 9001125; -- Descripció de la versió no informada
  ELSIF pcclaveh IS NULL THEN
    RETURN 9000513; -- Classe de vehicle no informat
  ELSIF pctipveh IS NULL THEN
    RETURN 9000994; -- Tipus de vehícle no informat
  ELSIF pflanzam IS NULL THEN
    RETURN 9001126; -- Data llançament no informada
  -- Inicio - Inforcol - 20/08/2019 - 0053492 - Quitar la validacion del tipo de vehiculo para motos
  ELSIF pcmotor IS NULL AND pctipveh NOT IN ('70', '71', '72') THEN
  -- Fin - Inforcol - 20/08/2019 - 0053492 - Quitar la validacion del tipo de vehiculo para motos
    RETURN 9001127; -- Tipus motor no informat
  END IF;
  RETURN 0;
EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
  RETURN 9001128; --Error validar la versió
END f_valida_version;
-- Bug 25458 - MDS - 07/01/2013 : nueva función que valida el formato de un campo
--Ini 41723 --ECP -- 25/04/2018
FUNCTION f_valida_formato_campo(
    pcampo   IN VARCHAR2,
    pformato IN VARCHAR2)
  RETURN NUMBER
IS
  i          NUMBER := 1;
  v_caracter VARCHAR2(1);
  v_formato  VARCHAR2(1);
BEGIN
  IF LENGTH(pcampo) <> LENGTH(pformato) THEN
    RETURN 1; -- Formato incorrecto
  END IF;
  WHILE i <= LENGTH(pcampo)
  LOOP
    v_caracter := SUBSTR(pcampo, i, 1);
    v_formato  := SUBSTR(pformato, i, 1);
    -- el formato del carácter tiene que ser Numérico
    IF v_formato = 'N' AND INSTR('1234567890', v_caracter) = 0 THEN
      RETURN 1;
      -- el formato del carácter tiene que ser Letra
    ELSIF v_formato = 'L' AND INSTR('QWERTYUIOPASDFGHJKLZXCVBNM', UPPER(v_caracter)) = 0 THEN
      RETURN 1;
    ELSIF v_formato                                         = 'C' -- BUG 26968/0147424 - FAL - 25/06/2013 -- No admite vocales
      AND INSTR('QWRTYPSDFGHJKLZXCVBNM', UPPER(v_caracter)) = 0 THEN
      RETURN 1;
    ELSIF v_formato                      = 'E' -- Bug 41273 -- ECP -- 25/04/2018 Espacios
      AND INSTR(' ', UPPER(v_caracter)) <> 1 THEN
      RETURN 1;
      -- tiene que ser exclusivamente el carácter
      --ELSE  -- BUG 0025412 - FAL - 21/01/2013
      -- ELSIF v_formato NOT IN('L', 'N') THEN  -- BUG 26968/0147424 - FAL - 25/06/2013 -- No admite vocales
    ELSIF v_formato NOT IN('L', 'N', 'C', 'E') THEN
      -- FI BUG 0025412
      IF v_caracter <> v_formato THEN
        RETURN 1;
      END IF;
    END IF;
    i := i + 1;
  END LOOP;
  RETURN 0;
END f_valida_formato_campo;
--Ini 41723 --ECP -- 25/04/2018
-- Bug 25458 - MDS - 07/01/2013 : nueva función que valida el formato de la matrícula
FUNCTION f_valida_ctipmat(
    pctipmat  IN NUMBER,
    pcmatric  IN VARCHAR2,
    pcversion IN VARCHAR2,
    pctipveh  IN VARCHAR2)
  RETURN NUMBER
IS
  vobjectname         VARCHAR2(500) := 'PAC_AUTOS.f_valida_ctipmat';
  vparam              VARCHAR2(500) := 'parámetros - pctipmat: ' || pctipmat || ' pcmatric: ' || pcmatric || ' pcversion: ' || pcversion || ' pctipveh: ' || pctipveh;
  vpasexec            NUMBER(8)     := 0;
  v_valida_ctipmat    NUMBER        := 0;
  v_longitud_cmatric  NUMBER        := 0;
  v_numerror_longitud NUMBER        := 9904745;
  v_numerror_formato  NUMBER        := 9904746;
  --Ini 43206/26797 -- ECP --18/07/2016
  v_valida_uso NUMBER := 9909156;
  v_cont       NUMBER;
  --Fin 43206/26797 -- ECP --18/07/2016
BEGIN
  vpasexec := 1;
  -- valida que la matrícula no tenga caracteres prohibidos
  v_valida_ctipmat    := pac_validaciones.f_valida_campo(pac_md_common.f_get_cxtempresa(), 'CMATRIC', pcmatric);
  IF v_valida_ctipmat <> 0 THEN
    RETURN v_numerror_formato;
  END IF;
  vpasexec := 2;
  -- valida el formato de la matrícula, en función del tipo de matrícula y el tipo vehículo
  v_longitud_cmatric := LENGTH(pcmatric);
  --
  vpasexec := 3;
  -- Placa tipo TL (L)
  IF pctipmat              = 11 THEN
    IF v_longitud_cmatric <> 6 THEN
      RETURN v_numerror_longitud;
    END IF;
    -- formato correcto : LLNNNN
    IF f_valida_formato_campo(pcmatric, 'TLNNNN') <> 0 THEN
      RETURN v_numerror_formato;
    END IF;
  END IF;
  vpasexec := 4;
  -- Placa tipo Colombia (C)
  IF pctipmat = 12 THEN
    -- Ini 31204/0012636 -- ECP -- 15/05/2014
    IF v_longitud_cmatric <> 6 THEN
      IF pctipveh IN('17', '18', '19') THEN -- BUG 0017327 ¿ 20/03/2015 - jrn - Formato placa para motocarros 3 letras 2 números
        IF v_longitud_cmatric <> 5 THEN
          RETURN v_numerror_longitud;
        END IF;
      ELSE
        RETURN v_numerror_longitud;
      END IF;
      -- Fin 31204/0012636 -- ECP -- 15/05/2014
    END IF;
    -- Remolques
    IF pctipveh IN('23', '25') THEN
      -- formato correcto : RLLLLL
      IF (f_valida_formato_campo(pcmatric, 'RNNNNN') <> 0 AND f_valida_formato_campo(pcmatric, 'SNNNNN') <> 0) -- BUG 0017909 - 26/05/2015 ¿ HRE
        THEN
        RETURN v_numerror_formato;
      END IF;
      -- Motocarro
    ELSIF pctipveh = '19' THEN
      -- formato correcto : NNNLLL
      IF f_valida_formato_campo(pcmatric, 'NNNLLL') <> 0 THEN
        --Ini 31650/0013061 -- ECP -- 18/06/2014
        IF f_valida_formato_campo(pcmatric, 'LLLNNL')   <> 0 THEN
          IF f_valida_formato_campo(pcmatric, 'LLLNNN') <> 0 THEN
            -- INI BUG 0017327 ¿ 20/03/2015 - JRN - Formato placa para motocarros 3 letras 2 números
            IF f_valida_formato_campo(pcmatric, 'LLLNN') <> 0 THEN
              RETURN v_numerror_formato;
            END IF;
            -- FIN BUG 0017327 ¿ 20/03/2015 - JRN
          END IF;
        END IF;
        --Fin 31650/0013061 -- ECP -- 18/06/2014
      END IF;
      -- Motocicleta
      -- Ini 31204/0012636 -- ECP -- 15/05/2014
    ELSIF pctipveh IN('17', '18') THEN
      IF v_longitud_cmatric   <> 6 THEN
        IF v_longitud_cmatric <> 5 THEN
          RETURN v_numerror_longitud;
        END IF;
      END IF;
      -- formato correcto : LLLNNL
      IF f_valida_formato_campo(pcmatric, 'LLLNNL') <> 0 THEN
        -- formato correcto : LLLNN
        IF f_valida_formato_campo(pcmatric, 'LLLNN') <> 0 THEN
          RETURN v_numerror_formato;
        END IF;
      END IF;
      -- Fin 31204/0012636 -- ECP -- 15/05/2014
      -- Para el resto
     -- INICIO AITSSD-4245
     ELSIF pctipveh IN('16') THEN
        IF v_longitud_cmatric <> 6 THEN
        p_control_error('PAY23', vobjectname,'314 vparam '||vparam||' v_longitud_cmatric: '||v_longitud_cmatric||' '||DBMS_UTILITY.FORMAT_CALL_STACK);
          RETURN v_numerror_longitud;
        END IF;
       IF f_valida_formato_campo(pcmatric, 'LLLNNL') <> 0 THEN
        p_control_error('PAY23', vobjectname,'315 vparam '||vparam||' v_longitud_cmatric: '||v_longitud_cmatric||' '||DBMS_UTILITY.FORMAT_CALL_STACK);
         RETURN v_numerror_formato;
        END IF;
     p_control_error('PAY23', vobjectname,'316 SALIO vparam '||vparam||' v_longitud_cmatric: '||v_longitud_cmatric||' '||DBMS_UTILITY.FORMAT_CALL_STACK);
     -- FIN AITSSD-4245
    ELSE
      -- formato correcto : LLLNNN
      IF f_valida_formato_campo(pcmatric, 'LLLNNN') <> 0 THEN
        RETURN v_numerror_formato;
      END IF;
    END IF;
  END IF;
  vpasexec := 5;
  -- Placa tipo extranjera
  IF pctipmat = 13 THEN
    -- Ini 32013/0013821 --ECP-- 30/07/2014  Se cambia IF v_longitud_cmatric <> 10 por
    IF v_longitud_cmatric > 10 THEN
      RETURN v_numerror_longitud;
    END IF;
    -- Fin 32013/0013821 --ECP-- 30/07/2014
    --Este tipo de matricula puedes ser alfanumerico
    --         -- formato correcto : LLLLLLLLLL
    --         IF f_valida_formato_campo(pcmatric, 'LLLLLLLLLL') <> 0 THEN
    --            RETURN v_numerror_formato;
    --         END IF;
  END IF;
  vpasexec := 6;
  -- Placa uso diplomático
  -- Ini 41723 -- ECP -- 25/04/2018
  IF pctipmat                = 14 THEN
   --Ini DV 13/05/2022 QT 	0074952: Ajustar Estructura de placa diplomatica
   -- IF v_longitud_cmatric    > 7 THEN
      IF v_longitud_cmatric <> 6 THEN
        RETURN v_numerror_longitud;
     -- END IF;
    END IF;
    -- formato correcto : LLNNNN
    --IF f_valida_formato_campo(pcmatric, 'LLLENNN')  <> 0 THEN
     IF f_valida_formato_campo(pcmatric, 'LLLNNN')  <> 0 THEN
      IF f_valida_formato_campo(pcmatric, 'LLNNNN') <> 0 THEN
     --Fin DV 13/05/2022 QT 	0074952: Ajustar Estructura de placa diplomatica
        --Ini Bug 37950/21720 -- ECP -- 14/10/2015
        RETURN v_numerror_formato;
        -- Ini 43206/26797 -- ECP --18/07/2016
        --Ini 28050 -- ECP -- 05/09/2016
        /*ELSIF f_valida_formato_campo(pcmatric, 'LLLNNN') = 0 THEN
        BEGIN
        SELECT COUNT(1)
        INTO v_cont
        FROM seguros a, autriesgos b
        WHERE a.sseguro = b.sseguro
        AND a.csituac = 0
        AND a.creteni = 0
        AND b.ctipmat = pctipmat
        AND b.cmatric = pcmatric;
        END;
        IF v_cont <> 0 THEN
        RETURN v_valida_uso;
        END IF;*/
        --Fin 28050 -- ECP -- 05/09/2016
        -- Fin 43206/26797 -- ECP --18/07/2016
      END IF;
      --Ini Bug 37950/21720 -- ECP -- 14/10/2015
    END IF;
  END IF;
  -- Fin 41723 -- ECP -- 25/04/2018
  vpasexec := 7;
  -- Placa tipo importación temporal
  IF pctipmat              = 15 THEN
    IF v_longitud_cmatric <> 5 THEN
      RETURN v_numerror_longitud;
    END IF;
    -- formato correcto : LNNNN
    IF f_valida_formato_campo(pcmatric, 'LNNNN') <> 0 THEN
      RETURN v_numerror_formato;
    END IF;
  END IF;
  -- BUG 0025412 - FAL - 11/01/2013
  -- Placa tipo Chilena
  IF pctipmat              = 16 THEN
    IF v_longitud_cmatric <> 6 THEN
      RETURN v_numerror_longitud;
    END IF;
    -- formato correcto : LNNNN
    -- Bug 0026968 - FAL - 30/05/2013
    -- IF f_valida_formato_campo(pcmatric, 'LLNNNN') <> 0 THEN
    IF f_valida_formato_campo(pcmatric, 'CCNNNN') <> 0
      -- AND f_valida_formato_campo(pcmatric, 'LLLLNN') <> 0 THEN  -- BUG 26968/0147424 - FAL - 25/06/2013 -- No admite vocales
      AND f_valida_formato_campo(pcmatric, 'CCCCNN') <> 0 THEN
      -- FI Bug 0026968
      RETURN v_numerror_formato;
    END IF;
  END IF;
  -- Placa tipo Chilena PPU
  IF pctipmat              = 17 THEN
    IF v_longitud_cmatric <> 6 THEN
      RETURN v_numerror_longitud;
    END IF;
    -- formato correcto : LNNNN
    IF f_valida_formato_campo(pcmatric, 'LLLLNN') <> 0 THEN
      RETURN v_numerror_formato;
    END IF;
  END IF;
  -- FI BUG 0025412
  RETURN 0;
EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
  RETURN v_numerror_formato; --Error validar matrícula
END f_valida_ctipmat;
-- Bug 25458 - MDS - 07/01/2013 : nueva función que valida el formato del chasis
FUNCTION f_valida_chasis(
    pcchasis IN VARCHAR2)
  RETURN NUMBER
IS
  vobjectname         VARCHAR2(500) := 'PAC_AUTOS.f_valida_chasis';
  vparam              VARCHAR2(500) := 'parámetros - pcchasis: ' || pcchasis;
  vpasexec            NUMBER(8)     := 0;
  v_valida_cchasis    NUMBER        := 0;
  v_longitud_cchasis  NUMBER        := 0;
  v_numerror_longitud NUMBER        := 9904747;
  v_numerror_formato  NUMBER        := 9904748;
BEGIN
  vpasexec := 1;
  --INI FSE CRILS-597 - 24/03/2026
   p_control_error(
    'FSE',
    vobjectname,
    'Inicio función',
    vparam,
    f_user
  );
  --FIN FSE CRILS-597 - 24/03/2026
  -- valida que el chasis no tenga caracteres prohibidos
  v_valida_cchasis    := pac_validaciones.f_valida_campo(pac_md_common.f_get_cxtempresa(), 'CCHASIS', pcchasis);
  IF v_valida_cchasis <> 0 THEN
   --INI FSE CRILS-597 - 24/03/2026
    p_control_error(
      'FSE',
      vobjectname,
      'Retorno por error de formato. Paso: ' || vpasexec,
      vparam || ' - CALL_STACK: ' || SUBSTR(DBMS_UTILITY.format_call_stack,1,3800),
      f_user
    );
    --FIN FSE CRILS-597 - 24/03/2026
    RETURN v_numerror_formato;
  END IF;
  vpasexec := 2;
  RETURN 0;
EXCEPTION
WHEN OTHERS THEN
  --INI FSE CRILS-597 - 24/03/2026
  p_control_error(
    'FSE',
    vobjectname,
    'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM,
    vparam || ' - ERROR_BACKTRACE: ' || SUBSTR(DBMS_UTILITY.format_error_backtrace,1,3800),
    f_user
  );
  --FIN FSE CRILS-597 - 24/03/2026
  p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
  RETURN v_numerror_formato; --Error validar chasis
END f_valida_chasis;
FUNCTION f_valida_rieauto(
    psseguro  IN NUMBER,   -- Código identificativo del seguro
    pnriesgo  IN NUMBER,   --  Numero De Riesgo
    pcversion IN VARCHAR2, -- En Este Campo Tiene La Siguiente Estructura:
    -- 5 Primeras Posiciones = Marca Del Auto.
    -- Posición 6-7-8 = Modelo Del Auto.
    -- Posición 9-10-11 = Versión Del Auto.
    pcmodelo     IN VARCHAR2, -- Código Del Modelo Del Auto.( Se Corresponde Con El Campo Autmodelos.Smodelo)
    pcmarca      IN VARCHAR2, -- Los Cinco Primeros Caracteres Del Campo Cversion.
    pctipveh     IN VARCHAR2, -- Código Del Tipo De Vehículo
    pcclaveh     IN VARCHAR2, -- Código De La Clase De Vehiculo.
    pcmatric     IN VARCHAR2, -- Matricula Vehiculo. No Se Informa Si  Ctipmat = 2, Sin Matricula
    pctipmat     IN NUMBER,   -- Tipo De Matricula. Tipo De Patente
    pcuso        IN VARCHAR2, -- Codigo Uso Del Vehiculo
    pcsubuso     IN VARCHAR2, -- Codigo Subuso Del Vehiculo
    pfmatric     IN DATE,     -- Fecha de primera matriculación
    pnkilometros IN NUMBER,   -- Número de kilómetros anuales. Valor fijo = 295
    pivehicu     IN NUMBER,   --  Importe Vehiculo
    pnpma        IN NUMBER,   --  Peso Máximo Autorizado
    pntara       IN NUMBER,   --  Tara
    pnpuertas    IN NUMBER,   --  Numero de puertas del vehiculo
    pnplazas     IN NUMBER,   --  Numero de plazas del vehiculo
    pcmotor      IN VARCHAR2, -- Tipo combustible(Tipo de motor (Gasolina, Diesel,etc))
    pcgaraje     IN NUMBER,   -- Utiliza garaje. Valor fijo = 296
    pcvehb7      IN NUMBER,   -- Indica si procede de base siete o no. Valor fijo = 108
    pcusorem     IN NUMBER,   --Utiliza remolque . Valor fijo =108 ( si o no )
    pcremolque   IN NUMBER,   -- Descripción del remolque. Valor fijo =297
    pccolor      IN NUMBER,   --  Código color vehículo. Valor fijo = 440
    pcvehnue     IN VARCHAR2, -- Indica si el vehículo es nuevo o no.
    pnbastid     IN VARCHAR2,
    pcchasis     IN VARCHAR2, -- Código de chasis
    pcodmotor    IN VARCHAR2, -- Código del motor
    psproduc     IN NUMBER,   --Código del producto)
    pfefecto     IN DATE,     --Fecha de Efecto
    panyo        IN NUMBER)   --Anyo del vehiculo
  RETURN NUMBER
IS
  vpasexec            NUMBER(8) := 0;
  v_valida_ctipmat    NUMBER    := 0;
  v_valida_cchasis    NUMBER    := 0;
  v_valida_nbastid    NUMBER    := 0;
  v_valida_codmotor   NUMBER    := 0;
  v_valida_duplicidad NUMBER    := 0;
  nerror              NUMBER;
  nerror1             NUMBER;
  nerror2             NUMBER;
  nerror3             NUMBER;
  v_cvalpar           NUMBER;
  vparam              VARCHAR2(4000) := 'parámetros - psseguro: ' || psseguro || ' pnriesgo: ' || pnriesgo || ' pcversion: ' || pcversion || ' pcmarca: ' || pcmarca || ' pctipveh: ' || pctipveh || ' pcclaveh: ' || pcclaveh || ' pcmatric: ' || pcmatric || ' pctipmat: ' || pctipmat || ' pcuso: ' || pcuso || ' pcsubuso: ' || pcsubuso || ' pfmatric: ' || pfmatric || ' pnkilometros: ' || pnkilometros || ' pivehicu: ' || pivehicu || ' pnpma: ' || pnpma || ' pntara: ' || pntara || ' pnpuertas: ' || pnpuertas || ' pnplazas: ' || pnplazas || ' pcmotor: ' || pcmotor || ' pcgaraje: ' || pcgaraje || ' pcvehb7: ' || pcvehb7 || ' pcusorem: ' || pcusorem || ' pcremolque: ' || pcremolque || ' pccolor: ' || pccolor || ' pcvehnue: ' || pcvehnue || ' pnbastid: ' || pnbastid || ' pcchasis: ' || pcchasis || ' pcodmotor: ' || pcodmotor || ' psproduc: ' || psproduc || 'anyo:' || panyo;
  vobjectname         VARCHAR2(200)  := 'PAC_AUTOS.f_valida_rieauto';
  -- INICIO - 31/01/2020 - Inforcol - 0058290: colectivo aws - riesgos no acordes al plan
  v_valida_ctipveh    NUMBER;
  vmensajes t_iax_mensajes;
  -- FIN - 31/01/2020 - Inforcol - 0058290: colectivo aws - riesgos no acordes al plan
BEGIN
  IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'V_ANYO'), 0) = 1 THEN
    IF panyo NOT BETWEEN EXTRACT(YEAR FROM f_sysdate) - 35 AND EXTRACT (YEAR FROM f_sysdate) + 1 THEN
      RETURN 9905775;
    END IF;
  END IF;
  vpasexec := 1;
  -- INICIO - 31/01/2020 - Inforcol - 0058290: colectivo aws - riesgos no acordes al plan
  IF NVL(f_parproductos_v(psproduc, 'VAL_CTIPVEH_AUT_COL'), 0) = 1 THEN
    v_valida_ctipveh    := pac_autos.f_val_ctipveh_aut_col(pctipveh, vmensajes);
    IF v_valida_ctipveh <> 0 THEN
      RETURN v_valida_ctipveh;
    END IF;
  END IF;
  -- FIN - 31/01/2020 - Inforcol - 0058290: colectivo aws - riesgos no acordes al plan
  -- valida la matrícula
  v_valida_ctipmat    := pac_autos.f_valida_ctipmat(pctipmat, pcmatric, pcversion, pctipveh);
  IF v_valida_ctipmat <> 0 THEN
    RETURN v_valida_ctipmat;
  END IF;
  vpasexec := 2;
  -- valida el chasis
  v_valida_cchasis    := pac_autos.f_valida_chasis(pcchasis);
  IF v_valida_cchasis <> 0 THEN
    RETURN v_valida_cchasis;
  END IF;
  vpasexec := 3;
  -- valida el vin
  v_valida_nbastid     := pac_validaciones.f_valida_campo(pac_md_common.f_get_cxtempresa(), 'NBASTID', pnbastid);
  IF v_valida_nbastid  <> 0 THEN
    IF v_valida_nbastid = 50000 THEN
      --Formato de bastidor incorrecto
      RETURN 9904837;
    ELSE
      RETURN v_valida_nbastid;
    END IF;
  END IF;
  vpasexec := 4;
  -- valida el campo motor
  v_valida_codmotor     := pac_validaciones.f_valida_campo(pac_md_common.f_get_cxtempresa(), 'CODMOTOR', pcodmotor);
  IF v_valida_codmotor  <> 0 THEN
    IF v_valida_codmotor = 50000 THEN
      --Formato de motor incorrecto
      RETURN 9904838;
    ELSE
      RETURN v_valida_codmotor;
    END IF;
  END IF;
  --      --BUG 0025628: INICIO - DCT - 22/01/2013
  --      --Validamos que no haya duplicidad de matrículas, vin o código del motor.
  --      IF pac_iax_produccion.issimul = FALSE THEN
  --         vpasexec := 5;
  --         nerror := f_parproductos(psproduc, 'POLIZA_UNICA', v_cvalpar);
  --         IF nerror <> 0 THEN
  --            RETURN nerror;
  --         END IF;
  --         IF NVL(v_cvalpar, 0) = 4 THEN   --por cumulo
  --            --BUG 26435 - INICIO - DCT - 15/03/2013 - Añadir pcchasis
  --            v_valida_duplicidad := f_controlduplicidad(psseguro, pcmatric, pnbastid,
  --                                                       pcodmotor, psproduc, pfefecto,
  --                                                       pcchasis);
  --            --BUG 26435 - FIN - DCT - 15/03/2013
  --            IF v_valida_duplicidad <> 0 THEN
  --               RETURN v_valida_duplicidad;
  --            END IF;
  --         END IF;
  --      END IF;
  vpasexec := 6;
  --BUG 0025628: FIN - DCT - 22/01/2013
  RETURN 0;
EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
  RETURN 9001128; --Error validar el auto
END f_valida_rieauto;
/*************************************************************************
FUNCTION f_set_version
Funció que inserta en AUT_VERSIONES
param in pcmarca   : Codi de la marca
param in pcmodelo  : Codi del modelo
param in pctipveh  : Codi tipo vehícle
param in pcclaveh  : Codi classe vehícle
param in pcversion : Codi de la versió
param in ptversion : Descripció versió
param in ptvarian  : Complement a la versió (en 2ª categoria)
param in pnpuerta  : Número de portes totals en turismes
param in pnpuertl  : Número de portes laterals dels furgons
param in pnpuertt  : Número de portes del darrera dels furgons
param in pflanzam  : Data del llançament. Format mes/any (mm/aaaa)
param in pntara    : Pes en buit
param in pnpma     : Pes Màxim Admès
param in pnvolcar  : Volum de carga en els furgons
param in pnlongit  : Longitud del vehícle
param in pnvia     : Via davantera
param in pnneumat  : Amplada de pneumàtic davanter
param in pcvehcha  : Descripció xassis
param in pcvehlog  : Descripció longitud
param in pcvehacr  : Descripció tacament
param in pcvehcaj  : Descripció de caixa
param in pcvehtec  : Descripció de sostre
param in pcmotor   : Tipus de motor (Gasolina, Diesel,  Elèctric, etc)
param in pncilind  : Cilindrada del motor
param in pnpotecv  : Poténcia del vehícle
param in pnpotekw  : Poténcia del vehícle
param in pnplazas  : Número màxim de places
param in pnace100  : Temps d'acceleració de 0 a 100 Km/h.
param in pnace400  : Temps d'acceleració de 0 a 400 metres
param in pnveloc   : Velocitat màxima
param in pcvehb7   : Indica si ve de base set o no
return             : 0 -> Tot correcte
1 -> S'ha produit un error
*************************************************************************/
FUNCTION f_set_version(
    pcmarca   IN VARCHAR2,
    pcmodelo  IN VARCHAR2,
    pctipveh  IN VARCHAR2,
    pcclaveh  IN VARCHAR2,
    pcversion IN VARCHAR2,
    ptversion IN VARCHAR2,
    pnpuerta  IN NUMBER,
    pflanzam  IN DATE,
    pntara    IN NUMBER,
    pnpma     IN NUMBER,
    pcmotor   IN VARCHAR2,
    pncilind  IN NUMBER,
    pnpotecv  IN NUMBER,
    pnpotekw  IN NUMBER,
    pnplazas  IN NUMBER,
    pcvehb7   IN NUMBER)
  RETURN NUMBER
IS
  vobjectname VARCHAR2(500) := 'PAC_AUTOS.f_set_version';
  vparam      VARCHAR2(500) := 'parámetros - pcmarca: ' || pcmarca || ' pcmodelo:' || pcmodelo || ' pctipveh:' || pctipveh || ' pcclaveh:' || pcclaveh || ' pcversion:' || pcversion || ' ptversion:' || ptversion || ' pnpuerta:' || pnpuerta || ' pflanzam:' || pflanzam || ' pntara:' || pntara || ' pnpma:' || pnpma || ' pcmotor:' || pcmotor || ' pncilind:' || pncilind || ' pnpotecv:' || pnpotecv || ' pnpotekw:' || pnpotekw || ' pnplazas:' || pnplazas || ' pcvehb7:' || pcvehb7;
  vpasexec    NUMBER(5)     := 1;
  vseqversion VARCHAR2(11);
BEGIN
  IF pcversion IS NULL THEN
    SELECT LPAD(pcmarca, 5, '0')
      || LPAD(pcmodelo, 3, '0')
      || LPAD(sversion.NEXTVAL, 3, '0')
    INTO vseqversion
    FROM DUAL;
  ELSE
    vseqversion := pcversion;
  END IF;
  BEGIN
    INSERT
    INTO aut_versiones
      (
        cversion,
        cmodelo,
        cmarca,
        cclaveh,
        ctipveh,
        tversion,
        npuerta,
        flanzam,
        ntara,
        npma,
        cmotor,
        ncilind,
        npotecv,
        npotekw,
        nplazas,
        cvehb7
      )
      VALUES
      (
        vseqversion,
        pcmodelo,
        pcmarca,
        pcclaveh,
        pctipveh,
        ptversion,
        pnpuerta,
        pflanzam,
        pntara,
        pnpma,
        pcmotor,
        pncilind,
        pnpotecv,
        pnpotekw,
        pnplazas,
        pcvehb7
      );
  EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    UPDATE aut_versiones
    SET cmodelo    = pcmodelo,
      cmarca       = pcmarca,
      cclaveh      = pcclaveh,
      ctipveh      = pctipveh,
      tversion     = ptversion,
      npuerta      = pnpuerta,
      flanzam      = pflanzam,
      ntara        = pntara,
      npma         = pnpma,
      cmotor       = pcmotor,
      ncilind      = pncilind,
      npotecv      = pnpotecv,
      npotekw      = pnpotekw,
      nplazas      = pnplazas,
      cvehb7       = pcvehb7
    WHERE cversion = vseqversion;
  END;
  RETURN 0;
EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
  RETURN 9001137; --Error al insertar la versió (AUT_VERSIONES)
END f_set_version;
-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desversion
/*************************************************************************
FUNCTION f_desversion
Funcion que busca la descripcion de la version de un vehiculo
param in pcversion : Codi de la versió
return             : descripcion de la version
*************************************************************************/
FUNCTION f_desversion(
    pcversion IN VARCHAR2)
  RETURN VARCHAR2
IS
  v_tversion aut_versiones.tversion%TYPE; -- VARCHAR2(100)
BEGIN
  SELECT tversion INTO v_tversion FROM aut_versiones WHERE cversion = pcversion;
  RETURN v_tversion;
EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, 'pac_autos.f_desversion', 1, 'pcversion = ' || pcversion, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
  RETURN NULL;
END f_desversion;
-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desversion
-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desmodelo
/*************************************************************************
FUNCTION f_desmodelo
Funcion que busca la descripcion del modelo de un vehiculo
param in pcmodelo : Codigo del modelo
param in pcmarca : Codigo de la marca
return            : descripcion del modelo
*************************************************************************/
FUNCTION f_desmodelo(
    pcmodelo IN VARCHAR2,
    pcmarca  IN VARCHAR2)
  RETURN VARCHAR2
IS
  v_tmodelo aut_modelos.tmodelo%TYPE; -- VARCHAR2(100)
BEGIN
  SELECT tmodelo
  INTO v_tmodelo
  FROM aut_modelos
  WHERE cmarca = pcmarca
  AND cmodelo  = pcmodelo
  AND cempres  = pac_md_common.f_get_cxtempresa();
  RETURN v_tmodelo;
EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, 'pac_autos.f_desmodelo', 1, 'pcmodelo = ' || pcmodelo || '  pcmarca = ' || pcmarca, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
  RETURN NULL;
END f_desmodelo;
-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desmodelo
-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desmarca
/*************************************************************************
FUNCTION f_desmarca
Funcion que busca la descripcion de la marca de un vehiculo
param in pcmarca : Codigo de la marca
return            : descripcion de la marca
*************************************************************************/
FUNCTION f_desmarca(
    pcmarca IN VARCHAR2)
  RETURN VARCHAR2
IS
  v_tmarca aut_marcas.tmarca%TYPE; -- VARCHAR2(100)
BEGIN
  SELECT tmarca
  INTO v_tmarca
  FROM aut_marcas
  WHERE cmarca = pcmarca
  AND cempres  = pac_md_common.f_get_cxtempresa();
  RETURN v_tmarca;
EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, 'pac_autos.f_desmarca', 1, 'pcmarca = ' || pcmarca, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
  RETURN NULL;
END f_desmarca;
-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desmarca
-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_destipveh
/*************************************************************************
FUNCTION f_destipveh
Funcion que busca la descripcion del tipo de un vehiculo
param in pctipveh : Codigo del tipo de vehiculo
param in pcidioma : Idioma de la descripcion
return            : descripcion del tipo
*************************************************************************/
FUNCTION f_destipveh(
    pctipveh IN VARCHAR2,
    pcidioma IN NUMBER)
  RETURN VARCHAR2
IS
  v_ttipveh aut_destipveh.ttipveh%TYPE; -- VARCHAR2(100)
BEGIN
  SELECT ttipveh
  INTO v_ttipveh
  FROM aut_destipveh
  WHERE ctipveh = pctipveh
  AND cempres   = pac_md_common.f_get_cxtempresa()
  AND cidioma   = pcidioma;
  RETURN v_ttipveh;
EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, 'pac_autos.f_destipveh', 1, 'pctipveh = ' || pctipveh || '  pcidioma = ' || pcidioma, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
  RETURN NULL;
END f_destipveh;
-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_destipveh
-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desclaveh
/*************************************************************************
FUNCTION f_desclaveh
Funcion que busca la descripcion de la clase de un vehiculo
param in pcclaveh : Codigo de la clase de vehiculo
param in pcidioma : Idioma de la descripcion
return            : descripcion del tipo
*************************************************************************/
FUNCTION f_desclaveh(
    pcclaveh IN VARCHAR2,
    pcidioma IN NUMBER)
  RETURN VARCHAR2
IS
  v_tclaveh aut_desclaveh.tclaveh%TYPE; -- VARCHAR2(100)
BEGIN
  SELECT tclaveh
  INTO v_tclaveh
  FROM aut_desclaveh
  WHERE cclaveh = pcclaveh
  AND cempres   = pac_md_common.f_get_cxtempresa()
  AND cidioma   = pcidioma;
  RETURN v_tclaveh;
EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, 'pac_autos.f_desclaveh', 1, 'pcclaveh = ' || pcclaveh || '  pcidioma = ' || pcidioma, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
  RETURN NULL;
END f_desclaveh;
-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desclaveh
-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desuso
/*************************************************************************
FUNCTION f_desuso
Funcion que busca la descripcion del uso de un vehiculo
param in pcuso : Codigo del uso de vehiculo
param in pcidioma : Idioma de la descripcion
return            : descripcion del uso
*************************************************************************/
FUNCTION f_desuso(
    pcuso    IN VARCHAR2,
    pcidioma IN NUMBER)
  RETURN VARCHAR2
IS
  v_tuso aut_desuso.tuso%TYPE; -- VARCHAR2(100)
BEGIN
  SELECT tuso
  INTO v_tuso
  FROM aut_desuso
  WHERE cuso  = pcuso
  AND cidioma = pcidioma
  AND cempres = pac_md_common.f_get_cxtempresa();
  RETURN v_tuso;
EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, 'pac_autos.f_desuso', 1, 'pcuso = ' || pcuso || '  pcidioma = ' || pcidioma, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
  RETURN NULL;
END f_desuso;
-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desuso
-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_dessubuso
/*************************************************************************
FUNCTION f_dessubuso
Funcion que busca la descripcion del subuso de un vehiculo
param in pcuso : Codigo del subuso de vehiculo
param in pcidioma : Idioma de la descripcion
return            : descripcion del subuso
*************************************************************************/
FUNCTION f_dessubuso(
    pcsubuso IN VARCHAR2,
    pcidioma IN NUMBER)
  RETURN VARCHAR2
IS
  v_tsubuso aut_dessubuso.tsubuso%TYPE; -- VARCHAR2(100)
BEGIN
  SELECT tsubuso
  INTO v_tsubuso
  FROM aut_dessubuso
    -- Ini 31139 -- ECP -- 22/06/2017
  WHERE csubuso = NVL(pcsubuso, 0)
    -- Fin 31139 -- ECP -- 22/06/2017
  AND cidioma = pcidioma
  AND cempres = pac_md_common.f_get_cxtempresa();
  RETURN v_tsubuso;
EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, 'pac_autos.f_dessubuso', 1, 'pcsubuso = ' || pcsubuso || '  pcidioma = ' || pcidioma, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
  RETURN NULL;
END f_dessubuso;
-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_dessubuso
-- BUG 0025412 - FAL - 11/01/2013
FUNCTION f_get_digitverif_matric(
    pctipmat IN NUMBER,
    pcmatric IN VARCHAR2)
  RETURN VARCHAR2
IS
  v_obj        VARCHAR2(100) := 'pac_propio.f_get_digitverif_matric';
  v_param      VARCHAR2(500) := 't=' || pctipmat || '-m=' || pcmatric;
  n_pas        NUMBER;
  v_numero     VARCHAR2(20);
  v_suma       NUMBER;
  v_modulo11   NUMBER;
  v_digito     NUMBER(1);
  v_3carac     VARCHAR2(1);
  v_format_mat NUMBER;
  v_1y2_carac  VARCHAR2(2);
  v_equival aut_digitverif_matric.cequival%TYPE;
  v_cmatric   VARCHAR2(7);
  i           NUMBER := 1;
  v_caracter  VARCHAR2(1);
  v_car_equiv VARCHAR2(1);
BEGIN
  v_3carac                          := SUBSTR(pcmatric, 3, 1);
  IF pctipmat                        = 16 THEN
    IF INSTR('1234567890', v_3carac) = 0 THEN
      RETURN NULL;
    ELSE
      v_1y2_carac := SUBSTR(pcmatric, 1, 2);
      BEGIN
        SELECT cequival
        INTO v_equival
        FROM aut_digitverif_matric
        WHERE cserie = v_1y2_carac;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN 1;
      END;
      v_cmatric  := v_equival || SUBSTR(pcmatric, 3, 4);
      v_suma     := SUBSTR(LPAD(v_cmatric, 7, 0), 1, 1) * 2 + SUBSTR(LPAD(v_cmatric, 7, 0), 2, 1) * 7 + SUBSTR(LPAD(v_cmatric, 7, 0), 3, 1) * 6 + SUBSTR(LPAD(v_cmatric, 7, 0), 4, 1) * 5 + SUBSTR(LPAD(v_cmatric, 7, 0), 5, 1) * 4 + SUBSTR(LPAD(v_cmatric, 7, 0), 6, 1) * 3 + SUBSTR(LPAD(v_cmatric, 7, 0), 7, 1) * 2;
      n_pas      := 110;
      v_modulo11 := MOD(v_suma, 11);
      n_pas      := 111;
      v_digito   := 11 - v_modulo11;
      IF v_digito = 11 THEN
        --OK
        RETURN '0';
      ELSIF v_digito = 10 THEN
        RETURN 'K';
      ELSE
        RETURN v_digito;
      END IF;
    END IF;
  ELSIF pctipmat = 17 THEN
    -- IF INSTR('QWERTYUIOPASDFGHJKLZXCVBNM', UPPER(v_3carac)) = 0 THEN
    IF INSTR('QWRTYPSDFGHJKLZXCVBNM', UPPER(v_3carac)) = 0 THEN -- BUG 26968/0147424 - FAL - 25/06/2013 -- No admite vocales
      RETURN NULL;
    ELSE
      WHILE i <= 4
      LOOP
        v_caracter := SUBSTR(pcmatric, i, 1);
        SELECT DECODE(v_caracter, 'B', '1', 'C', '2', 'D', '3', 'F', '4', 'G', '5', 'H', '6', 'J', '7', 'K', '8', 'L', '9', 'P', '0', 'R', '2', 'S', '3', 'T', '4', 'V', '5', 'W', '6', 'X', '7', 'Y', '8', 'Z', '9')
        INTO v_car_equiv
        FROM DUAL;
        v_cmatric := v_cmatric || v_car_equiv;
        i         := i + 1;
      END LOOP;
      v_cmatric  := v_cmatric || SUBSTR(pcmatric, 5, 2);
      v_suma     := SUBSTR(LPAD(v_cmatric, 6, 0), 1, 1) * 7 + SUBSTR(LPAD(v_cmatric, 6, 0), 2, 1) * 6 + SUBSTR(LPAD(v_cmatric, 6, 0), 3, 1) * 5 + SUBSTR(LPAD(v_cmatric, 6, 0), 4, 1) * 4 + SUBSTR(LPAD(v_cmatric, 6, 0), 5, 1) * 3 + SUBSTR(LPAD(v_cmatric, 6, 0), 6, 1) * 2;
      n_pas      := 110;
      v_modulo11 := MOD(v_suma, 11);
      n_pas      := 111;
      v_digito   := 11 - v_modulo11;
      IF v_digito = 11 THEN
        --OK
        RETURN '0';
      ELSIF v_digito = 10 THEN
        RETURN 'K';
      ELSE
        RETURN v_digito;
      END IF;
    END IF;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, v_obj, n_pas, v_param, SQLCODE || ' ' || SQLERRM);
  RETURN NULL;
END f_get_digitverif_matric;
-- FI BUG 0025412
/*************************************************************************
FUNCTION f_controlduplicidad
Funcion que valida si la matrícula y/o bastidor y/o código motor no esten duplicados
param in pcmatric: Codigo de la matrícula
param in pnbastid : Codigo del bastidor
param in pcodmotor: Codigo del motor
param in psproduc:  Codigo del producto
param in pfefecto:  Fecha efecto
return: 0(OK) x(error)
*************************************************************************/
FUNCTION f_controlduplicidad(
    psseguro  IN NUMBER,
    pcmatric  IN VARCHAR2,
    pnbastid  IN VARCHAR2,
    pcodmotor IN VARCHAR2,
    psproduc  IN NUMBER,
    pfefecto  IN DATE,
    pcchasis  IN VARCHAR2 DEFAULT NULL,
    ptablas   IN VARCHAR2 DEFAULT 'EST',
    pctipmat  IN NUMBER DEFAULT NULL) -- Tipo Matricula   --   43206/26797 --ECP -- 01/08/2016)
  RETURN NUMBER
IS
  vpasexec NUMBER(8) := 0;
  nerror   NUMBER    := 0;
  nerror1  NUMBER;
  nerror2  NUMBER;
  nerror3  NUMBER;
  nerror4  NUMBER;
  -- INI BUG 0018167 - 27/07/2015 - RCM - Se crean las variables para manejar nuevas excepciones
  nerror5  NUMBER; -- Error 1 de propuestas de alta/suplemento pendientes
  nerror6  NUMBER; -- Error 2 de propuestas de alta/suplemento con fecha de vencim futura
  nerror7  NUMBER; -- Error 3 de propuestas de alta/suplemento con fecha de anulac. futura
  nerror8  NUMBER; -- Error 1 de polizas vigentes
  nerror9  NUMBER; -- Error 2 de polizas vigentes con fecha de vencimiento futura
  nerror10 NUMBER; -- Error 3 de polizasvigentes con fecha de anulación futura
  nerror11 NUMBER; -- Error 1 de polizas vigentes con fecha de anulación futura  -- INI 43206/25265 -- ECP -- 28/06/2016
  -- FIN BUG 0018167 - 27/07/2015 - RCM
  v_sproduc   NUMBER; -- Ini 43105 -- ECP -- 09/05/2018
  vparam      VARCHAR2(4000) := 'parámetros -  psseguro:' || psseguro || ' pcmatric: ' || pcmatric || ' pnbastid: ' || pnbastid || ' pcodmotor: ' || pcodmotor || ' psproduc: ' || psproduc || ' pfefecto: ' || pfefecto || ' pcchasis: ' || pcchasis;
  vobjectname VARCHAR2(200)  := 'PAC_AUTOS.f_controlduplicidad';
  --INI  09/06/2020  JMC  QT61433
  v_espuac    NUMBER;
  --FIN  09/06/2020  JMC  QT61433
  --INI  17/11/2021  JMC  QT72215
  nerror12    NUMBER; --Error de polizas rehabilitadas con matriculas vigentes posteriores
  --FIN  17/11/2021  JMC  QT72215
   vcagente   NUMBER;-- DV 01/07/2022 QT	0074849: Cotizacion placa con poliza vigente
   vcagentep  NUMBER;-- DV 01/07/2022 QT	0074849: Cotizacion placa con poliza vigente
   vcantsimul  NUMBER;-- DV 07/02/2023 QT	AITSSD-5624:Emision doble póliza PUAC Falabella para misma placa RDT812
BEGIN
-- INI 0061570 ASN 26/06/2020 (excluir tambien SOAT)
/*
  -- Ini 0052909 -- SOTO -- 18/07/2019 No permite generar cobros para la póliza No. 305557 certif 1 placa WLX766 // SRC-Solo RC
  -- se excluye al producto 6049 SOLO RC de las validaciones de duplicidad por placa motor y bastidor
  IF psproduc =6049 THEN
     return nerror;
  END IF;
  -- Fin 0052909 -- SOTO -- 18/07/2019
*/
   --INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
   --IF psproduc IN (6049,900730) THEN
  -- INI DMRL CRILS-1006 08/04/2024
	  p_control_error ('DMRL', vobjectname, 'No 1 '||'vparam :'||vparam||'err SQL'||SUBSTR(' -Linea: '||dbms_utility.format_call_stack, 1, 2500));
  -- FIN DMRL CRILS-1006 08/04/2024
   IF NVL(f_parproductos_v(psproduc, 'SINCONTROLDUPLI'), 0) = 1 THEN
   --FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
     return nerror;
   END IF;
-- FIN 0061570 ASN 26/06/2020
  --INI  09/06/2020  JMC  QT61433
  v_espuac := NVL(f_parproductos_v(psproduc, 'ESPUAC'), 0);
  --FIN  09/06/2020  JMC  QT61433

  IF ptablas = 'EST' THEN
    --Ini 45385 -- ECP -- 08/08/2018
    IF pcmatric IS NOT NULL THEN
      -- INI BUG 0018167 - 27/07/2015 - RCM - Crear las consultas individuales en cada validacion de la placa
      --Validación 1: La placa esta siendo usada en otra(s) propuesta(s) de alta o suplemento pendiente(s).
      SELECT COUNT(1)
      INTO nerror5
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
        -- INICIO (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		union
		select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        )
        -- FIN (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'PLACA_DUPLICADA'
        AND p.cvalpar   = 1
        )
      AND r.nmovimi =
        (SELECT MAX(nmovimi)
        FROM autriesgos
        WHERE autriesgos.sseguro = s.sseguro
        )
      AND r.ctipmat      = pctipmat -- Tipo Matricula   --   41722 --ECP -- 26/04/2018
      AND r.cmatric      = pcmatric
      AND(r.sseguro NOT IN
        (SELECT ssegpol FROM estseguros WHERE sseguro = psseguro
        )
      OR psseguro   IS NULL)
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0) FROM productos WHERE sproduc = s.sproduc
        )))
      AND(csituac      IN(4, 5)) -- propuestas de alta/suplemento
      AND NOT(s.csituac = 4
      AND creteni      IN(3, 4 , 8,16)) -- propuestas diferentes a las no aceptadas, o anuladas --DV 08/01/2025 AITSSD-23780 Emisión póliza  en estado Inspección rechazada genera bloqueo de placa
      AND(s.fvencim    IS NULL)  -- propuestas no vencidas
      AND(s.fanulac    IS NULL); -- propuestas no anuladas
      -- Validación 2 : La placa esta siendo usada en otra(s) propuesta(s) de alta o suplemento pendiente(s)
      -- que vencerán a futuro.
 -- INI DMRL CRILS-1006 08/04/2024
	  p_control_error ('DMRL', vobjectname, 'No 2 '||'vparam :'||vparam||' nerror5: '||nerror5||'err SQL'||SUBSTR(' -Linea: '||dbms_utility.format_call_stack, 1, 2500));
 -- FIN DMRL CRILS-1006 08/04/2024
      SELECT COUNT(1)
      INTO nerror6
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
        -- INICIO (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		union
		select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        )
        -- FIN (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'PLACA_DUPLICADA'
        AND p.cvalpar   = 1
        )
      AND r.nmovimi =
        (SELECT MAX(nmovimi)
        FROM autriesgos
        WHERE autriesgos.sseguro = s.sseguro
        )
      AND r.ctipmat      = pctipmat -- Tipo Matricula   --   41722 --ECP -- 26/04/2018
      AND r.cmatric      = pcmatric
      AND(r.sseguro NOT IN
        (SELECT ssegpol FROM estseguros WHERE sseguro = psseguro
        )
      OR psseguro   IS NULL)
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0)
        FROM productos
        WHERE sproduc = s.sproduc
        )))
      AND(csituac                                         IN(4, 5)) -- propuestas de alta/suplemento
      AND NOT(s.csituac                                    = 4
      AND creteni                                         IN(3, 4,8,16)) -- propuestas diferentes a las no aceptadas, o anuladas --DV 08/01/2025 AITSSD-23780 Emisión póliza  en estado Inspección rechazada genera bloqueo de placa
      AND(s.fvencim                                       IS NOT NULL
      AND TRUNC(s.fvencim)                                        > pfefecto -- propuestas que se vence a futuro   --BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1        -- con anulacion programada
      OR pac_anulacion.f_esta_anulada_vto(s.sseguro)       = 1        -- con anulacion al vencimiento
      OR(3                                                 =
        (SELECT cduraci -- con duración al vencimiento
        FROM productos
        WHERE sproduc = s.sproduc
        )
      AND TRUNC(s.fefecto) <= pfefecto)));--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      -- Validación 3 : La placa esta siendo usada en otra(s) propuesta(s) de alta o suplemento pendiente(s)
      -- con fecha de anulación futura.
 -- INI DMRL CRILS-1006 08/04/2024
	  p_control_error ('DMRL', vobjectname, 'No 3 '||'vparam :'||vparam||' nerror6: '||nerror6||'err SQL'||SUBSTR(' -Linea: '||dbms_utility.format_call_stack, 1, 2500));
 -- FIN DMRL CRILS-1006 08/04/2024
      SELECT COUNT(1)
      INTO nerror7
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
        -- INICIO (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		union
		select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        )
        -- FIN (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'PLACA_DUPLICADA'
        AND p.cvalpar   = 1
        )
      AND r.nmovimi =
        (SELECT MAX(nmovimi)
        FROM autriesgos
        WHERE autriesgos.sseguro = s.sseguro
        )
      AND r.ctipmat      = pctipmat -- Tipo Matricula   --   41722 --ECP -- 26/04/2018
      AND r.cmatric      = pcmatric
      AND(r.sseguro NOT IN
        (SELECT ssegpol FROM estseguros WHERE sseguro = psseguro
        )
      OR psseguro   IS NULL)
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0) FROM productos WHERE sproduc = s.sproduc
        )))
      AND(csituac      IN(4, 5)) -- propuestas de alta/suplemento
      AND NOT(s.csituac = 4
      AND creteni      IN(3, 4,8,16)) -- propuestas diferentes a las no aceptadas, o anuladas --DV 08/01/2025 AITSSD-23780 Emisión póliza  en estado Inspección rechazada genera bloqueo de placa
      AND(s.fanulac    IS NOT NULL
      AND TRUNC(s.fanulac)     > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --Ini 41372/25353 -- ECP -- 14/04/2016
      AND TRUNC(s.fanulac) >  --BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        (SELECT TRUNC(fcaranu) FROM seguros WHERE sseguro = psseguro--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        )
        --Fin 41372/25353 --ECP -- 14/04/2016
        ); -- propuestas con fechas de anulacion futura
      -- Validación 4 : La placa esta siendo usada en otra(s) poliza(s) vigente(s) .
 -- INI DMRL CRILS-1006 08/04/2024
	  p_control_error ('DMRL', vobjectname, 'No 4 '||'vparam :'||vparam||' nerror7: '||nerror7||'err SQL'||SUBSTR(' -Linea: '||dbms_utility.format_call_stack, 1, 2500));
 -- FIN DMRL CRILS-1006 08/04/2024
      SELECT COUNT(1)
      INTO nerror8
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
        -- INICIO (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		union
		select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        )
        -- FIN (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'PLACA_DUPLICADA'
        AND p.cvalpar   = 1
        )
      AND r.nmovimi =
        (SELECT MAX(nmovimi)
        FROM autriesgos
        WHERE autriesgos.sseguro = s.sseguro
        )
      AND r.ctipmat = pctipmat -- Tipo Matricula   --   43206/26797 --ECP -- 01/08/2016
      AND r.cmatric = pcmatric
        --- IGIL Tarea 36247 / 206491 Tomar sseguro real y no de las tablas est (ssegpol)
        -- Ini 41722 -- ECP -- 02/05/2018
        --Ini Bug 0043148 - AGP -17/05/2018 - Se reversa cambio realizado Bug 41722, No permite realizar suplementos
      AND(r.sseguro NOT IN
        (SELECT ssegpol FROM estseguros WHERE sseguro = psseguro
        -- Ini 47761 -- SPV -- 04/12/2018
        UNION
        SELECT sseguro FROM seguros WHERE sseguro = psseguro
        )
      OR psseguro IS NULL)
        -- Fin 41722 -- ECP -- 02/05/2018
        --Fin Bug 0043148 - AGP -17/05/2018
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0) FROM productos WHERE sproduc = s.sproduc
        )))
        --Ini 43206/25265 -- ECP -- 20/06/2016
        -- INI BUG 32648 - CSI - 17/04/2017 - Se ajusta condición, para que el mensaje se arroje cuando la fecha de proxima cartera o fecha de cartera anual sean inferiores a la fecha de solicitud
        -- Ini 47909 -- ECP -- 27/11/2018
        --INI QT 0051836 DV mejora de consulta de validaciones placa, motor, chasis, en la validacion de fechas para polizas de autos existentes.
      AND((TRUNC(s.fcarpro) > pfefecto) -- BUG 52378 - RCM - 13/06/2019 --BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      OR (TRUNC(s.fcaranu)  > pfefecto) -- BUG 52378 - RCM - 13/06/2019 --BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --FIN QT 0051836 DV mejora de consulta de validaciones placa, motor, chasis, en la validacion de fechas para polizas de autos existentes.
      AND TRUNC(s.fcaranu) <> TRUNC(s.fcarpro))--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --INI SPV 28/01/2019 0049158: iAxis permite cotizar placas con póliza
        -- Se tienen en cuenta productos de auto individual para las cotizaciones
      AND s.cramo IN (105, 104) --47761 SPV -- 04/12/2018 Solo se toman los productos colectivos de auto
        --FIN SPV 28/01/2019 0049158: iAxis permite cotizar placas con póliza
        --Fin 47909 -- ECP -- 27/11/2018
        -- FIN BUG 32648 - CSI  - 17/04/2017 Se ajusta condición, para que el mensaje se arroje cuando la fecha de proxima cartera o fecha de cartera anual sean inferiores a la fecha de solicitud
        --Fin 43206/25265 -- ECP -- 20/06/2016
      AND(csituac NOT IN(2, 4, 5) -- poliza
        -- Fin 47761 -- SPV -- 04/12/2018
      AND(f_vigente(s.sseguro, NULL, pfefecto)  = 0
      OR(TRUNC(s.fefecto)                              > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND f_vigente(s.sseguro, NULL, TRUNC(s.fefecto)) = 0)))--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      --INI  09/06/2020  JMC  QT61433
      AND (v_espuac = 0 OR (v_espuac = 1 AND f_excepcion_agente(psseguro, s.cagente, ptablas) = 0))
      --FIN  09/06/2020  JMC  QT61433
      AND(s.fvencim                            IS NULL)  -- polizas no vencidas
      AND(s.fanulac                            IS NULL); -- polizas no anuladas
      --Ini 41372/25265 -- ECP -- 28/06/2016
      -- Validación 11 : La placa esta siendo usada en otra(s) poliza(s) vigente(s) con fechas de anulacion futura.
      SELECT COUNT(1)
      INTO nerror11
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
      AND r.nmovimi   =
        (SELECT MAX(nmovimi)
        FROM autriesgos
        WHERE autriesgos.sseguro = s.sseguro
        )
      AND r.ctipmat = pctipmat -- Tipo Matricula   --   41722 --ECP -- 26/04/2018
      AND r.cmatric = pcmatric
        --- IGIL Tarea 36247 / 206491 Tomar sseguro real y no de las tablas est (ssegpol)
      AND(r.sseguro NOT IN
        (SELECT ssegpol FROM estseguros WHERE sseguro = psseguro
        -- Ini 47761 -- SPV -- 04/12/2018
        UNION
        SELECT sseguro
        FROM seguros
        WHERE sseguro = psseguro
          -- Fin 47761 -- SPV -- 04/12/2018
        )
      OR psseguro   IS NULL)
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc  --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0) FROM productos WHERE sproduc = s.sproduc
        )))
        --Ini 43206/25265 -- ECP -- 20/06/2016
      AND(TRUNC(s.fcarpro) > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(TRUNC(s.fcaranu) > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --Fin 43206/25265 -- ECP -- 20/06/2016
      AND(csituac NOT                          IN(4, 5) -- poliza
      AND(f_vigente(s.sseguro, NULL, pfefecto)  = 0
      OR(TRUNC(s.fefecto)                              > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND f_vigente(s.sseguro, NULL, TRUNC(s.fefecto)) = 0)))--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(s.fvencim                            IS NULL) -- polizas no vencidas
      AND(s.fanulac                            IS NOT NULL
      AND TRUNC(s.fanulac)                             > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --Ini 41372/25353 -- ECP -- 14/04/2016
      --INI  20/07/2021  JMC  QT69419
      --AND TRUNC(s.fanulac) >--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      --  (SELECT TRUNC(fcaranu) FROM seguros WHERE sseguro = psseguro--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      --  ))-- polizas con fechas de anulacion futura
      )
      --FIN  20/07/2021  JMC  QT69419
         --Fin 41372/25265 --ECP -- 28/06/2016

        -- INI 0052909 11/07/2019 SOT exclusion producto 6049 solo rc para placas duplicadas
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		AND S.SPRODUC NOT IN (select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1);
	  --  AND NVL(f_parproductos_v(s.sproduc, 'NO_VALIDA_MATRICULA'), 0) = 0  ;
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        -- FIN 0052909 11/07/2019
      -- Validación 5 : La placa esta siendo usada en otra(s) poliza(s) vigente(s) que vencerá(n) a futuro.
      SELECT COUNT(1)
      INTO nerror9
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
        -- INICIO (25263 + LCOL-126):DCT - 11/07/2016
        -- INI 65862 - 18/01/2020 - Validación errada póliza vigente placa WGQ484
        /*
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
        )*/
      AND s.sproduc NOT IN
      --Ini DV 25/11/2021 QT 0072107: cliente tiene una poliza vigente y otra con inicio de vigencia futura,el servicio responde que no tiene poliza vigente D &||D
       /* ((SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
        ),900730)*/
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		(SELECT p.sproduc  FROM parproductos p  WHERE p.cparpro = 'POLIZA_UNICA' AND p.cvalpar = 0 --union all select 900730 psproduc from dual)
		 union
		select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1)
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
      --Fin DV 25/11/2021 QT 0072107: cliente tiene una poliza vigente y otra con inicio de vigencia futura,el servicio responde que no tiene poliza vigente D &||D
        -- FIN 65862 - 18/01/2020 - Validación errada póliza vigente placa WGQ484
        -- FIN (25263 + LCOL-126):DCT - 11/07/2016
      AND r.nmovimi =
        (SELECT MAX(nmovimi)
        FROM autriesgos
        WHERE autriesgos.sseguro = s.sseguro
        )
      AND r.ctipmat      = pctipmat -- Tipo Matricula   --   41722 --ECP -- 26/04/2018
      AND r.cmatric      = pcmatric
      AND(r.sseguro NOT IN
        (SELECT sseguro FROM estseguros WHERE sseguro = psseguro
        )
      OR psseguro   IS NULL)
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0)
        FROM productos
        WHERE sproduc = s.sproduc
        )))
      AND(csituac NOT                                     IN(4, 5) -- poliza
      AND(f_vigente(s.sseguro, NULL, pfefecto)             = 0
      OR(TRUNC(s.fefecto)                                         > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND f_vigente(s.sseguro, NULL, TRUNC(s.fefecto))            = 0)))--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(s.fvencim                                       IS NOT NULL
      AND TRUNC(s.fvencim)                                        > pfefecto -- poliza que se vence a futuro--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1        -- con anulacion programada
      OR pac_anulacion.f_esta_anulada_vto(s.sseguro)       = 1        -- con anulacion al vencimiento
      OR(3                                                 =
        (SELECT cduraci -- coon duración al vencimiento
        FROM productos
        WHERE sproduc = s.sproduc
        )
      AND TRUNC(s.fefecto) <= pfefecto)));--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      -- Validación 6 : La placa esta siendo usada en otra(s) poliza(s) vigente(s) con fecha de anulación futura.
      SELECT COUNT(1)
      INTO nerror10
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
        -- INICIO (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		union
		select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        )
        -- FIN (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'PLACA_DUPLICADA'
        AND p.cvalpar   = 1
        )
      AND r.nmovimi =
        (SELECT MAX(nmovimi)
        FROM autriesgos
        WHERE autriesgos.sseguro = s.sseguro
        )
      AND r.ctipmat      = pctipmat -- Tipo Matricula   --   41722 --ECP -- 26/04/2018
      AND r.cmatric      = pcmatric
      AND(r.sseguro NOT IN
        (SELECT sseguro FROM estseguros WHERE sseguro = psseguro
        )
      OR psseguro   IS NULL)
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0) FROM productos WHERE sproduc = s.sproduc
        )))
      AND(csituac NOT                          IN (4, 5, 2) --BUG 0032287 - 29/03/2017 - CASL - Se añade al filtro la situacion 2(Anulada)
      AND(f_vigente(s.sseguro, NULL, pfefecto)  = 0
      OR(TRUNC(s.fefecto)                              > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND f_vigente(s.sseguro, NULL, TRUNC(s.fefecto)) = 0)))--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(s.fanulac                            IS NOT NULL
      AND(TRUNC(s.fanulac)                             > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --Ini 41372/25353 -- ECP -- 14/04/2016
        -- Ini 30453 -- ECP -- 20/01/2017
      OR TRUNC(s.fanulac) >--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        (SELECT TRUNC(fcaranu) FROM seguros WHERE sseguro = psseguro--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        ))
        --Fin 30453 -- ECP -- 20/01/2017
        --Fin 41372/25353 --ECP -- 14/04/2016
        ); -- polizas con fechas de anulacion futura
      -- FIN BUG 0018167 - 27/07/2015 ¿ RCM
    END IF;
    IF pnbastid IS NOT NULL THEN
      SELECT COUNT(1)
      INTO nerror2
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
        -- INICIO (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		union
		select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        )
        -- FIN (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'PLACA_DUPLICADA'
        AND p.cvalpar   = 1
        )
        -- Ini 48619 -- ECP-- 28/12/2018
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro LIKE '%SOAT%'
        AND p.cvalpar = 1
        )
        --Fin 48619 --  ECP -- 28/12/2018
      AND r.nbastid = pnbastid
        -- Ini 41722 -- ECP -- 02/05/2018
        --Ini Bug 0043148 - AGP -17/05/2018 - Se reversa cambio realizado Bug 41722, No permite realizar suplementos
      AND(r.sseguro NOT IN
        (SELECT ssegpol FROM estseguros WHERE sseguro = psseguro
        )
        -- Fin 41722 -- ECP -- 02/05/2018
        --Fin Bug 0043148 - AGP -17/05/2018
      OR psseguro   IS NULL)
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0) FROM productos WHERE sproduc = s.sproduc
        )))
        -- AND r.fanulac IS NULL --que el riesgo no este anulado
        -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
        -- AND s.csituac <> 2 -- que no estén anuladas
        --  AND s.csituac NOT IN(2, 3)   -- que no estén anuladas ni vencidas
        --Ini 43206/25265 -- ECP -- 20/06/2016
        --Ini 47909 -- ECP -- 27/11/2018
        --INI QT 0051836 DV mejora de consulta de validaciones placa, motor, chasis, en la validacion de fechas para polizas de autos existentes.
      AND((TRUNC(s.fcarpro) > pfefecto) -- BUG 52378 - RCM - 13/06/2019--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      OR (TRUNC(s.fcaranu)  > pfefecto) -- BUG 52378 - RCM - 13/06/2019--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND TRUNC(s.fcaranu) <> TRUNC(s.fcarpro))--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --FIN QT 0051836 DV mejora de consulta de validaciones placa, motor, chasis, en la validacion de fechas para polizas de autos existentes.
        --Fin 47909 -- ECP -- 27/11/2018
        --Fin 47475 -- ECP -- 06/11/2018
        --Fin 43206/25265 -- ECP -- 20/06/2016
      AND(f_vigente(s.sseguro, NULL, pfefecto) = 0
      OR csituac                              IN(4, 5)
        -- Bug 31686/178722 - 04/07/2014 - AMC
      OR(TRUNC(s.fefecto)                              > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND f_vigente(s.sseguro, NULL, TRUNC(s.fefecto)) = 0))--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        -- FI BUG 11330 - 15/10/2009 ¿ FAL
      AND NOT(s.csituac = 4
      AND creteni      IN(3, 4,8,16)) --DV 08/01/2025 AITSSD-23780 Emisión póliza  en estado Inspección rechazada genera bloqueo de placa
        -- Ini 47909 -- ECP -- 27/11/2018
        -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
        -- Ini 60276 -- 15/04/2020: validación VIN en póliza vigente
      --
      --INI BUG 0061331 - 29/05/2020 - CASL - Se reversa bug 60276
      --
      AND((s.fvencim                                       IS NOT NULL
      AND TRUNC(s.fvencim)                                         > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      OR s.fvencim                                         IS NULL
      AND((pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1))
      OR pac_anulacion.f_esta_anulada_vto(s.sseguro)        = 1)

      /*AND((s.fvencim                                      IS NULL)
      OR(s.fvencim                                        IS NOT NULL
      AND s.fvencim                                        > pfefecto)
      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1
      OR pac_anulacion.f_esta_anulada_vto(s.sseguro)       = 1))*/
      --
      --FIN BUG 0061331 - 29/05/2020 - CASL
      --
      -- Fin 60276 -- 15/04/2020: validación VIN en póliza vigente
        -- Fin 47909 -- ECP -- 27/11/2018
      AND((s.fanulac IS NOT NULL)--BUG GZG 0069313 30/06/2021
      OR (TRUNC(s.fanulac)   > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --Ini 41372/25353 -- ECP -- 14/04/2016
      AND TRUNC(s.fanulac) >--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        (SELECT TRUNC(fcaranu) FROM seguros WHERE sseguro = psseguro--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        )
        --Fin 41372/25353 --ECP -- 14/04/2016
        )
        --BUG 28455/156716 - RCL - 28/10/2013 - QT-0009745: Error al validar matriculas
      --INI  09/06/2020  JMC  QT61433
      AND (v_espuac = 0 OR (v_espuac = 1 AND f_excepcion_agente(psseguro, s.cagente, ptablas) = 0))
      --FIN  09/06/2020  JMC  QT61433
      AND r.nmovimi =
        (SELECT MAX(nmovimi) FROM autriesgos WHERE autriesgos.sseguro = s.sseguro
        );
    END IF;
    -- Ini 43105 -- ECP -- 09/05/2018
    IF pcodmotor IS NOT NULL THEN
      SELECT COUNT(1)
      INTO nerror3
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
        -- INICIO (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		union
		select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        )
        -- FIN (25263 + LCOL-126):DCT - 11/07/2016
      AND r.codmotor = pcodmotor
        -- Ini 41722 -- ECP -- 02/05/2018
        --Ini Bug 0043148 - AGP -17/05/2018 - Se reversa cambio realizado Bug 41722, No permite realizar suplementos
      AND(r.sseguro NOT IN
        (SELECT ssegpol FROM estseguros WHERE sseguro = psseguro
        -- Ini 47761 -- SPV -- 04/12/2018
        UNION
        SELECT sseguro FROM seguros WHERE sseguro = psseguro
        )
        -- Fin 41722 -- ECP -- 02/05/2018
        --Fin Bug 0043148 - AGP -17/05/2018
      OR psseguro   IS NULL)
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0) FROM productos WHERE sproduc = s.sproduc
        )))
        -- AND r.fanulac IS NULL --que el riesgo no este anulado
        -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
        -- AND s.csituac <> 2 -- que no estén anuladas
        -- AND s.csituac NOT IN(2, 3)   -- que no estén anuladas ni vencidas
        -- FI BUG 11330 - 15/10/2009 ¿ FAL
        --Ini 43206/25265 -- ECP -- 20/06/2016
        --Ini 47909 -- ECP -- 27/11/2018
        --INI QT 0051836 DV mejora de consulta de validaciones placa, motor, chasis, en la validacion de fechas para polizas de autos existentes.
      AND((TRUNC(s.fcarpro) > pfefecto) -- BUG 52378 - RCM - 13/06/2019--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      OR (TRUNC(s.fcaranu)  > pfefecto) -- BUG 52378 - RCM - 13/06/2019--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND TRUNC(s.fcaranu) <> TRUNC(s.fcarpro))--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --FIN QT 0051836 DV mejora de consulta de validaciones placa, motor, chasis, en la validacion de fechas para polizas de autos existentes.
        -- INI SPV 28/01/2019 0049158: iAxis permite cotizar placas con póliza vigente
        -- Se tienen en cuenta productos de auto individual para las cotizaciones
      AND s.cramo IN (105, 104) --47761 SPV -- 04/12/2018 Solo se toman los productos colectivos de auto
        -- FIN SPV 28/01/2019 0049158: iAxis permite cotizar placas con póliza vigente
        --Fin 47909 -- ECP -- 27/11/2018
        --Fin 43206/25265 -- ECP -- 20/06/2016
      AND(f_vigente(s.sseguro, NULL, pfefecto) = 0
      OR csituac                              IN(4, 5)
        -- Bug 31686/178722 - 04/07/2014 - AMC
      OR(TRUNC(s.fefecto)                              > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND f_vigente(s.sseguro, NULL, TRUNC(s.fefecto)) = 0))--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND NOT(s.csituac                         = 4
      AND creteni                              IN(3, 4,8,16)) --DV 08/01/2025 AITSSD-23780 Emisión póliza  en estado Inspección rechazada genera bloqueo de placa
      AND NOT(s.csituac                         = 2)
        -- Fin 47761 -- SPV -- 04/12/2018
        -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
      AND((s.fvencim                                      IS NULL)
      OR(s.fvencim                                        IS NOT NULL
      AND TRUNC(s.fvencim)                                        > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1
      OR pac_anulacion.f_esta_anulada_vto(s.sseguro)       = 1)))
      AND((s.fanulac                                      IS NULL)
      OR (TRUNC(s.fanulac)                                        > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --Ini 41372/25353 -- ECP -- 14/04/2016
      AND TRUNC(s.fanulac) >--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        (SELECT TRUNC(fcaranu) FROM seguros WHERE sseguro = psseguro--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        )
        --Fin 41372/25353 --ECP -- 14/04/2016
        )
        --BUG 28455/156716 - RCL - 28/10/2013 - QT-0009745: Error al validar matriculas
      --INI  09/06/2020  JMC  QT61433
      AND (v_espuac = 0 OR (v_espuac = 1 AND f_excepcion_agente(psseguro, s.cagente, ptablas) = 0))
      --FIN  09/06/2020  JMC  QT61433
      AND r.nmovimi =
        (SELECT MAX(nmovimi) FROM autriesgos WHERE autriesgos.sseguro = s.sseguro
        );
      -- Fin 43105 -- ECP -- 09/05/2018
    END IF;
    --dc_p_trazas('08052018','psseguro -->'||psseguro||' pfefecto<'||pfefecto||'>psproduc < '||psproduc||' pcodmotor <'||pcodmotor);
    --BUG 26435 - INICIO - DCT - 15/03/2013
    IF pcchasis IS NOT NULL THEN
      SELECT COUNT(1)
      INTO nerror4
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
        -- INICIO (25263 + LCOL-126):DCT - 11/07/2016
        -- INI 65862 - 18/01/2020 - Validación errada póliza vigente placa WGQ484
        /*
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
        )*/
      AND s.sproduc NOT IN
       --Ini DV 25/11/2021 QT 0072107: cliente tiene una poliza vigente y otra con inicio de vigencia futura,el servicio responde que no tiene poliza vigente D &||D
      /*  ((SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
        ),900730)*/
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        (SELECT p.sproduc  FROM parproductos p  WHERE p.cparpro = 'POLIZA_UNICA' AND p.cvalpar = 0 --union all select 900730 psproduc from dual)
		 union
		 select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1)
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        --Fin DV 25/11/2021 QT 0072107: cliente tiene una poliza vigente y otra con inicio de vigencia futura,el servicio responde que no tiene poliza vigente D &||D
        -- FIN 65862 - 18/01/2020 - Validación errada póliza vigente placa WGQ484
        -- FIN (25263 + LCOL-126):DCT - 11/07/2016
      AND r.cchasis = pcchasis
        -- Ini 41722 -- ECP -- 02/05/2018
        --Ini Bug 0043148 - AGP -17/05/2018 - Se reversa cambio realizado Bug 41722, No permite realizar suplementos
      AND(r.sseguro NOT IN
        (SELECT ssegpol FROM estseguros WHERE sseguro = psseguro
        )
        -- Fin 41722 -- ECP -- 02/05/2018
        --Fin Bug 0043148 - AGP -17/05/2018
      OR psseguro   IS NULL)
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT scumulo FROM cum_cumprod WHERE cproduc = psproduc
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0) FROM productos WHERE sproduc = s.sproduc
        )))
        -- AND r.fanulac IS NULL --que el riesgo no este anulado
        -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
        -- AND s.csituac <> 2 -- que no estén anuladas
        --  AND s.csituac NOT IN(2, 3)   -- que no estén anuladas ni vencidas
        --Ini 43206/25265 -- ECP -- 20/06/2016
      AND(TRUNC(s.fcarpro) > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(TRUNC(s.fcaranu) > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --Fin 43206/25265 -- ECP -- 20/06/2016
      AND(f_vigente(s.sseguro, NULL, pfefecto) = 0
      OR csituac                              IN(4, 5)
        -- Bug 31686/178722 - 04/07/2014 - AMC
      OR(TRUNC(s.fefecto)                              > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND f_vigente(s.sseguro, NULL, TRUNC(s.fefecto)) = 0))--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        -- FI BUG 11330 - 15/10/2009 ¿ FAL
      AND NOT(s.csituac = 4
      AND creteni      IN(3, 4, 8,16)) --DV 08/01/2025 AITSSD-23780 Emisión póliza  en estado Inspección rechazada genera bloqueo de placa
        -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pÃ³lizas con vencimiento programado a fecha anterior al efecto de la nueva pÃ³liza
      AND((s.fvencim                                      IS NULL)
      OR(s.fvencim                                        IS NOT NULL
      AND TRUNC(s.fvencim)                                        > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1
      OR pac_anulacion.f_esta_anulada_vto(s.sseguro)       = 1)))
        --INI QT 0051836 DV mejora de consulta de validaciones placa, motor, chasis, en la validacion de fechas para polizas de autos existentes.
      AND((s.fanulac IS NULL)     -- BUG 52378 - RCM - 13/06/2019
      OR (TRUNC(s.fanulac)   > pfefecto) -- BUG 52378 - RCM - 13/06/2019--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --FIN QT 0051836 DV mejora de consulta de validaciones placa, motor, chasis, en la validacion de fechas para polizas de autos existentes.
        --Ini 41372/25353 -- ECP -- 14/04/2016
      AND TRUNC(s.fanulac) >--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        (SELECT TRUNC(fcaranu) FROM seguros WHERE sseguro = psseguro--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        )
        --Fin 41372/25353 --ECP -- 14/04/2016
        )
        --BUG 28455/156716 - RCL - 28/10/2013 - QT-0009745: Error al validar matriculas
      --INI  09/06/2020  JMC  QT61433
      AND (v_espuac = 0 OR (v_espuac = 1 AND f_excepcion_agente(psseguro, s.cagente, ptablas) = 0))
      --FIN  09/06/2020  JMC  QT61433
      AND r.nmovimi =
        (SELECT MAX(nmovimi) FROM autriesgos WHERE autriesgos.sseguro = s.sseguro
        );
    END IF;
    --BUG 26435 - FIN - DCT - 15/03/2013
    -- INI BUG 0055282 - 16/10/2019 - GZG
   --Ini DV 25/11/2021 QT 0072107: cliente tiene una poliza vigente y otra con inicio de vigencia futura,el servicio responde que no tiene poliza vigente D &||D
     if nerror8 = 0 then
   --Fin DV 25/11/2021 QT 0072107: cliente tiene una poliza vigente y otra con inicio de vigencia futura,el servicio responde que no tiene poliza vigente D &||D
SELECT COUNT(1)
INTO nerror8
FROM autriesgos r,
  seguros s
WHERE r.sseguro    = s.sseguro
AND s.sproduc NOT IN
  (SELECT p.sproduc
  FROM parproductos p
  WHERE p.cparpro = 'POLIZA_UNICA'
  AND p.cvalpar   = 0
  --INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
	union
	select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1
  --FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
  )
AND r.nmovimi =
  (SELECT MAX(nmovimi)
  FROM autriesgos
  WHERE autriesgos.sseguro = s.sseguro
  )
AND r.ctipmat      = pctipmat
AND r.cmatric      = pcmatric
AND(r.sseguro NOT IN
  (SELECT sseguro FROM seguros WHERE sseguro = psseguro
  UNION
  SELECT ssegpol FROM estseguros WHERE sseguro = psseguro
  )
OR psseguro   IS NULL)
AND(s.sproduc IN
  (SELECT cp.cproduc
  FROM cum_cumprod cp,
    cum_cumulo cc
  WHERE cc.scumulo = cp.ccumulo
  AND cc.cnivel    = 0
  AND cc.scumulo  IN
            (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
    )
  )
OR(0 IN
  (SELECT NVL(creaseg, 0) FROM productos WHERE sproduc = s.sproduc
  )))
AND s.cramo   IN (105, 104)
--Ini DV QT AITSSD-3143 Póliza en estado Propuesta cartera / Prop. Cartera Pdte. Autor. permite emitir póliza nueva con misma placa
--AND csituac = 0
--INI 16/12/2022 DV QT AITSSD-4183 No permite cotizar / emitir error "La placa está siendo usada en una póliza vigente" rollback de la instalacion del ticket 3143
AND csituac    not in(2,3,4,6,10)
--FIN 16/12/2022 DV QT AITSSD-4183 No permite cotizar / emitir error "La placa está siendo usada en una póliza vigente" rollback de la instalacion del ticket 3143
--Fin DV QT AITSSD-3143 Póliza en estado Propuesta cartera / Prop. Cartera Pdte. Autor. permite emitir póliza nueva con misma placa
--INI  09/06/2020  JMC  QT61433
AND (v_espuac = 0 OR (v_espuac = 1 AND f_excepcion_agente(psseguro, s.cagente, ptablas) = 0))
--FIN  09/06/2020  JMC  QT61433
AND(s.fvencim IS NULL)
AND(s.fanulac IS NULL);
     --Ini DV 25/11/2021 QT 0072107: cliente tiene una poliza vigente y otra con inicio de vigencia futura,el servicio responde que no tiene poliza vigente D &||D
      end if;
     --Fin DV 25/11/2021 QT 0072107: cliente tiene una poliza vigente y otra con inicio de vigencia futura,el servicio responde que no tiene poliza vigente D &||D
      -- FIN BUG 0055282 - 16/10/2019 - GZG
     --Ini DV 07/02/2023 QT AITSSD-5624 Emision doble póliza PUAC Falabella para misma placa RDT812
     --Se adiciona validacion para evitar emision de polizas duplicadas por webservice
	 --se quitan trazas para que no pasen a produccion
	   --INI  DV 01/07/2022 QT	0074849: Cotizacion placa con poliza vigente
	   --INI DV 29/03/2023 QT AITSSD-6311 Cotización con la misma clave intermediario indica La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
	   IF pac_iax_produccion.issimul and pcmatric is not null and (nerror8 > 0 or nerror9 > 0 or nerror10 > 0 or nerror11 > 0 ) THEN
	   --FIN DV 29/03/2023 QT AITSSD-6311 Cotización con la misma clave intermediario indica La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
	     begin
           select count (sseguro) into vcantsimul from estseguros where sseguro = psseguro and csituac = 7;
         exception
          when others then
            vcantsimul := 0;
         end;
        IF vcantsimul = 0 then
          vcagente := nvl(pac_iax_produccion.poliza.det_poliza.cagente,0);
	      IF vcagente = 0 then
           nerror := 9000503; --Error al recuperar los datos del agente
          END IF;

         BEGIN
           SELECT distinct s.cagente
            INTO vcagentep
            FROM autriesgos r,
            seguros s
            WHERE r.sseguro = s.sseguro
            AND s.sproduc NOT IN
            (SELECT p.sproduc
            FROM parproductos p
            WHERE p.cparpro = 'POLIZA_UNICA'
            AND p.cvalpar   = 0
			--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		    union
		    select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1
		    --FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
            )
            AND s.sproduc NOT IN
            (SELECT p.sproduc
            FROM parproductos p
            WHERE p.cparpro = 'PLACA_DUPLICADA'
            AND p.cvalpar   = 1
            )
            AND r.nmovimi =
            (SELECT MAX(nmovimi)
            FROM autriesgos
            WHERE autriesgos.sseguro = s.sseguro
            )
            AND r.ctipmat = pctipmat -- Tipo Matricula
            AND r.cmatric = pcmatric
             AND(r.sseguro NOT IN
           (SELECT ssegpol FROM estseguros WHERE sseguro = psseguro

            UNION
            SELECT sseguro FROM seguros WHERE sseguro = psseguro
            )
            OR psseguro IS NULL)

            AND(s.sproduc IN
            (SELECT cp.cproduc
            FROM cum_cumprod cp,
              cum_cumulo cc
            WHERE cc.scumulo = cp.ccumulo
            AND cc.cnivel    = 0
            AND cc.scumulo  IN
              (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc
              )
            )
            OR(0 IN
            (SELECT NVL(creaseg, 0) FROM productos WHERE sproduc = s.sproduc
            )))
           --INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura(AITSSD-2587 cambios que faltaban)
			/*AND((TRUNC(s.fcarpro) > pfefecto)
            OR (TRUNC(s.fcaranu)  > pfefecto)
            AND TRUNC(s.fcaranu) <> TRUNC(s.fcarpro))*/
	    --FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
             AND s.cramo IN (105, 104)
             AND(csituac NOT IN(2, 4, 5)
             AND(f_vigente(s.sseguro, NULL, pfefecto)  = 0
            OR(TRUNC(s.fefecto)                              > pfefecto
            AND f_vigente(s.sseguro, NULL, TRUNC(s.fefecto)) = 0)))
        --INI DV 29/03/2023 QT AITSSD-6311 Cotización con la misma clave intermediario indica La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		    AND (v_espuac = 0 OR (v_espuac = 1 AND f_excepcion_agente(psseguro, s.cagente, ptablas) = 0));
          /* AND(s.fvencim                            IS NULL)
            AND(s.fanulac                            IS NULL);*/
		--FIN DV 29/03/2023 QT AITSSD-6311 Cotización con la misma clave intermediario indica La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
 -- INI DMRL CRILS-1006 08/04/2024
	  p_control_error ('DMRL', vobjectname, 'No 12 '||' f_user: '||f_user||' vparam :'||vparam||' vcagente '||vcagente||' vcagentep: '||vcagentep||'err SQL'||SUBSTR(' -Linea: '||dbms_utility.format_call_stack, 1, 2500));
 -- FIN DMRL CRILS-1006 08/04/2024
         EXCEPTION
          WHEN OTHERS THEN
             vcagentep := NULL;
          END;
  -- INI DMRL CRILS-1006 08/04/2024
         IF vcagentep > 0 AND vcagente = vcagentep AND f_user <> 'AXIS_LCOL' THEN
  -- FIN DMRL CRILS-1006 08/04/2024
           nerror8 := 0; --DEJAR HACER SIMULACION CON EL MISMO AGENTE PERO ESTA SE RESATRINGE SI SE DESEA EMITIR POR FECHAS EN CASO DE TRASLAPARSEN
           nerror2 := 0;
           nerror3 := 0;
           nerror4 := 0;
		   --INI DV 29/03/2023 QT AITSSD-6311 Cotización con la misma clave intermediario indica La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
           nerror9 := 0;
           nerror10 := 0;
           nerror11 := 0;
		   --FIN DV 29/03/2023 QT AITSSD-6311 Cotización con la misma clave intermediario indica La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
 -- INI DMRL CRILS-1006 08/04/2024
	  p_control_error ('DMRL', vobjectname, 'No 13 '||' f_user: '||f_user||' vparam :'||vparam||' vcagente '||vcagente||' nerror8 '||nerror8||' vcagentep: '||vcagentep||'err SQL'||SUBSTR(' -Linea: '||dbms_utility.format_call_stack, 1, 2500));
 -- FIN DMRL CRILS-1006 08/04/2024
          END IF;
       END IF;
      --Fin DV 07/02/2023 QT AITSSD-5624 Emision doble póliza PUAC Falabella para misma placa RDT812
	   END IF;
	   --FIN  DV 01/07/2022 QT	0074849: Cotizacion placa con poliza vigente
  ELSE
    IF pcmatric IS NOT NULL THEN
      -- INI BUG 0018167 - 27/07/2015 - RCM - Crear las consultas individuales en cada validacion de la placa
      -- Validación 1 : La placa esta siendo usada en otra(s) propuesta(s) de alta o suplemento pendiente(s) .
      SELECT COUNT(1)
      INTO nerror5
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
        -- INICIO (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		union
		select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        )
        -- FIN (25263 + LCOL-126):DCT - 11/07/2016
      AND r.nmovimi =
        (SELECT MAX(nmovimi)
        FROM autriesgos
        WHERE autriesgos.sseguro = s.sseguro
        )
      AND r.ctipmat      = pctipmat -- Tipo Matricula   --   41722 --ECP -- 26/04/2018
      AND r.cmatric      = pcmatric
      AND(r.sseguro NOT IN
        (SELECT sseguro FROM seguros WHERE sseguro = psseguro
        )
      OR psseguro   IS NULL)
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0) FROM productos WHERE sproduc = s.sproduc
        )))
      AND(csituac      IN(4, 5)) -- propuestas de alta/suplemento
      AND NOT(s.csituac = 4
      AND creteni      IN(3, 4,8,16)) -- propuestas diferentes a las no aceptadas, o anuladas --DV 08/01/2025 AITSSD-23780 Emisión póliza  en estado Inspección rechazada genera bloqueo de placa
      AND(s.fvencim    IS NULL)  -- propuestas no vencidas
      AND(s.fanulac    IS NULL); -- propuestas no anuladas
      -- Validación 2 : La placa esta siendo usada en otra(s) propuesta(s) de alta o suplemento pendiente(s) que vencerán a futuro.
 -- INI DMRL CRILS-1006 08/04/2024
	  p_control_error ('DMRL', vobjectname, 'No 14 '||'vparam :'||vparam||' vcagente '||vcagente||' nerror5 '||nerror5||' vcagentep: '||vcagentep||'err SQL'||SUBSTR(' -Linea: '||dbms_utility.format_call_stack, 1, 2500));
 -- FIN DMRL CRILS-1006 08/04/2024
      SELECT COUNT(1)
      INTO nerror6
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
        -- INICIO (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		union
		select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        )
        -- FIN (25263 + LCOL-126):DCT - 11/07/2016
      AND r.nmovimi =
        (SELECT MAX(nmovimi)
        FROM autriesgos
        WHERE autriesgos.sseguro = s.sseguro
        )
      AND r.ctipmat      = pctipmat -- Tipo Matricula   --   41722 --ECP -- 26/04/2018
      AND r.cmatric      = pcmatric
      AND(r.sseguro NOT IN
        (SELECT sseguro FROM seguros WHERE sseguro = psseguro
        )
      OR psseguro   IS NULL)
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0)
        FROM productos
        WHERE sproduc = s.sproduc
        )))
      AND(csituac                                         IN(4, 5)) -- propuestas de alta/suplemento
      AND NOT(s.csituac                                    = 4
      AND creteni                                         IN(3, 4,8,16)) -- propuestas diferentes a las no aceptadas, o anuladas --DV 08/01/2025 AITSSD-23780 Emisión póliza  en estado Inspección rechazada genera bloqueo de placa
      AND(s.fvencim                                       IS NOT NULL
      AND TRUNC(s.fvencim)                                        > pfefecto -- propuestas que se vence a futuro--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1        -- con anulacion programada
      OR pac_anulacion.f_esta_anulada_vto(s.sseguro)       = 1        -- con anulacion al vencimiento
      OR(3                                                 =
        (SELECT cduraci -- con duración al vencimiento
        FROM productos
        WHERE sproduc = s.sproduc
        )
      AND TRUNC(s.fefecto) <= pfefecto)));--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      -- Validación 3 : La placa esta siendo usada en otra(s) propuesta(s) de alta o suplemento pendiente(s) con fecha de anulación futura.
 -- INI DMRL CRILS-1006 08/04/2024
	  p_control_error ('DMRL', vobjectname, 'No 15 '||'vparam :'||vparam||' vcagente '||vcagente||' nerror6 '||nerror6||' vcagentep: '||vcagentep||'err SQL'||SUBSTR(' -Linea: '||dbms_utility.format_call_stack, 1, 2500));
 -- FIN DMRL CRILS-1006 08/04/2024
      SELECT COUNT(1)
      INTO nerror7
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
        -- INICIO (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		union
		select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        )
        -- FIN (25263 + LCOL-126):DCT - 11/07/2016
      AND r.nmovimi =
        (SELECT MAX(nmovimi)
        FROM autriesgos
        WHERE autriesgos.sseguro = s.sseguro
        )
      AND r.ctipmat      = pctipmat -- Tipo Matricula   --   41722 --ECP -- 26/04/2018
      AND r.cmatric      = pcmatric
      AND(r.sseguro NOT IN
        (SELECT sseguro FROM seguros WHERE sseguro = psseguro
        )
      OR psseguro   IS NULL)
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0) FROM productos WHERE sproduc = s.sproduc
        )))
      AND(csituac      IN(4, 5)) -- propuestas de alta/suplemento
      AND NOT(s.csituac = 4
      AND creteni      IN(3, 4,8,16)) -- propuestas diferentes a las no aceptadas, o anuladas --DV 08/01/2025 AITSSD-23780 Emisión póliza  en estado Inspección rechazada genera bloqueo de placa
      AND(s.fanulac    IS NOT NULL
      AND TRUNC(s.fanulac)     > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --Ini 41372/25353 -- ECP -- 14/04/2016
      AND TRUNC(s.fanulac) >--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        (SELECT TRUNC(fcaranu) FROM seguros WHERE sseguro = psseguro--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        )
        --Fin 41372/25353 --ECP -- 14/04/2016
        ); -- propuestas con fechas de anulacion futura
      -- Validación 4 : La placa esta siendo usada en otra(s) poliza(s) vigente(s) .
      SELECT COUNT(1)
      INTO nerror8
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
        -- INICIO (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		union
		select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        )
        -- FIN (25263 + LCOL-126):DCT - 11/07/2016
      AND r.nmovimi =
        (SELECT MAX(nmovimi)
        FROM autriesgos
        WHERE autriesgos.sseguro = s.sseguro
        )
      AND r.ctipmat = pctipmat -- Tipo Matricula   --   43206/26797 --ECP -- 01/08/2016
      AND r.cmatric = pcmatric
        -- Ini 41722 --ECP -- 26/04/2018
        --Ini Bug 0043148 - AGP -17/05/2018 - Se reversa cambio realizado Bug 41722, No permite realizar suplementos
      AND(r.sseguro NOT IN
        (SELECT sseguro FROM seguros WHERE sseguro = psseguro
        -- Ini 47761 -- SPV -- 04/12/2018
        UNION
        SELECT ssegpol FROM estseguros WHERE sseguro = psseguro
        )
        --Fin  41722 --ECP -- 26/04/2018
        --Fin  Bug 0043148 - AGP -17/05/2018
      OR psseguro   IS NULL)
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0) FROM productos WHERE sproduc = s.sproduc
        )))
        --Ini 43206/25265 -- ECP -- 20/06/2016
      AND(TRUNC(s.fcarpro) > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(TRUNC(s.fcaranu) > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        -- Ini 47475 -- ECP -- 06/11/2018
      AND TRUNC(s.fcaranu) <> TRUNC(s.fcarpro)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        -- INI SPV 28/01/2019 0049158: iAxis permite cotizar placas con póliza vigente
        -- Se tienen en cuenta productos de auto individual para las cotizaciones
      AND s.cramo IN (105, 104) --47761 SPV -- 04/12/2018 Solo se toman los productos colectivos de auto
        -- FIN SPV 28/01/2019 0049158: iAxis permite cotizar placas con póliza vigente
        --Fin 47475 -- ECP -- 06/11/2018
        --Fin 43206/25265 -- ECP -- 20/06/2016
      AND(csituac NOT IN(2, 4, 5) -- poliza
        -- Fin 47761 -- SPV -- 04/12/2018
      AND(f_vigente(s.sseguro, NULL, pfefecto)  = 0
      OR(TRUNC(s.fefecto)                              > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND f_vigente(s.sseguro, NULL, TRUNC(s.fefecto)) = 0)))--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(s.fvencim                            IS NULL)  -- polizas no vencidas
      AND(s.fanulac                            IS NULL); -- polizas no anuladas
      --ini 25265 ECP 28-06-2016
      -- Validación 11 : La placa esta siendo usada en otra(s) poliza(s) vigente(s) con fechas de anulacion futura.
 -- INI DMRL CRILS-1006 08/04/2024
	  p_control_error ('DMRL', vobjectname, 'No 16 '||'vparam :'||vparam||' vcagente '||vcagente||' nerror7 '||nerror7||' vcagentep: '||vcagentep||'err SQL'||SUBSTR(' -Linea: '||dbms_utility.format_call_stack, 1, 2500));
 -- FIN DMRL CRILS-1006 08/04/2024
      SELECT COUNT(1)
      INTO nerror11
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
      AND r.nmovimi   =
        (SELECT MAX(nmovimi)
        FROM autriesgos
        WHERE autriesgos.sseguro = s.sseguro
        )
      AND r.ctipmat = pctipmat -- Tipo Matricula   --   41722 --ECP -- 26/04/2018
      AND r.cmatric = pcmatric
        --- IGIL Tarea 36247 / 206491 Tomar sseguro real y no de las tablas est (ssegpol)
        --
        -- Ini 41722 --ECP -- 26/04/2018
        --Ini Bug 0043148 - AGP -17/05/2018 - Se reversa cambio realizado Bug 41722, No permite realizar suplementos
      AND(r.sseguro NOT IN
        (SELECT ssegpol FROM estseguros WHERE sseguro = psseguro
        -- Ini 47761 -- SPV -- 04/12/2018
        UNION
        SELECT sseguro
        FROM seguros
        WHERE sseguro = psseguro
          -- Fin 47761 -- SPV -- 04/12/2018
        )
        -- Fin  41722 --ECP -- 26/04/2018
        --Fin Bug 0043148 - AGP -17/05/2018 - Se reversa cambio realizado Bug 41722, No permite realizar suplementos
      OR psseguro   IS NULL)
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0) FROM productos WHERE sproduc = s.sproduc
        )))
        --Ini 43206/25265 -- ECP -- 20/06/2016
      AND(TRUNC(s.fcarpro) > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(TRUNC(s.fcaranu) > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --Fin 43206/25265 -- ECP -- 20/06/2016
      AND(csituac NOT                          IN(4, 5) -- poliza
      AND(f_vigente(s.sseguro, NULL, pfefecto)  = 0
      OR(TRUNC(s.fefecto)                              > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND f_vigente(s.sseguro, NULL, TRUNC(s.fefecto)) = 0)))--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(s.fvencim                            IS NULL) -- polizas no vencidas
      AND(s.fanulac                            IS NOT NULL
      AND TRUNC(s.fanulac)                             > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --Ini 41372/25353 -- ECP -- 14/04/2016
      AND TRUNC(s.fanulac) >--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        (SELECT TRUNC(fcaranu) FROM seguros WHERE sseguro = psseguro--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        )
        --Fin 41372/25353 --ECP -- 14/04/2016
        )-- polizas con fechas de anulacion futura
        --Fin 41372/25265 --ECP -- 28/06/2016; -- polizas con fechas de anulacion futura
        -- INI 0052909 11/07/2019 SOT exclusion producto 6049 solo rc para placas duplicadas
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		AND  s.sproduc NOT IN (select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1);
		--AND NVL(f_parproductos_v(s.sproduc, 'NO_VALIDA_MATRICULA'), 0) = 0  ;
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        -- FIN 0052909   SOT 11/07/2019
      -- Validación 5 : La placa esta siendo usada en otra(s) poliza(s) vigente(s) que vencerá(n) a futuro.
 -- INI DMRL CRILS-1006 08/04/2024
	  p_control_error ('DMRL', vobjectname, 'No 17 '||'vparam :'||vparam||' vcagente '||vcagente||' nerror11 '||nerror11||' vcagentep: '||vcagentep||'err SQL'||SUBSTR(' -Linea: '||dbms_utility.format_call_stack, 1, 2500));
 -- FIN DMRL CRILS-1006 08/04/2024
      SELECT COUNT(1)
      INTO nerror9
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
        -- INICIO (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		union
		select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        )
        -- FIN (25263 + LCOL-126):DCT - 11/07/2016
      AND r.nmovimi =
        (SELECT MAX(nmovimi)
        FROM autriesgos
        WHERE autriesgos.sseguro = s.sseguro
        )
      AND r.ctipmat      = pctipmat -- Tipo Matricula   --   41722 --ECP -- 26/04/2018
      AND r.cmatric      = pcmatric
      AND(r.sseguro NOT IN
        (SELECT sseguro FROM seguros WHERE sseguro = psseguro
        )
      OR psseguro   IS NULL)
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0)
        FROM productos
        WHERE sproduc = s.sproduc
        )))
      AND(csituac NOT                                     IN(4, 5)
      AND(f_vigente(s.sseguro, NULL, pfefecto)             = 0
      OR(TRUNC(s.fefecto)                                         > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND f_vigente(s.sseguro, NULL, TRUNC(s.fefecto))            = 0)))--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(s.fvencim                                       IS NOT NULL
      AND TRUNC(s.fvencim)                                        > pfefecto -- propuestas que se vence a futuro--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1        -- con anulacion programada
      OR pac_anulacion.f_esta_anulada_vto(s.sseguro)       = 1        -- con anulacion al vencimiento
      OR(3                                                 =
        (SELECT cduraci -- coon duración al vencimiento
        FROM productos
        WHERE sproduc = s.sproduc
        )
      AND TRUNC(s.fefecto) <= pfefecto)));--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      -- Validación 6 : La placa esta siendo usada en otra(s) poliza(s) vigente(s) con fecha de anulación futura.
      SELECT COUNT(1)
      INTO nerror10
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
        -- INICIO (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		union
		select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        )
        -- FIN (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'PLACA_DUPLICADA'
        AND p.cvalpar   = 1
        )
      AND r.nmovimi =
        (SELECT MAX(nmovimi)
        FROM autriesgos
        WHERE autriesgos.sseguro = s.sseguro
        )
      AND r.ctipmat      = pctipmat -- Tipo Matricula   --   41722 --ECP -- 26/04/2018
      AND r.cmatric      = pcmatric
      AND(r.sseguro NOT IN
        (SELECT sseguro FROM seguros WHERE sseguro = psseguro
        )
      OR psseguro   IS NULL)
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0) FROM productos WHERE sproduc = s.sproduc
        )))
      AND(csituac NOT IN
        --BUG 0052436 - 17/06/2019 - JGB - Se añade al filtro la situacion 3(Vencida)
        (4, 5, 2, 3) --BUG 0032287 - 29/03/2017 - CASL - Se añade al filtro la situacion 2(Anulada)
      AND(f_vigente(s.sseguro, NULL, pfefecto)  = 0
      OR(TRUNC(s.fefecto)                              > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND f_vigente(s.sseguro, NULL, TRUNC(s.fefecto)) = 0)))--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(s.fanulac                            IS NOT NULL
      AND(TRUNC(s.fanulac)                             > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --Ini 41372/25353 -- ECP -- 14/04/2016
        -- Ini 30453 -- ECP -- 20/01/2017
      OR TRUNC(s.fanulac) >--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        (SELECT TRUNC(fcaranu) FROM seguros WHERE sseguro = psseguro--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        ))
        -- Fin 30453 -- ECP -- 20/01/2017
        --Fin 41372/25353 --ECP -- 14/04/2016
        ); -- poliza con fechas de anulacion futura
      -- FIN BUG 0018167 - 27/07/2015 - RCM
-- INI BUG 0055282 - 16/10/2019 - GZG
 -- INI DMRL CRILS-1006 08/04/2024
	  p_control_error ('DMRL', vobjectname, 'No 18 '||'vparam :'||vparam||' vcagente '||vcagente||' nerror10 '||nerror10||' vcagentep: '||vcagentep||'err SQL'||SUBSTR(' -Linea: '||dbms_utility.format_call_stack, 1, 2500));
 -- FIN DMRL CRILS-1006 08/04/2024
SELECT COUNT(1)
INTO nerror8
FROM autriesgos r,
  seguros s
WHERE r.sseguro    = s.sseguro
AND s.sproduc NOT IN
  (SELECT p.sproduc
  FROM parproductos p
  WHERE p.cparpro = 'POLIZA_UNICA'
  AND p.cvalpar   = 0
  --INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
  union
  select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1
  --FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
  )
AND r.nmovimi =
  (SELECT MAX(nmovimi)
  FROM autriesgos
  WHERE autriesgos.sseguro = s.sseguro
  )
AND r.ctipmat      = pctipmat
AND r.cmatric      = pcmatric
AND(r.sseguro NOT IN
  (SELECT sseguro FROM seguros WHERE sseguro = psseguro
  UNION
  SELECT ssegpol FROM estseguros WHERE sseguro = psseguro
  )
OR psseguro   IS NULL)
AND(s.sproduc IN
  (SELECT cp.cproduc
  FROM cum_cumprod cp,
    cum_cumulo cc
  WHERE cc.scumulo = cp.ccumulo
  AND cc.cnivel    = 0
  AND cc.scumulo  IN
            (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
    )
  )
OR(0 IN
  (SELECT NVL(creaseg, 0) FROM productos WHERE sproduc = s.sproduc
  )))
AND s.cramo   IN (105, 104)
AND csituac    = 0
AND(s.fvencim IS NULL)
AND(s.fanulac IS NULL);
      -- FIN BUG 0055282 - 16/10/2019 - GZG
       --INI  17/11/2021  JMC  QT72215
       SELECT COUNT(1)
         INTO nerror12
         FROM movseguro m
        WHERE sseguro= psseguro
          AND nmovimi = (SELECT MAX (nmovimi)
                           FROM movseguro
                          WHERE sseguro = m.sseguro
                            AND cmotven <> 52)
          AND cmovseg = 3;
       IF nerror12 > 0 THEN
          --El ultimo movimiento es una baja, entendemos que se trata de una rehabilitacion
          SELECT COUNT(1)
            INTO nerror12
            FROM autriesgos r, seguros s
           WHERE r.sseguro = s.sseguro
             AND s.sproduc NOT IN (SELECT p.sproduc
                                     FROM parproductos p
                                    WHERE p.cparpro = 'POLIZA_UNICA'
                                    --INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
					AND p.cvalpar   = 0 --)
					union
					select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1)
				    --FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
             AND r.nmovimi = (SELECT MAX(nmovimi)
                                FROM autriesgos
                               WHERE autriesgos.sseguro = s.sseguro)
             AND r.ctipmat      = pctipmat
             AND r.cmatric      = pcmatric
             AND (r.sseguro NOT IN (SELECT sseguro
                                      FROM seguros
                                     WHERE sseguro = psseguro
                                    UNION
                                    SELECT ssegpol
                                      FROM estseguros
                                     WHERE sseguro = psseguro)
                   OR psseguro   IS NULL)
             AND s.cramo   IN (105, 104)
             AND csituac    = 0
             AND TRUNC(s.fefecto) >= pfefecto;
 -- INI DMRL CRILS-1006 08/04/2024
	  p_control_error ('DMRL', vobjectname, 'No 19 '||'vparam :'||vparam||' vcagente '||vcagente||' nerror8 '||nerror8||' vcagentep: '||vcagentep||'err SQL'||SUBSTR(' -Linea: '||dbms_utility.format_call_stack, 1, 2500));
 -- FIN DMRL CRILS-1006 08/04/2024
       END IF;
       --FIN  17/11/2021  JMC  QT72215
    END IF;
    IF pnbastid IS NOT NULL THEN
      SELECT COUNT(1)
      INTO nerror2
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
        -- INICIO (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		union
		select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        )
        -- FIN (25263 + LCOL-126):DCT - 11/07/2016
      AND r.nbastid      = pnbastid
      AND(r.sseguro NOT IN
        (SELECT ssegpol FROM estseguros WHERE sseguro = psseguro
        -- Ini 47761 -- SPV -- 11/12/2018
        UNION
        SELECT sseguro FROM seguros WHERE sseguro = psseguro
        )
      OR psseguro IS NULL)
        --Fin 47761 -- SPV -- 11/12/2018
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0) FROM productos WHERE sproduc = s.sproduc
        )))
        -- AND r.fanulac IS NULL --que el riesgo no este anulado
        -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
        -- AND s.csituac <> 2 -- que no estén anuladas
        -- AND s.csituac NOT IN(2, 3)   -- que no estén anuladas ni vencidas
        --Ini 43206/25265 -- ECP -- 20/06/2016
      AND(TRUNC(s.fcarpro) > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(TRUNC(s.fcaranu) > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        -- Ini 47475 -- ECP -- 06/11/2018
      AND TRUNC(s.fcaranu) <> TRUNC(s.fcarpro)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        -- INI SPV 28/01/2019 0049158: iAxis permite cotizar placas con póliza vigente
        -- Se tienen en cuenta productos de auto individual para las cotizaciones
      AND s.cramo IN (105, 104) --47761 SPV -- 11/12/2018 Solo se toman los productos colectivos de auto
        -- FIN SPV 28/01/2019 0049158: iAxis permite cotizar placas con póliza vigente
        --Fin 47475 -- ECP -- 06/11/2018
        --Fin 43206/25265 -- ECP -- 20/06/2016
      AND(f_vigente(s.sseguro, NULL, pfefecto) = 0
      OR csituac                              IN(4, 5)
        -- Bug 31686/178722 - 04/07/2014 - AMC
      OR(TRUNC(s.fefecto)                              > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND f_vigente(s.sseguro, NULL, TRUNC(s.fefecto)) = 0))--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        -- FI BUG 11330 - 15/10/2009 ¿ FAL
      AND NOT(s.csituac = 4
      AND creteni      IN(3, 4,8,16)) --DV 08/01/2025 AITSSD-23780 Emisión póliza  en estado Inspección rechazada genera bloqueo de placa
        -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pÃ³lizas con vencimiento programado a fecha anterior al efecto de la nueva pÃ³liza
      AND((s.fvencim                                      IS NULL)
      OR(s.fvencim                                        IS NOT NULL
      AND TRUNC(s.fvencim)                                        > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1
      OR pac_anulacion.f_esta_anulada_vto(s.sseguro)       = 1)))
      AND((s.fanulac                                      IS NULL)
      OR (TRUNC(s.fanulac)                                        > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --Ini 41372/25353 -- ECP -- 14/04/2016
      AND TRUNC(s.fanulac) >--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        (SELECT TRUNC(fcaranu) FROM seguros WHERE sseguro = psseguro--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        )
        --Fin 41372/25353 --ECP -- 14/04/2016
        )
        --BUG 28455/156716 - RCL - 28/10/2013 - QT-0009745: Error al validar matriculas
      AND r.nmovimi =
        (SELECT MAX(nmovimi) FROM autriesgos WHERE autriesgos.sseguro = s.sseguro
        )
        --Ini 47761 -- SPV -- 11/12/2018
      AND s.csituac <> 2; -- Excluir polizas o certificados anulados
      --Fin 47761 -- SPV -- 11/12/2018;
 -- INI DMRL CRILS-1006 08/04/2024
	  p_control_error ('DMRL', vobjectname, 'No 20 '||'vparam :'||vparam||' vcagente '||vcagente||' nerror2 '||nerror2||' vcagentep: '||vcagentep||'err SQL'||SUBSTR(' -Linea: '||dbms_utility.format_call_stack, 1, 2500));
 -- FIN DMRL CRILS-1006 08/04/2024
    END IF;
    -- Ini 43105 -- ECP -- 09/05/2018
    IF pcodmotor IS NOT NULL THEN
      SELECT COUNT(1)
      INTO nerror3
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
        -- INICIO (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		union
		select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        )
        -- FIN (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'PLACA_DUPLICADA'
        AND p.cvalpar   = 1
        )
      AND r.codmotor     = pcodmotor
      AND(r.sseguro NOT IN
        (SELECT sseguro FROM seguros WHERE sseguro = psseguro
        -- Ini 47761 -- SPV -- 04/12/2018
        UNION
        SELECT ssegpol FROM estseguros WHERE sseguro = psseguro
        )
      OR psseguro   IS NULL)
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0) FROM productos WHERE sproduc = s.sproduc
        )))
        -- AND r.fanulac IS NULL --que el riesgo no este anulado
        -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
        -- AND s.csituac <> 2 -- que no estén anuladas
        --AND s.csituac NOT IN(2, 3)   -- que no estén anuladas ni vencidas
        --Ini 43206/25265 -- ECP -- 20/06/2016
      AND(TRUNC(s.fcarpro) > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(TRUNC(s.fcaranu) > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        -- Ini 47475 -- ECP -- 06/11/2018
      AND TRUNC(s.fcaranu) <> TRUNC(s.fcarpro)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        -- INI SPV 28/01/2019 0049158: iAxis permite cotizar placas con póliza vigente
        -- Se tienen en cuenta productos de auto individual para las cotizaciones
      AND s.cramo IN (105, 104) --47761 SPV -- 04/12/2018 Solo se toman los productos colectivos de auto
        -- FIN SPV 28/01/2019 0049158: iAxis permite cotizar placas con póliza vigente
        --Fin 47475 -- ECP -- 06/11/2018
        --Fin 43206/25265 -- ECP -- 20/06/2016
      AND(f_vigente(s.sseguro, NULL, pfefecto) = 0
      OR csituac                              IN(4, 5)
        -- Bug 31686/178722 - 04/07/2014 - AMC
      OR(TRUNC(s.fefecto)                              > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND f_vigente(s.sseguro, NULL, TRUNC(s.fefecto)) = 0))--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        -- FI BUG 11330 - 15/10/2009 ¿ FAL
      AND NOT(s.csituac = 4
      AND creteni      IN(3, 4,8,16)) --DV 08/01/2025 AITSSD-23780 Emisión póliza  en estado Inspección rechazada genera bloqueo de placa
      AND NOT(s.csituac = 2)
        -- Fin 47761 -- SPV -- 04/12/2018
        -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
      AND((s.fvencim                                      IS NULL)
      OR(s.fvencim                                        IS NOT NULL
      AND TRUNC(s.fvencim)                                        > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1
      OR pac_anulacion.f_esta_anulada_vto(TRUNC(s.sseguro))       = 1)))--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND((s.fanulac                                      IS NULL)
      OR (TRUNC(s.fanulac)                                        > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --Ini 41372/25353 -- ECP -- 14/04/2016
      AND TRUNC(s.fanulac) >--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        (SELECT TRUNC(fcaranu) FROM seguros WHERE sseguro = psseguro--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        )
        --Fin 41372/25353 --ECP -- 14/04/2016
        --Ini 43206/25265 -- ECP -- 20/06/2016
      AND TRUNC(s.fanulac) >--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        (SELECT TRUNC(fcaranu) FROM estseguros WHERE sseguro = psseguro--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        )
      AND TRUNC(s.fcaranu) >--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        (SELECT TRUNC(fcaranu) FROM estseguros WHERE sseguro = psseguro--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        )
        --Fin 43206/25265 -- ECP -- 20/06/2016
        )
        --BUG 28455/156716 - RCL - 28/10/2013 - QT-0009745: Error al validar matriculas
      AND r.nmovimi =
        (SELECT MAX(nmovimi) FROM autriesgos WHERE autriesgos.sseguro = s.sseguro
        );
    END IF;
    -- Fin 43105 -- ECP -- 09/05/2018
    --BUG 26435 - INICIO - DCT - 15/03/2013
    IF pcchasis IS NOT NULL THEN
      SELECT COUNT(1)
      INTO nerror4
      FROM autriesgos r,
        seguros s
      WHERE r.sseguro = s.sseguro
        -- INICIO (25263 + LCOL-126):DCT - 11/07/2016
      AND s.sproduc NOT IN
        (SELECT p.sproduc
        FROM parproductos p
        WHERE p.cparpro = 'POLIZA_UNICA'
        AND p.cvalpar   = 0
		--INI DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
		union
		select p.sproduc from parproductos p where cparpro ='SINCONTROLDUPLI' AND p.cvalpar   = 1
		--FIN DV 28/03/2023 QT AITSSD-6813 Error La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
        )
        -- FIN (25263 + LCOL-126):DCT - 11/07/2016
      AND r.cchasis      = pcchasis
      AND(r.sseguro NOT IN
        (SELECT sseguro FROM seguros WHERE sseguro = psseguro
        )
      OR psseguro   IS NULL)
      AND(s.sproduc IN
        (SELECT cp.cproduc
        FROM cum_cumprod cp,
          cum_cumulo cc
        WHERE cc.scumulo = cp.ccumulo
        AND cc.cnivel    = 0
        AND cc.scumulo  IN
          (SELECT ccumulo FROM cum_cumprod WHERE cproduc = psproduc --cambio scumulo x ccumulo DV 25/11/2021 QT	0072107
          )
        )
      OR(0 IN
        (SELECT NVL(creaseg, 0) FROM productos WHERE sproduc = s.sproduc
        )))
        -- AND r.fanulac IS NULL --que el riesgo no este anulado
        -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
        -- AND s.csituac <> 2 -- que no estén anuladas
        -- AND s.csituac NOT IN(2, 3)   -- que no estén anuladas ni vencidas
        --Ini 43206/25265 -- ECP -- 20/06/2016
      AND(TRUNC(s.fcarpro) > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(TRUNC(s.fcaranu) > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --Fin 43206/25265 -- ECP -- 20/06/2016
      AND(f_vigente(s.sseguro, NULL, pfefecto) = 0
      OR csituac                              IN(4, 5)
        -- Bug 31686/178722 - 04/07/2014 - AMC
      OR(TRUNC(s.fefecto)                              > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND f_vigente(s.sseguro, NULL, TRUNC(s.fefecto)) = 0))--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        -- FI BUG 11330 - 15/10/2009 ¿ FAL
      AND NOT(s.csituac = 4
      AND creteni      IN(3, 4,8,16)) --DV 08/01/2025 AITSSD-23780 Emisión póliza  en estado Inspección rechazada genera bloqueo de placa
        -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
      AND((s.fvencim                                      IS NULL)
      OR(s.fvencim                                        IS NOT NULL
      AND TRUNC(s.fvencim)                                        > pfefecto--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1
      OR pac_anulacion.f_esta_anulada_vto(s.sseguro)       = 1)))
      AND((s.fanulac                                      IS NULL)
      OR (TRUNC(s.fanulac)                                        > pfefecto)--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        --Ini 41372/25353 -- ECP -- 14/04/2016
      AND TRUNC(s.fanulac) >--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        (SELECT TRUNC(fcaranu) FROM seguros WHERE sseguro = psseguro--BUG 0063717 - 23/09/2020 - CASL - Se trunca la fecha
        )
        --Fin 41372/25353 --ECP -- 14/04/2016
        )
        --BUG 28455/156716 - RCL - 28/10/2013 - QT-0009745: Error al validar matriculas
      AND r.nmovimi =
        (SELECT MAX(nmovimi) FROM autriesgos WHERE autriesgos.sseguro = s.sseguro
        );
    END IF;
  END IF;
  --Si encontramos alguna póliza significa que estas duplicando la matrícula, vin o código del motor
  -- INI BUG 0018167 - 27/07/2015 - RCM - Se manejan los nuevos mensajes de error
  -- Ini 43105 -- ECP -- 09/05/2018
  IF nerror5    > 0 THEN
    nerror     := 9908031; --La placa esta siendo usada en alguna propuesta de alta o suplemento pendiente
  ELSIF nerror6 > 0 THEN
    nerror     := 9908032; --La placa esta siendo usada en alguna propuesta de alta o suplemento pendiente que tiene fecha de vencimiento futura
  ELSIF nerror7 > 0 THEN
    nerror     := 9908033; --La placa esta siendo usada en alguna propuesta de alta o suplemento pendiente que tiene fecha de anulación futura
  ELSIF nerror8 > 0 THEN
    nerror     := 9908034; --La placa esta siendo usada en alguna poliza vigente
    -- INI 43206/25265 -- ECP -- 28/06/2016
  ELSIF nerror11 > 0 THEN
    nerror      := 9908034; --La placa esta siendo usada en alguna poliza vigente
    --FIN 43206/25265 -- ECP --28/06/2016
  --INI  17/11/2021  JMC  QT72215
  ELSIF nerror12 > 0 THEN
     nerror      := 9908034; --La placa esta siendo usada en alguna poliza vigente
  --FIN  17/11/2021  JMC  QT72215
  ELSIF nerror9  > 0 THEN
    nerror      := 9908035; --La placa esta siendo usada en alguna poliza vigente que tiene fecha de vencimiento futura
  ELSIF nerror10 > 0 THEN
    nerror      := 9908036; --La placa esta siendo usada en alguna poliza vigente que tiene fecha de anulación futura
    -- FIN BUG 0018167 - 27/07/2015 - RCM
  ELSIF nerror2 > 0 THEN
    nerror     := 9904841; --Bastidor ya existente
  ELSIF nerror3 > 0 THEN
    nerror     := 9904842; --Código del motor ya existente
  ELSIF nerror4 > 0 THEN
    nerror     := 9905114; --Código del chasis ya existente
  END IF;
  --Fin 45385 -- ECP -- 08/08/2018
 -- INI DMRL CRILS-1006 08/04/2024
	  p_control_error ('DMRL', vobjectname, 'No 23 '||'vparam :'||vparam||' vcagente '||vcagente||' nerror '||nerror||' vcagentep: '||vcagentep||'err SQL'||SUBSTR(' -Linea: '||dbms_utility.format_call_stack, 1, 2500));
 -- FIN DMRL CRILS-1006 08/04/2024
  RETURN nerror;
EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
  RETURN nerror; --Error validar el auto
END f_controlduplicidad;
-- BUG 0025202 -  ECP  - 15/02/2013
/*************************************************************************
FUNCTION f_despeso
Funcion que busca la descripcion del peso de un vehiculo
param in pcpeso : Codigo del peso
return            : descripcion del peso
*************************************************************************/
FUNCTION f_despeso(
    psproduc IN NUMBER,
    pcpeso   IN NUMBER,
    pcidioma IN NUMBER)
  RETURN VARCHAR2
IS
  v_tpeso aut_prod_pesos.tpeso%TYPE;
BEGIN
  BEGIN
    SELECT tpeso
    INTO v_tpeso
    FROM aut_prod_pesos
    WHERE sproduc = psproduc
    AND cpeso     = pcpeso
    AND cidioma   = pcidioma;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    SELECT tpeso
    INTO v_tpeso
    FROM aut_prod_pesos
    WHERE sproduc = 0
    AND cpeso     = pcpeso
    AND cidioma   = pcidioma;
  END;
  RETURN v_tpeso;
EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, 'pac_autos.f_despeso', 1, 'pcpeso = ' || pcpeso, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
  RETURN NULL;
END f_despeso;
/*************************************************************************
FUNCTION f_get_valorauto
Funcion que busca el valor de una version
param in psseguro : Codigo del seguro
param in pnriesgo : Numero de riesgo
param in psproces : Codigo del proceso
param in pcversion : Código de la versión
param out pvalorcomercial : valor comercial
param out pvalorcomercial_nuevo : nuevo valor comercial
return  0 - Ok 1 Ko
Bug 26638/160933 - 11/12/2013 - AMC
*************************************************************************/
FUNCTION f_get_valorauto(
    psseguro  IN NUMBER,
    pnriesgo  IN NUMBER,
    psproces  IN NUMBER,
    pcversion IN VARCHAR2,
    pdonde    IN NUMBER,
    pvalorcomercial OUT NUMBER,
    pvalorcomercial_nuevo OUT NUMBER)
  RETURN NUMBER
IS
BEGIN
  IF pdonde = 1 THEN
    SELECT
      (SELECT vcomercial
      FROM aut_versiones_anyo aut
      WHERE aut.cversion = av.cversionhomologo
      AND aut.anyo       = ar.anyo
      ),
      (SELECT vcomercial
      FROM aut_versiones_anyo aut
      WHERE aut.cversion = av.cversionhomologo
      AND aut.anyo       =
        (SELECT MAX(anyo)
        FROM aut_versiones_anyo d
        WHERE d.cversion = av.cversionhomologo
        )
      )
    INTO pvalorcomercial,
      pvalorcomercial_nuevo
    FROM aut_versiones_anyo d,
      aut_versiones av,
      autriesgoscar ar
    WHERE d.cversion = pcversion
    AND av.cversion  = d.cversion
    AND ar.anyo      = d.anyo
    AND ar.sseguro   = psseguro
    AND ar.nriesgo   = pnriesgo
    AND av.cversion  = ar.cversion
    AND ar.sproces   = psproces;
  ELSE
    SELECT vcomercial,
      (SELECT vcomercial
      FROM aut_versiones_anyo d
      WHERE d.cversion = pcversion
      AND anyo         =
        (SELECT MAX(anyo) FROM aut_versiones_anyo d WHERE d.cversion = pcversion
        )
      )
    INTO pvalorcomercial,
      pvalorcomercial_nuevo
    FROM aut_versiones_anyo d,
      aut_versiones av,
      estautriesgos ar,
      estseguros es
    WHERE d.cversion = pcversion
    AND av.cversion  = d.cversion
    AND ar.anyo      = d.anyo
    AND ar.sseguro   = psseguro
    AND ar.sseguro   = es.sseguro
    AND ar.nriesgo   = pnriesgo;
  END IF;
  RETURN 0;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  pvalorcomercial       := NULL;
  pvalorcomercial_nuevo := NULL;
  RETURN 0;
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, 'pac_autos.f_get_valorauto', 1, 'psseguro = ' || psseguro || ' pnriesgo:' || pnriesgo || ' psproces:' || psproces || ' pcversion:' || pcversion, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
  RETURN 1;
END;
--INICIO --BUG 0026011- AGP -12/07/2016: Se adiciona Funcion f_get_cmatric
/*************************************************************************
Funcion que retorna la placa informando el seguro.
param  in     psseguro : Id. seguro
param  in     ptablas  : 'EST', 'POL'
return        trespue  : Descripcion del texto de una respuesta
*************************************************************************/
FUNCTION f_get_cmatric(
    psseguro IN seguros.sseguro%TYPE,
    ptablas  IN VARCHAR2)
  RETURN VARCHAR2
IS
  vpasexec NUMBER := 1;
  vcmatric autriesgos.cmatric%TYPE;
  vparam        VARCHAR2(200) := 'psseguro: ' || psseguro || ' ptablas: ' || ptablas;
  vobject       VARCHAR2(200) := 'f_get_cmatric';
  e_param_error EXCEPTION;
BEGIN
  IF psseguro IS NULL OR ptablas IS NULL THEN
    RAISE e_param_error;
  END IF;
  IF ptablas = 'EST' THEN
    SELECT a.cmatric
    INTO vcmatric
    FROM estautriesgos a
    WHERE a.sseguro = psseguro
    AND a.nmovimi   =
      (SELECT MAX(nmovimi) FROM estautriesgos a2 WHERE a2.sseguro = a.sseguro
      );
  ELSE
    SELECT a.cmatric
    INTO vcmatric
    FROM autriesgos a
    WHERE a.sseguro = psseguro
    AND a.nmovimi   =
      (SELECT MAX(nmovimi) FROM autriesgos a2 WHERE a2.sseguro = a.sseguro
      );
  END IF;
  RETURN vcmatric;
EXCEPTION
WHEN e_param_error THEN
  p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'Parametros incorrectos');
  RETURN NULL;
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || ' - ' || SQLERRM);
  RETURN NULL;
END f_get_cmatric;
--FIN --BUG 0026011- AGP -12/07/2016: Se adiciona Funcion f_get_cmatric
-- INICIO - 31/01/2020 - Inforcol - 0058290: colectivo aws - riesgos no acordes al plan
/*************************************************************************
Funcion valida que la clase de riesgo este permitida al emitir un certificado
para productos de autos colectivo
param  in     psseguro : Id. seguro
param  in     pctipveh : clase de riesgo
param  OUT     mensajes : mensajes de iAXIS
return        NUMBER   : 0 valida ok -  otro valor: vr. de mensaje literal
*************************************************************************/
FUNCTION f_val_ctipveh_aut_col(
    pctipveh IN NUMBER,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vpasexec NUMBER := 1;
  vcmatric autriesgos.cmatric%TYPE;
  vparam        VARCHAR2(200);
  vobject       VARCHAR2(200) := 'PAC_AUTOS.f_val_ctipveh_aut_col';
  v_npoliza   NUMBER;
  v_sseguro   NUMBER;
  v_cnt_resp  NUMBER;
  vobdetpoliza   ob_iax_detpoliza;
  -- INICIO - 31/03/2020 - Inforcol - 0059482: AWS - TOTAL CAR - 317483 ,298342 ,303014 y 318809 - No esta dejando cotizar aun cuando las clases se encuentran en plan
  n_registro  NUMBER;
  v_cpregun_4089 estpregunpolseg.cpregun%TYPE := 4089;
  v_crespue_4089 estpregunpolseg.crespue%TYPE;
  v_trespue_4089 estpregunpolseg.trespue%TYPE;
  v_existepreg NUMBER;
  vnumerr      NUMBER;
  -- FIN - 31/03/2020 - Inforcol - 0059482: AWS - TOTAL CAR - 317483 ,298342 ,303014 y 318809 - No esta dejando cotizar aun cuando las clases se encuentran en plan
BEGIN
  -- Se obtiene el valor del sseguro al emitir con el tipo objeto ob_iax_detpoliza
  vpasexec := 1;
  vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);
  vparam := 'vobdetpoliza.sseguro: ' || vobdetpoliza.sseguro || ' pctipveh: ' || pctipveh;
  vpasexec := 2;
  -- INICIO - 31/03/2020 - Inforcol - 0059482: AWS - TOTAL CAR - 317483 ,298342 ,303014 y 318809 - No esta dejando cotizar aun cuando las clases se encuentran en plan
  -- Se obtiene el valor de la pregunta 4089 (plan del colectivo) en tiempo de ejecucion
  vnumerr := pac_call.f_get_preguntas(n_registro, v_cpregun_4089, v_crespue_4089, v_trespue_4089, v_existepreg);
  IF vnumerr <> 0 OR v_crespue_4089 IS NULL THEN
    RETURN 9000758;
  END IF;
  -- Se obtiene el valor de npoliza del tipo objeto vobdetpoliza para obtener el sseguro del certificado 0
  v_npoliza:=  vobdetpoliza.npoliza;
  -- Se comenta este código para validar solo por el que trae el tipo objeto
  /*BEGIN
    SELECT npoliza
      INTO v_npoliza
      FROM estseguros
     WHERE sseguro = vobdetpoliza.sseguro;
  EXCEPTION
    WHEN OTHERS THEN
      v_npoliza := 0;
  END;*/
  -- FIN - 31/03/2020 - Inforcol - 0059482: AWS - TOTAL CAR - 317483 ,298342 ,303014 y 318809 - No esta dejando cotizar aun cuando las clases se encuentran en plan
  vpasexec := 3;
  -- Se obtiene el valor de npoliza
  BEGIN
    SELECT sseguro
      INTO v_sseguro
      FROM seguros
     WHERE npoliza = v_npoliza
       AND ncertif = 0;
  EXCEPTION
    WHEN OTHERS THEN
      v_sseguro := 0;
  END;
  vpasexec := 4;
  -- Se busca la clase de riesgo dentro de las predefinidas en la caratula
  -- en la pregunta 9119
  BEGIN
    SELECT COUNT(*)
      INTO v_cnt_resp
      FROM pregunsegtab
     WHERE sseguro = v_sseguro
       AND cpregun = 9119
       -- INICIO - 31/03/2020 - Inforcol - 0059482: AWS - TOTAL CAR - 317483 ,298342 ,303014 y 318809 - No esta dejando cotizar aun cuando las clases se encuentran en plan
       AND (nvalor  = pctipveh OR  nvalor = 999999999)
       AND nriesgo = v_crespue_4089
       -- FIN - 31/03/2020 - Inforcol - 0059482: AWS - TOTAL CAR - 317483 ,298342 ,303014 y 318809 - No esta dejando cotizar aun cuando las clases se encuentran en plan
       AND nmovimi = (SELECT MAX(nmovimi) FROM pregunsegtab WHERE sseguro = v_sseguro);
  EXCEPTION
    WHEN OTHERS THEN
      v_cnt_resp := 0;
  END;
  vpasexec := 5;
  -- Se valida y si no se encuentra la clase de riesgo
  -- retorna el mensaje "Clase de riesgo no permitida"
  IF NVL(v_cnt_resp,0) = 0 THEN
    RETURN 9906136;
  END IF;
  RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || ' - ' || SQLERRM);
    RETURN NULL;
END f_val_ctipveh_aut_col;
-- FIN - 31/01/2020 - Inforcol - 0058290: colectivo aws - riesgos no acordes al plan
--INI  09/06/2020  JMC  QT61433
FUNCTION f_excepcion_agente (
    pssegcot IN NUMBER,
    pagepol  IN NUMBER,
    ptablas  IN VARCHAR2)
  RETURN NUMBER
IS
   v_cagecot   NUMBER;
   v_cagepol   NUMBER;
   v_cont      NUMBER;
BEGIN

   IF pac_iax_produccion.issimul THEN --AND pac_iax_produccion.poliza.det_poliza.csituac = 7 THEN
      --Obtenemos el agente de la cotización
      BEGIN
         SELECT cagente
           INTO v_cagecot
           FROM estseguros
          WHERE sseguro =  pssegcot;
      EXCEPTION
         WHEN OTHERS THEN
            v_cagecot := pac_iax_produccion.poliza.det_poliza.cagente;
      END;
   END IF;

   IF v_cagecot IS NOT NULL AND pagepol IS NOT NULL THEN
      BEGIN
         SELECT COUNT(*)
           INTO v_cont
           FROM age_excep_cot
          WHERE cageexc = v_cagecot
            AND cageseg = pagepol;
         IF v_cont > 0 THEN
            RETURN 1;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
   END IF;

   RETURN 0;
END f_excepcion_agente;
--FIN  09/06/2020  JMC  QT61433
--INI  18/03/2021  IGIL  QT65595
PROCEDURE p_notificacion_rc (psseguro IN NUMBER, pnriesgo IN NUMBER, pnmovimi IN NUMBER, pfsinies IN DATE, pccausin IN NUMBER, pcmotsin IN VARCHAR, pnproducto IN NUMBER,
pnsinies IN VARCHAR2, pntramit IN NUMBER, pctipres IN NUMBER, pnmovres IN NUMBER, pcgarant IN NUMBER,  vireserva IN NUMBER  )
   IS
   v_asunto        VARCHAR2(8000);
   v_cuerpo        VARCHAR2(8000);
   v_sender        VARCHAR2(200);
   v_receptor      VARCHAR2(200);
   vmensajes       t_iax_mensajes;
   v_placa         VARCHAR2(2000) := '';
   v_fsinies       VARCHAR2(2000) := '';
   v_tdescrip      VARCHAR2(2000) := '';
   v_npoliza       VARCHAR2(2000) := '';
   v_ncertif       VARCHAR2(2000) := '';
   v_tnombre       VARCHAR2(2000) := '';
   v_tdireccion    VARCHAR2(2000) := '';
   v_ttelefono     VARCHAR2(2000) := '';
   v_temail        VARCHAR2(2000) := '';
   v_garantia      VARCHAR2(2000) := '';
   v_cramo      NUMBER(8,0);
BEGIN

   BEGIN
        SELECT cramo
        INTO v_cramo
        FROM productos
        WHERE sproduc = pnproducto
        AND rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_cramo := 0;
    END;
IF pcgarant IN(756, 757, 9036, 9037, 786, 5446, 5447)
AND ( pnproducto = 900753 OR v_cramo IN (104, 105) )  THEN
   SELECT dbms_lob.substr(impreso) INTO v_asunto FROM informes_xml WHERE id = 655950;
   SELECT dbms_lob.substr(impreso) INTO v_cuerpo FROM informes_xml WHERE id = 655951;

   BEGIN
        SELECT TO_CHAR(sin.fsinies, 'dd/MM/yyyy'), sin.tsinies, s.npoliza, s.ncertif, (select pcgarant || ' ' || gs.tgarant from garangen gs where gs.cidioma = 8 and gs.cgarant = pcgarant) vgaran
        INTO v_fsinies, v_tdescrip, v_npoliza, v_ncertif, v_garantia
        FROM sin_siniestro sin, seguros s
        WHERE sin.nsinies = pnsinies
        AND sin.sseguro = s.sseguro
        AND rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    BEGIN
        SELECT SUBSTR(cmatric, 1,3) ||' ' || SUBSTR(cmatric, 4,6)
        INTO v_placa
        FROM autriesgos
        WHERE nriesgo = pnriesgo
        AND sseguro = psseguro
        AND nmovimi = ( select max(a.nmovimi) from autriesgos a where a.sseguro = psseguro and a.nriesgo = pnriesgo)
        AND rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    BEGIN
        SELECT pac_isqlfor_lcol.f_dades_persona(a.sperson,4,8 ,'POL') || ' ' || pac_isqlfor_lcol.f_dades_persona(a.sperson,5,8 ,'POL') nombre,
        pac_isqlfor_lcol.f_direccion(a.sperson,nvl(a.cdomici,1),'POL') direccion,
        pac_isqlfor.f_telefono(a.sperson) telefono,
        (select c.tvalcon from per_contactos c where c.ctipcon= 3 and c.sperson = a.sperson and rownum =1 ) email
        INTO v_tnombre, v_tdireccion, v_ttelefono, v_temail
        FROM asegurados a
        WHERE a.sseguro = psseguro
        AND rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    BEGIN
            SELECT tvalpar
              INTO v_receptor
              FROM parinstalacion
             WHERE cparame = 'RC_NOTIF_EMAIL';
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_receptor := '';
    END;
   v_asunto := utl_lms.format_message(v_asunto, pnsinies , v_placa);
   v_cuerpo := utl_lms.format_message(v_cuerpo, pnsinies ,v_garantia, v_npoliza, v_ncertif, v_tnombre, v_temail,v_ttelefono, v_tdireccion, v_tdescrip, v_fsinies);
   v_sender := PAC_IAX_PARAM.F_PARINSTALACION_TT('MAIL_USER', vmensajes);
   PAC_SEND_MAIL.MAIL(v_sender, v_receptor, v_asunto, v_cuerpo, null, null);
END IF;
END p_notificacion_rc;
--FIN  18/03/2021  IGIL  QT65595
END pac_autos;