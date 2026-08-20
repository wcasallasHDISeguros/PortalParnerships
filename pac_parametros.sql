CREATE OR REPLACE PACKAGE AXIS.pac_parametros AUTHID CURRENT_USER IS
/****************************************************************************
   NOMBRE:       PAC_PARAMETROS
   PROPÓSITO:  Funciones para parametros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0                                     1. Creación del package
   5.0        22/10/2009   AMC             5. Bug 8999: Se añade la función F_DESCDETPARAM
   6.0        29/10/2010   JMP             6. Bug 8999: Ajustes y revisiones
   8.0        10/10/2013   SPC             8. 0028024 : Optimización proceso tarificación y cartera
   9.0        03/12/2018   CASL            9. 0039680: APCN, debe crearse por garantia la pregunta de valor asegurado.
  10.0        26/03/2019   CASL           10. 0050601: Impresiones Masivas: Optimización Proceso de Impresiones Masivas Generación de Zips
1 ***************************************************************************/
   CURSOR c_codparam IS
      SELECT cparam, ctipo, tdefecto
        FROM codparam;

   TYPE r_codparam IS TABLE OF c_codparam%ROWTYPE
      INDEX BY BINARY_INTEGER;

   v_codparam     r_codparam;

   CURSOR c_parproductos IS
      SELECT cvalpar, sproduc, cparpro, tvalpar
        FROM parproductos;

   TYPE r_parproductos IS TABLE OF c_parproductos%ROWTYPE
      INDEX BY BINARY_INTEGER;

   v_parproductos r_parproductos;

   CURSOR c_parinstalacion IS
      SELECT tvalpar, nvalpar, cparame
        FROM parinstalacion;

   TYPE r_parinstalacion IS TABLE OF c_parinstalacion%ROWTYPE
      INDEX BY BINARY_INTEGER;

   v_parinstalacion r_parinstalacion;

   CURSOR c_parempresas IS
      SELECT nvalpar, cempres, cparam
        FROM parempresas;

   TYPE r_parempresas IS TABLE OF c_parempresas%ROWTYPE
      INDEX BY BINARY_INTEGER;

   v_parempresas  r_parempresas;

   TYPE tind IS TABLE OF NUMBER
      INDEX BY VARCHAR2(512);

   vindt1         tind;
   vindt2         tind;
   vindt3         tind;
   vindt4         tind;

   FUNCTION f_parproducto_n(psproduc IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_parproducto_t(psproduc IN NUMBER, pcparam IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_parproducto_f(psproduc IN NUMBER, pcparam IN VARCHAR2)
      RETURN DATE;

   FUNCTION f_paractividad_n(psproduc IN NUMBER, pcactivi IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_paractividad_t(psproduc IN NUMBER, pcactivi IN NUMBER, pcparam IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_paractividad_f(psproduc IN NUMBER, pcactivi IN NUMBER, pcparam IN VARCHAR2)
      RETURN DATE;

   FUNCTION f_pargaranpro_n(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcparam IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_pargaranpro_t(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcparam IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_pargaranpro_f(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcparam IN VARCHAR2)
      RETURN DATE;

   FUNCTION f_parinstalacion_n(pcparam IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_parinstalacion_t(pcparam IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_parinstalacion_f(pcparam IN VARCHAR2)
      RETURN DATE;

   FUNCTION f_parempresa_n(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_parempresa_t(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_parempresa_f(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN DATE;

   FUNCTION f_parmotmov_n(
      pcmotmov IN NUMBER,
      pcparam IN VARCHAR2,
      psproduc IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION f_parmotmov_t(
      pcmotmov IN NUMBER,
      pcparam IN VARCHAR2,
      psproduc IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

   FUNCTION f_parmotmov_f(
      pcmotmov IN NUMBER,
      pcparam IN VARCHAR2,
      psproduc IN NUMBER DEFAULT 0)
      RETURN DATE;

   FUNCTION f_parconexion_n(pcparam IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_parconexion_t(pcparam IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_parconexion_f(pcparam IN VARCHAR2)
      RETURN DATE;

   FUNCTION f_desgrpparam(
      pcgrppar IN VARCHAR2,
      pcutili IN NUMBER,
      pcidioma IN NUMBER,
      ptgrppar IN OUT VARCHAR2,
      pnformat IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   FUNCTION f_descparam(pcodi IN VARCHAR2, ptipo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /****************************************************************************
      F_DESCDETPARAM
      Obtener la descripción del parametro
      param in pcparam   : codigo del parametro
      param in pcvalpar  : codigo del valor del parametro
      param in pcidioma  : idioma
      retorno texto del valor del parametro
     Bug 8999 - 22/10/2009 - AMC
   *****************************************************************************/
   FUNCTION f_descdetparam(pcparam IN VARCHAR2, pcvalpar IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_parlistado_n(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_parlistado_t(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_parlistado_f(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN DATE;
   --
   --INI BUG 0039680 - 03/12/2018 - CASL - Se crean funciones para obtener parametros por producto y modalidad
   --
   FUNCTION f_parproductomod_n(psproduc    IN NUMBER  ,
                               pcmodalidad IN VARCHAR2,
                               pcparam     IN VARCHAR2)
      RETURN NUMBER;
   --
   FUNCTION f_parproductomod_t(psproduc    IN NUMBER  ,
                               pcmodalidad IN VARCHAR2,
                               pcparam     IN VARCHAR2)
      RETURN VARCHAR2;
   --
   FUNCTION f_parproductomod_f(psproduc    IN NUMBER  ,
                               pcmodalidad IN VARCHAR2,
                               pcparam     IN VARCHAR2)
      RETURN DATE;
   --
   --FIN BUG 0039680 - 03/12/2018 - CASL
   --
   --INI BUG 0050601 - 26/03/2019 - CASL - Se crea nueva funcion
   --
   FUNCTION f_parproductomodmail_t(psproduc    IN NUMBER  ,
                                   pcmodalidad IN VARCHAR2,
                                   pcparam     IN VARCHAR2)
      RETURN CLOB;
   --
   --FIN BUG 0050601 - 26/03/2019 - CASL
   --
END pac_parametros;



----Forma de obtener el DDL "Encabezado y Cuerpo" del paquete desde consulta 
SELECT DBMS_METADATA.GET_DDL('PACKAGE_BODY', 'PAC_PARAMETROS', 'AXIS') 
  FROM DUAL;




SELECT text 
  FROM all_source 
 WHERE owner = 'AXIS' 
   AND name = 'PAC_PARAMETROS' 
   AND type = 'PACKAGE BODY'
 ORDER BY line;  