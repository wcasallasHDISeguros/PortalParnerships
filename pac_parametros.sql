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

CREATE OR REPLACE PACKAGE BODY AXIS.pac_parametros AS
   salida         EXCEPTION;

   /****************************************************************************
      NOMBRE:       PAC_PARAMETROS
      PROPÓSITO:  Funciones para parametros
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ----------  ----------------------------------
      1.0                                1. Creación del package.
      2.0        18/02/2009   AMC        2. Modificación del package
      3.0        06/03/2009   JRB        3. Modificación del package
      4.0        19/05/2009   APD        4. Bug 10127: en todas las funciones donde se realiza
                                            una select contra codparam se ha de controlar con
                                            el when-no-data-found realizar un return NULL
      5.0        22/10/2009   AMC        5. Bug 8999: Se añade la función F_DESCDETPARAM
      6.0        29/11/2010   JMP        6. Bug 8999: Se controla que los parámetros existan en CODPARAM y sean del tipo correcto
      7.0        08/03/2011   JMP        7. Bug 8999: Sustituimos F_USER por F_USER al insertar en TAB_ERROR para evitar un bucle infinito si no
                                            existiera el parámetro 'CONTEXT_F_USER' en PARINSTALACION.
      8.0        17/03/2014   MMM        8. 0030549: LCOL_F002-0011750: Contabilidad Cierre de Reaseguros esta descuadrada...
      9.0        10/10/2013   SPC        8. 0028024: Optimización proceso tarificación y cartera
     10.0        03/12/2018   CASL       9. 0039680: APCN, debe crearse por garantia la pregunta de valor asegurado.
     11.0        26/03/2019   CASL      10. 0050601: Impresiones Masivas: Optimización Proceso de Impresiones Masivas Generación de Zips
   ****************************************************************************/
   PROCEDURE carga_array_codparam IS
   BEGIN
      IF v_codparam.COUNT = 0 THEN
         OPEN c_codparam;

         LOOP
            FETCH c_codparam
            BULK COLLECT INTO v_codparam;

            EXIT WHEN c_codparam%NOTFOUND;
         END LOOP;

         CLOSE c_codparam;

         -- llenamos el array de índices
         FOR i IN 1 .. v_codparam.COUNT LOOP
            vindt1(v_codparam(i).cparam) := i;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.CARGA_ARRAY_CODPARAM', 1,
                     'SQLERRM = ' || SQLERRM, 'Error no controlado');
   END;

   PROCEDURE carga_array_parproductos IS
   BEGIN
      IF v_parproductos.COUNT = 0 THEN
         OPEN c_parproductos;

         LOOP
            FETCH c_parproductos
            BULK COLLECT INTO v_parproductos;

            EXIT WHEN c_parproductos%NOTFOUND;
         END LOOP;

         CLOSE c_parproductos;

         -- llenamos el array de índices
         FOR i IN 1 .. v_parproductos.COUNT LOOP
            vindt2(v_parproductos(i).sproduc || v_parproductos(i).cparpro) := i;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.CARGA_ARRAY_PARPRODUCTOS', 1,
                     'SQLERRM = ' || SQLERRM, 'Error no controlado');
   END;

   PROCEDURE carga_array_parinstalacion IS
   BEGIN
      IF v_parinstalacion.COUNT = 0 THEN
         OPEN c_parinstalacion;

         LOOP
            FETCH c_parinstalacion
            BULK COLLECT INTO v_parinstalacion;

            EXIT WHEN c_parinstalacion%NOTFOUND;
         END LOOP;

         CLOSE c_parinstalacion;

         -- llenamos el array de índices
         FOR i IN 1 .. v_parinstalacion.COUNT LOOP
            vindt3(v_parinstalacion(i).cparame) := i;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.CARGA_ARRAY_PARINSTALACION', 1,
                     'SQLERRM = ' || SQLERRM, 'Error no controlado');
   END;

   PROCEDURE carga_array_parempresas IS
   BEGIN
      IF v_parempresas.COUNT = 0 THEN
         OPEN c_parempresas;

         LOOP
            FETCH c_parempresas
            BULK COLLECT INTO v_parempresas;

            EXIT WHEN c_parempresas%NOTFOUND;
         END LOOP;

         CLOSE c_parempresas;

         -- llenamos el array de índices
         FOR i IN 1 .. v_parempresas.COUNT LOOP
            vindt4(v_parempresas(i).cempres || v_parempresas(i).cparam) := i;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.CARGA_ARRAY_PAREMPRESAS', 1,
                     'SQLERRM = ' || SQLERRM, 'Error no controlado');
   END;

   /****************************************************************************
      FUNCTION F_PARPRODUCTO_N
      Obtiene el valor numérico del parámetro de producto.
         param in psproduc : Código de producto
         param in pcparam  : Código de parámetro
         return            : valor numérico del parámetro
   *****************************************************************************/
   FUNCTION f_parproducto_n(psproduc IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       parproductos.cvalpar%TYPE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;
      carga_array_codparam;
      carga_array_parproductos;
      vctipo := v_codparam(vindt1(pcparam)).ctipo;
      vtdefecto := v_codparam(vindt1(pcparam)).tdefecto;
      vntraza := 2;

      IF vctipo IN(2, 4) THEN
         BEGIN
            vcvalpar := v_parproductos(vindt2(psproduc || pcparam)).cvalpar;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vntraza := 3;
               vcvalpar := vtdefecto;
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARPRODUCTO_N', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARPRODUCTO_N', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARPRODUCTO_N', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_parproducto_n;

   /****************************************************************************
      FUNCTION F_PARPRODUCTO_T
      Obtiene el valor Texto del parámetro de producto.
         param in psproduc : Código de producto
         param in pcparam  : Código de parámetro
         return            : valor Texto del parámetro
   *****************************************************************************/
   FUNCTION f_parproducto_t(psproduc IN NUMBER, pcparam IN VARCHAR2)
      RETURN VARCHAR2 IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       parproductos.tvalpar%TYPE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;
      carga_array_codparam;
      carga_array_parproductos;
      vctipo := v_codparam(vindt1(pcparam)).ctipo;
      vtdefecto := v_codparam(vindt1(pcparam)).tdefecto;
      vntraza := 2;

      IF vctipo = 1 THEN
         BEGIN
            vcvalpar := v_parproductos(vindt2(psproduc || pcparam)).tvalpar;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vntraza := 3;
               vcvalpar := vtdefecto;
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARPRODUCTO_T', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARPRODUCTO_T', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARPRODUCTO_T', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_parproducto_t;

   /****************************************************************************
      FUNCTION F_PARPRODUCTO_F
      Obtiene el valor Fecha del parámetro de producto.
         param in psproduc : Código de producto
         param in pcparam  : Código de parámetro
         return            : valor Fecha del parámetro
   *****************************************************************************/
   FUNCTION f_parproducto_f(psproduc IN NUMBER, pcparam IN VARCHAR2)
      RETURN DATE IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       DATE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;

      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;

      vntraza := 2;

      IF vctipo = 3 THEN
         BEGIN
            SELECT fvalpar
              INTO vcvalpar
              FROM parproductos
             WHERE sproduc = psproduc
               AND cparpro = pcparam;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vntraza := 3;
               vcvalpar := TO_DATE(vtdefecto, 'ddmmyyyy');
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARPRODUCTO_F', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARPRODUCTO_F', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARPRODUCTO_F', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_parproducto_f;

   /****************************************************************************
      FUNCTION F_PARACTIVIDAD_N
      Obtiene el valor numérico del parámetro de actividad.
         param in psproduc : Código de producto
         param in pcactivi : código de actividad
         param in pcparam  : Código de parámetro
         return            : valor numérico del parámetro
   *****************************************************************************/
   FUNCTION f_paractividad_n(psproduc IN NUMBER, pcactivi IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       paractividad.nvalpar%TYPE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;

      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;

      vntraza := 2;

      IF vctipo IN(2, 4) THEN
         BEGIN
            SELECT nvalpar
              INTO vcvalpar
              FROM paractividad
             WHERE sproduc = psproduc
               AND cparame = pcparam
               AND cactivi = pcactivi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vntraza := 3;
               vcvalpar := vtdefecto;
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARACTIVIDAD_N', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARACTIVIDAD_N', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARACTIVIDAD_N', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_paractividad_n;

   /****************************************************************************
      FUNCTION F_PARACTIVIDAD_T
      Obtiene el valor Texto del parámetro de actividad.
         param in psproduc : Código de producto
         param in pcactivi : código de actividad
         param in pcparam  : Código de parámetro
         return            : valor Texto del parámetro
   *****************************************************************************/
   FUNCTION f_paractividad_t(psproduc IN NUMBER, pcactivi IN NUMBER, pcparam IN VARCHAR2)
      RETURN VARCHAR2 IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       paractividad.tvalpar%TYPE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;

      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;

      vntraza := 2;

      IF vctipo = 1 THEN
         BEGIN
            SELECT tvalpar
              INTO vcvalpar
              FROM paractividad
             WHERE sproduc = psproduc
               AND cparame = pcparam
               AND cactivi = pcactivi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vntraza := 3;
               vcvalpar := vtdefecto;
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARACTIVIDAD_T', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARACTIVIDAD_T', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARACTIVIDAD_T', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_paractividad_t;

   /****************************************************************************
      FUNCTION F_PARACTIVIDAD_F
      Obtiene el valor Fecha del parámetro de actividad.
         param in psproduc : Código de producto
         param in pcactivi : código de actividad
         param in pcparam  : Código de parámetro
         return            : valor Fecha del parámetro
   *****************************************************************************/
   FUNCTION f_paractividad_f(psproduc IN NUMBER, pcactivi IN NUMBER, pcparam IN VARCHAR2)
      RETURN DATE IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       DATE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;

      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;

      vntraza := 2;

      IF vctipo = 3 THEN
         BEGIN
            SELECT fvalpar
              INTO vcvalpar
              FROM paractividad
             WHERE sproduc = psproduc
               AND cparame = pcparam
               AND cactivi = pcactivi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vntraza := 3;
               vcvalpar := TO_DATE(vtdefecto, 'ddmmyyyy');
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARACTIVIDAD_F', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARACTIVIDAD_F', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARACTIVIDAD_F', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_paractividad_f;

   /****************************************************************************
      FUNCTION F_PARGARANPRO_N
      Obtiene el valor numérico del parámetro de garantía.
         param in psproduc : Código de producto
         param in pcactivi : código de actividad
         param in pcgarant : código de garantía
         param in pcparam  : Código de parámetro
         return            : valor numérico del parámetro
   *****************************************************************************/
   FUNCTION f_pargaranpro_n(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcparam IN VARCHAR2)
      RETURN NUMBER IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       pargaranpro.cvalpar%TYPE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;

      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;

      -- 8.0 - 17/03/2014 - MMM - 0030549: LCOL_F002-0011750: Contabilidad Cierre de Reaseguros esta descuadrada... - Fin
      vntraza := 2;

      IF vctipo IN(2, 4) THEN
         BEGIN
            SELECT cvalpar
              INTO vcvalpar
              FROM pargaranpro
             WHERE sproduc = psproduc
               AND cpargar = pcparam
               AND cactivi = pcactivi
               AND cgarant = pcgarant;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT cvalpar
                    INTO vcvalpar
                    FROM pargaranpro
                   WHERE sproduc = psproduc
                     AND cpargar = pcparam
                     AND cactivi = 0
                     AND cgarant = pcgarant;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vntraza := 3;
                     vcvalpar := vtdefecto;
                  WHEN OTHERS THEN
                     vcvalpar := NULL;
               END;
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARGARANPRO_N', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARGARANPRO_N', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARGARANPRO_N', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_pargaranpro_n;

   /****************************************************************************
      FUNCTION F_PARGARANPRO_T
      Obtiene el valor Texto del parámetro de garantía.
         param in psproduc : Código de producto
         param in pcactivi : código de actividad
         param in pcgarant : código de garantía
         param in pcparam  : Código de parámetro
         return            : valor Texto del parámetro
   *****************************************************************************/
   FUNCTION f_pargaranpro_t(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcparam IN VARCHAR2)
      RETURN VARCHAR2 IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       pargaranpro.tvalpar%TYPE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;

      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;

      vntraza := 2;

      IF vctipo = 1 THEN
         BEGIN
            SELECT tvalpar
              INTO vcvalpar
              FROM pargaranpro
             WHERE sproduc = psproduc
               AND cpargar = pcparam
               AND cactivi = pcactivi
               AND cgarant = pcgarant;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT tvalpar
                    INTO vcvalpar
                    FROM pargaranpro
                   WHERE sproduc = psproduc
                     AND cpargar = pcparam
                     AND cactivi = 0
                     AND cgarant = pcgarant;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vntraza := 3;
                     vcvalpar := vtdefecto;
                  WHEN OTHERS THEN
                     vcvalpar := NULL;
               END;
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARGARANPRO_T', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARGARANPRO_T', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARGARANPRO_T', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_pargaranpro_t;

   /****************************************************************************
      FUNCTION F_PARGARANPRO_F
      Obtiene el valor Fecha del parámetro de garantía.
         param in psproduc : Código de producto
         param in pcactivi : código de actividad
         param in pcgarant : código de garantía
         param in pcparam  : Código de parámetro
         return            : valor Fecha del parámetro
   *****************************************************************************/
   FUNCTION f_pargaranpro_f(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcparam IN VARCHAR2)
      RETURN DATE IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       DATE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;

      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;

      vntraza := 2;

      IF vctipo = 3 THEN
         BEGIN
            SELECT fvalpar
              INTO vcvalpar
              FROM pargaranpro
             WHERE sproduc = psproduc
               AND cpargar = pcparam
               AND cactivi = pcactivi
               AND cgarant = pcgarant;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT fvalpar
                    INTO vcvalpar
                    FROM pargaranpro
                   WHERE sproduc = psproduc
                     AND cpargar = pcparam
                     AND cactivi = 0
                     AND cgarant = pcgarant;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vntraza := 3;
                     vcvalpar := TO_DATE(vtdefecto, 'ddmmyyyy');
                  WHEN OTHERS THEN
                     vcvalpar := NULL;
               END;
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARGARANPRO_F', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARGARANPRO_F', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARGARANPRO_F', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_pargaranpro_f;

   /****************************************************************************
      FUNCTION F_PARINSTALACION_N
      Obtiene el valor numérico del parámetro de instalación.
         param in pcparam  : Código de parámetro
         return            : valor numérico del parámetro
   *****************************************************************************/
   FUNCTION f_parinstalacion_n(pcparam IN VARCHAR2)
      RETURN NUMBER IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       parinstalacion.nvalpar%TYPE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;
      carga_array_codparam;
      carga_array_parinstalacion;
      vctipo := v_codparam(vindt1(pcparam)).ctipo;
      vtdefecto := v_codparam(vindt1(pcparam)).tdefecto;
      vntraza := 2;

      IF vctipo IN(2, 4) THEN
         BEGIN
            vcvalpar := v_parinstalacion(vindt3(pcparam)).nvalpar;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vntraza := 3;
               vcvalpar := vtdefecto;
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARINSTALACION_N', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARINSTALACION_N', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARINSTALACION_N', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_parinstalacion_n;

   /****************************************************************************
      FUNCTION F_PARINSTALACION_T
      Obtiene el valor Texto del parámetro de instalación.
         param in pcparam  : Código de parámetro
         return            : valor Texto del parámetro
   *****************************************************************************/
   FUNCTION f_parinstalacion_t(pcparam IN VARCHAR2)
      RETURN VARCHAR2 IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       parinstalacion.tvalpar%TYPE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;
      carga_array_codparam;
      carga_array_parinstalacion;
      vctipo := v_codparam(vindt1(pcparam)).ctipo;
      vtdefecto := v_codparam(vindt1(pcparam)).tdefecto;
      vntraza := 2;

      IF vctipo = 1 THEN
         BEGIN
            vcvalpar := v_parinstalacion(vindt3(pcparam)).tvalpar;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vntraza := 3;
               vcvalpar := vtdefecto;
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARINSTALACION_T', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARINSTALACION_T', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARINSTALACION_T', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_parinstalacion_t;

   /****************************************************************************
      FUNCTION F_PARINSTALACION_F
      Obtiene el valor Fecha del parámetro de instalación.
         param in pcparam  : Código de parámetro
         return            : valor Fecha del parámetro
   *****************************************************************************/
   FUNCTION f_parinstalacion_f(pcparam IN VARCHAR2)
      RETURN DATE IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       DATE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;

      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;

      vntraza := 2;

      IF vctipo = 3 THEN
         BEGIN
            SELECT fvalpar
              INTO vcvalpar
              FROM parinstalacion
             WHERE cparame = pcparam;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vntraza := 3;
               vcvalpar := TO_DATE(vtdefecto, 'ddmmyyyy');
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARINSTALACION_F', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARINSTALACION_F', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARINSTALACION_F', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_parinstalacion_f;

   /****************************************************************************
      FUNCTION F_PAREMPRESA_N
      Obtiene el valor numérico del parámetro de empresa.
         param in pcempres : Código de empresa
         param in pcparam  : Código de parámetro
         return            : valor numérico del parámetro
   *****************************************************************************/
   FUNCTION f_parempresa_n(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       parempresas.nvalpar%TYPE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;
      carga_array_codparam;
      carga_array_parempresas;
      vctipo := v_codparam(vindt1(pcparam)).ctipo;
      vtdefecto := v_codparam(vindt1(pcparam)).tdefecto;
      vntraza := 2;

      IF vctipo IN(2, 4) THEN
         BEGIN
            vcvalpar := v_parempresas(vindt4(pcempres || pcparam)).nvalpar;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vntraza := 3;
               vcvalpar := vtdefecto;
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PAREMPRESA_N', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PAREMPRESA_N', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PAREMPRESA_N', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_parempresa_n;

   /****************************************************************************
      FUNCTION F_PAREMPRESA_T
      Obtiene el valor Texto del parámetro de empresa.
         param in pcempres : Código de empresa
         param in pcparam  : Código de parámetro
         return            : valor Texto del parámetro
   *****************************************************************************/
   FUNCTION f_parempresa_t(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN VARCHAR2 IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       parempresas.tvalpar%TYPE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;

      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;

      vntraza := 2;

      IF vctipo = 1 THEN
         BEGIN
            SELECT tvalpar
              INTO vcvalpar
              FROM parempresas
             WHERE cempres = pcempres
               AND cparam = pcparam;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vntraza := 3;
               vcvalpar := vtdefecto;
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PAREMPRESA_T', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PAREMPRESA_T', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PAREMPRESA_T', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_parempresa_t;

   /****************************************************************************
      FUNCTION F_PAREMPRESA_F
      Obtiene el valor Fecha del parámetro de empresa.
         param in pcempres : Código de empresa
         param in pcparam  : Código de parámetro
         return            : valor Fecha del parámetro
   *****************************************************************************/
   FUNCTION f_parempresa_f(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN DATE IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       DATE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;

      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;

      vntraza := 2;

      IF vctipo = 3 THEN
         BEGIN
            SELECT fvalpar
              INTO vcvalpar
              FROM parempresas
             WHERE cempres = pcempres
               AND cparam = pcparam;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vntraza := 3;
               vcvalpar := TO_DATE(vtdefecto, 'ddmmyyyy');
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PAREMPRESA_F', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PAREMPRESA_F', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PAREMPRESA_F', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_parempresa_f;

   /****************************************************************************
      FUNCTION F_PARMOTMOV_N
      Obtiene el valor numérico del parámetro de movimiento.
         param in pcmotmov : código de motivo de movimiento
         param in pcparam  : Código de parámetro
         param in psproduc : Código de producto
         return            : valor numérico del parámetro
   *****************************************************************************/
   FUNCTION f_parmotmov_n(pcmotmov IN NUMBER, pcparam IN VARCHAR2, psproduc IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       parmotmov.cvalpar%TYPE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;

      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;

      vntraza := 2;

      IF vctipo IN(2, 4) THEN
         BEGIN
            SELECT cvalpar
              INTO vcvalpar
              FROM parmotmov
             WHERE sproduc = psproduc
               AND cparmot = pcparam
               AND cmotmov = pcmotmov;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT cvalpar
                    INTO vcvalpar
                    FROM parmotmov
                   WHERE sproduc = 0
                     AND cparmot = pcparam
                     AND cmotmov = pcmotmov;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vntraza := 3;
                     vcvalpar := vtdefecto;
                  WHEN OTHERS THEN
                     vcvalpar := NULL;
               END;
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARMOTMOV_N', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARMOTMOV_N', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARMOTMOV_N', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_parmotmov_n;

   /****************************************************************************
      FUNCTION F_PARMOTMOV_T
      Obtiene el valor Texto del parámetro de movimiento.
         param in pcmotmov : código de motivo de movimiento
         param in pcparam  : Código de parámetro
         param in psproduc : Código de producto
         return            : valor Texto del parámetro
   *****************************************************************************/
   FUNCTION f_parmotmov_t(pcmotmov IN NUMBER, pcparam IN VARCHAR2, psproduc IN NUMBER DEFAULT 0)
      RETURN VARCHAR2 IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       parmotmov.tvalpar%TYPE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;

      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;

      vntraza := 2;

      IF vctipo = 1 THEN
         BEGIN
            SELECT tvalpar
              INTO vcvalpar
              FROM parmotmov
             WHERE sproduc = psproduc
               AND cparmot = pcparam
               AND cmotmov = pcmotmov;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT tvalpar
                    INTO vcvalpar
                    FROM parmotmov
                   WHERE sproduc = 0
                     AND cparmot = pcparam
                     AND cmotmov = pcmotmov;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vntraza := 3;
                     vcvalpar := vtdefecto;
                  WHEN OTHERS THEN
                     vcvalpar := NULL;
               END;
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARMOTMOV_T', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARMOTMOV_T', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARMOTMOV_T', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_parmotmov_t;

   /****************************************************************************
      FUNCTION F_PARMOTMOV_F
      Obtiene el valor Fecha del parámetro de movimiento.
         param in pcmotmov : código de motivo de movimiento
         param in pcparam  : Código de parámetro
         param in psproduc : Código de producto
         return            : valor Fecha del parámetro
   *****************************************************************************/
   FUNCTION f_parmotmov_f(pcmotmov IN NUMBER, pcparam IN VARCHAR2, psproduc IN NUMBER DEFAULT 0)
      RETURN DATE IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       DATE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;

      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;

      vntraza := 2;

      IF vctipo = 3 THEN
         BEGIN
            SELECT fvalpar
              INTO vcvalpar
              FROM parmotmov
             WHERE sproduc = psproduc
               AND cparmot = pcparam
               AND cmotmov = pcmotmov;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT fvalpar
                    INTO vcvalpar
                    FROM parmotmov
                   WHERE sproduc = 0
                     AND cparmot = pcparam
                     AND cmotmov = pcmotmov;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vntraza := 3;
                     vcvalpar := TO_DATE(vtdefecto, 'ddmmyyyy');
                  WHEN OTHERS THEN
                     vcvalpar := NULL;
               END;
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARMOTMOV_F', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARMOTMOV_F', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARMOTMOV_F', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_parmotmov_f;
   --
   --INI BUG 0039680 - 03/12/2018 - CASL - Se crean funciones para obtener parametros por producto y modalidad
   --
   /****************************************************************************
      FUNCTION F_PARPRODUCTOMOD_N
      Obtiene el valor numérico del parámetro de producto y modaliad.
         return            : valor numérico del parámetro
   *****************************************************************************/
   --
   FUNCTION f_parproductomod_n(psproduc    IN NUMBER  ,
                               pcmodalidad IN VARCHAR2,
                               pcparam     IN VARCHAR2)
      RETURN NUMBER
   IS
      --
      vctipo    codparam.ctipo   %TYPE;
      vtdefecto codparam.tdefecto%TYPE;
      vcvalpar  parmotmov.cvalpar%TYPE;
      vntraza   tab_error.ntraza %TYPE;
      --
      vparam VARCHAR2(100) := ' -psproduc: '    ||psproduc   ||
                              ' -pcmodalidad: ' ||pcmodalidad||
                              ' -pcparam: '     ||pcparam;
      --
   BEGIN
      --
      vntraza := 1;
      --
      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;
      --
      vntraza := 2;
      --
      vparam := vparam || ' ctipo: ' || vctipo;
      --
      IF vctipo IN(2, 4)
      THEN
         --
         BEGIN
            --
            SELECT cvalpar
              INTO vcvalpar
              FROM parproductosmod
             WHERE sproduc    = psproduc
               AND cmodalidad = pcmodalidad
               AND cparpro    = pcparam;
            --
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               --
               BEGIN
                  --
                  SELECT cvalpar
                    INTO vcvalpar
                    FROM parproductosmod
                   WHERE sproduc    = 0
                     AND cmodalidad = pcmodalidad
                     AND cparpro    = pcparam;
                  --
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     --
                     vntraza := 3;
                     --
                     vcvalpar := vtdefecto;
                     --
                  WHEN OTHERS
                  THEN
                     --
                     vcvalpar := NULL;
                     --
               END;
               --
            WHEN OTHERS
            THEN
               --
               vcvalpar := NULL;
               --
         END;
         --
      ELSE
         --
         p_tab_error(pferror   => f_sysdate,
                     pcusuari  => f_user,
                     ptobjeto  => 'PAC_PARAMETROS.F_PARPRODUCTOMOD_N',
                     pntraza   => vntraza,
                     ptdescrip => vparam,
                     pterror   => 'Tipo de parámetro diferente al esperado');
         --
         vcvalpar := NULL;
         --
      END IF;
      --
      RETURN vcvalpar;
      --
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         --
         p_tab_error(pferror   => f_sysdate,
                     pcusuari  => f_user,
                     ptobjeto  => 'PAC_PARAMETROS.F_PARPRODUCTOMOD_N',
                     pntraza   => vntraza,
                     ptdescrip => vparam,
                     pterror   => 'Parámetro no definido');
         --
         RETURN NULL;
         --
      WHEN OTHERS
      THEN
         --
         p_tab_error(pferror   => f_sysdate,
                     pcusuari  => f_user,
                     ptobjeto  => 'PAC_PARAMETROS.F_PARPRODUCTOMOD_N',
                     pntraza   => vntraza,
                     ptdescrip => vparam || ' -SQLERRM: ' || SQLERRM,
                     pterror   => 'Error no controlado');
         --
         RETURN NULL;
         --
   END f_parproductomod_n;
   --
   /****************************************************************************
      FUNCTION F_PARPRODUCTOMOD_T
      Obtiene el valor Texto del parámetro de producto y modaliad.
         return            : valor Texto del parámetro
   *****************************************************************************/
   --
   FUNCTION f_parproductomod_t(psproduc    IN NUMBER  ,
                               pcmodalidad IN VARCHAR2,
                               pcparam     IN VARCHAR2)
      RETURN VARCHAR2
   IS
      --
      vctipo    codparam.ctipo   %TYPE;
      vtdefecto codparam.tdefecto%TYPE;
      vcvalpar  parmotmov.tvalpar%TYPE;
      vntraza   tab_error.ntraza %TYPE;
      --
      vparam VARCHAR2(100) := ' -psproduc: '    ||psproduc   ||
                              ' -pcmodalidad: ' ||pcmodalidad||
                              ' -pcparam: '     ||pcparam;
      --
   BEGIN
      --
      vntraza := 1;
      --
      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;
      --
      vntraza := 2;
      --
      vparam := vparam || ' ctipo: ' || vctipo;
      --
      IF vctipo = 1
      THEN
         --
         BEGIN
            --
            SELECT tvalpar
              INTO vcvalpar
              FROM parproductosmod
             WHERE sproduc    = psproduc
               AND cmodalidad = pcmodalidad
               AND cparpro    = pcparam;
            --
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               --
               BEGIN
                  --
                  SELECT tvalpar
                    INTO vcvalpar
                    FROM parproductosmod
                   WHERE sproduc    = 0
                     AND cmodalidad = pcmodalidad
                     AND cparpro    = pcparam;
                  --
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     --
                     vntraza := 3;
                     --
                     vcvalpar := vtdefecto;
                     --
                  WHEN OTHERS
                  THEN
                     --
                     vcvalpar := NULL;
                     --
               END;
               --
            WHEN OTHERS
            THEN
               --
               vcvalpar := NULL;
               --
         END;
         --
      ELSE
         --
         p_tab_error(pferror   => f_sysdate,
                     pcusuari  => f_user,
                     ptobjeto  => 'PAC_PARAMETROS.F_PARPRODUCTOMOD_T',
                     pntraza   => vntraza,
                     ptdescrip => vparam,
                     pterror   => 'Tipo de parámetro diferente al esperado');
         --
         vcvalpar := NULL;
         --
      END IF;
      --
      RETURN vcvalpar;
      --
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         --
         p_tab_error(pferror   => f_sysdate,
                     pcusuari  => f_user,
                     ptobjeto  => 'PAC_PARAMETROS.F_PARPRODUCTOMOD_T',
                     pntraza   => vntraza,
                     ptdescrip => vparam,
                     pterror   => 'Parámetro no definido');
         --
         RETURN NULL;
         --
      WHEN OTHERS THEN
         --
         p_tab_error(pferror   => f_sysdate,
                     pcusuari  => f_user,
                     ptobjeto  => 'PAC_PARAMETROS.F_PARPRODUCTOMOD_T',
                     pntraza   => vntraza,
                     ptdescrip => vparam || ' -SQLERRM: ' || SQLERRM,
                     pterror   => 'Error no controlado');
         --
         RETURN NULL;
         --
   END f_parproductomod_t;
   --
   /****************************************************************************
      FUNCTION F_parproductomod_F
      Obtiene el valor Fecha del parámetro de producto y modaliad.
         return            : valor Fecha del parámetro
   *****************************************************************************/
   FUNCTION f_parproductomod_f(psproduc    IN NUMBER  ,
                               pcmodalidad IN VARCHAR2,
                               pcparam     IN VARCHAR2)
      RETURN DATE
   IS
      --
      vctipo    codparam.ctipo   %TYPE;
      vtdefecto codparam.tdefecto%TYPE;
      vntraza   tab_error.ntraza %TYPE;
      --
      vcvalpar DATE;
      --
      vparam VARCHAR2(100) := ' -psproduc: '    ||psproduc   ||
                              ' -pcmodalidad: ' ||pcmodalidad||
                              ' -pcparam: '     ||pcparam;
      --
   BEGIN
      --
      vntraza := 1;
      --
      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;
      --
      vntraza := 2;
      --
      vparam := vparam || ' ctipo: ' || vctipo;
      --
      IF vctipo = 3
      THEN
         --
         BEGIN
            --
            SELECT fvalpar
              INTO vcvalpar
              FROM parproductosmod
             WHERE sproduc    = psproduc
               AND cmodalidad = pcmodalidad
               AND cparpro    = pcparam;
            --
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               --
               BEGIN
                  --
                  SELECT fvalpar
                    INTO vcvalpar
                    FROM parproductosmod
                   WHERE sproduc    = 0
                     AND cmodalidad = pcmodalidad
                     AND cparpro    = pcparam;
                  --
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     --
                     vntraza := 3;
                     --
                     vcvalpar := TO_DATE(vtdefecto, 'ddmmyyyy');
                     --
                  WHEN OTHERS
                  THEN
                     --
                     vcvalpar := NULL;
                     --
               END;
               --
            WHEN OTHERS
            THEN
               --
               vcvalpar := NULL;
               --
         END;
         --
      ELSE
         --
         p_tab_error(pferror   => f_sysdate,
                     pcusuari  => f_user,
                     ptobjeto  => 'PAC_PARAMETROS.F_PARPRODUCTOMOD_F',
                     pntraza   => vntraza,
                     ptdescrip => vparam,
                     pterror   => 'Tipo de parámetro diferente al esperado');
         --
         vcvalpar := NULL;
         --
      END IF;
      --
      RETURN vcvalpar;
      --
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         --
         p_tab_error(pferror   => f_sysdate,
                     pcusuari  => f_user,
                     ptobjeto  => 'PAC_PARAMETROS.F_PARPRODUCTOMOD_F',
                     pntraza   => vntraza,
                     ptdescrip => vparam,
                     pterror   => 'Parámetro no definido');
         --
         RETURN NULL;
         --
      WHEN OTHERS
      THEN
         --
         p_tab_error(pferror   => f_sysdate,
                     pcusuari  => f_user,
                     ptobjeto  => 'PAC_PARAMETROS.F_PARPRODUCTOMOD_F',
                     pntraza   => vntraza,
                     ptdescrip => vparam || ' -SQLERRM: ' || SQLERRM,
                     pterror   => 'Error no controlado');
         --
         RETURN NULL;
         --
   END f_parproductomod_f;
   --
   --FIN BUG 0039680 - 03/12/2018 - CASL
   --
   /****************************************************************************
      FUNCTION F_PARCONEXION_N
      Obtiene el valor numérico del parámetro de conexion.
         param in pcparam  : Código de parámetro
         return            : valor numérico del parámetro
   *****************************************************************************/
   FUNCTION f_parconexion_n(pcparam IN VARCHAR2)
      RETURN NUMBER IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       parconexion.cvalpar%TYPE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;

      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;

      vntraza := 2;

      IF vctipo IN(2, 4) THEN
         BEGIN
            SELECT cvalpar
              INTO vcvalpar
              FROM parconexion
             WHERE cparame = pcparam;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vntraza := 3;
               vcvalpar := vtdefecto;
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARCONEXION_N', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARCONEXION_N', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARCONEXION_N', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_parconexion_n;

   /****************************************************************************
      FUNCTION F_PARCONEXION_T
      Obtiene el valor Texto del parámetro de conexión.
         param in pcparam  : Código de parámetro
         return            : valor Texto del parámetro
   *****************************************************************************/
   FUNCTION f_parconexion_t(pcparam IN VARCHAR2)
      RETURN VARCHAR2 IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       parconexion.tvalpar%TYPE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;

      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;

      vntraza := 2;

      IF vctipo = 1 THEN
         BEGIN
            SELECT tvalpar
              INTO vcvalpar
              FROM parconexion
             WHERE cparame = pcparam;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vcvalpar := vtdefecto;
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARCONEXION_T', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARCONEXION_T', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARCONEXION_T', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_parconexion_t;

   /****************************************************************************
      FUNCTION F_PARCONEXION_F
      Obtiene el valor Fecha del parámetro de conexión.
         param in pcparam  : Código de parámetro
         return            : valor Fecha del parámetro
   *****************************************************************************/
   FUNCTION f_parconexion_f(pcparam IN VARCHAR2)
      RETURN DATE IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       DATE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;

      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;

      vntraza := 2;

      IF vctipo = 3 THEN
         BEGIN
            SELECT fvalpar
              INTO vcvalpar
              FROM parconexion
             WHERE cparame = pcparam;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vntraza := 3;
               vcvalpar := TO_DATE(vtdefecto, 'ddmmyyyy');
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARCONEXION_F', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARCONEXION_F', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARCONEXION_F', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_parconexion_f;

   /****************************************************************************
      FUNCTION F_PARLISTADO_N
      Obtiene el valor numérico del parámetro de listado.
         param in pcempres : Código de empresa
         param in pcparam  : Código de parámetro
         return            : valor numérico del parámetro
   *****************************************************************************/
   FUNCTION f_parlistado_n(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       parlistados.nvalpar%TYPE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;

      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;

      vntraza := 2;

      IF vctipo IN(2, 4) THEN
         BEGIN
            SELECT nvalpar
              INTO vcvalpar
              FROM parlistados
             WHERE cempres = pcempres
               AND cparame = pcparam;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vntraza := 3;
               vcvalpar := vtdefecto;
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARLISTADO_N', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARLISTADO_N', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARLISTADO_N', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_parlistado_n;

   /****************************************************************************
      FUNCTION F_PARLISTADO_T
      Obtiene el valor Texto del parámetro de listado.
         param in pcempres : Código de empresa
         param in pcparam  : Código de parámetro
         return            : valor Texto del parámetro
   *****************************************************************************/
   FUNCTION f_parlistado_t(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN VARCHAR2 IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       parlistados.tvalpar%TYPE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;

      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;

      vntraza := 2;

      IF vctipo = 1 THEN
         BEGIN
            SELECT tvalpar
              INTO vcvalpar
              FROM parlistados
             WHERE cempres = pcempres
               AND cparame = pcparam;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vntraza := 3;
               vcvalpar := vtdefecto;
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARLISTADO_T', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARLISTADO_T', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARLISTADO_T', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_parlistado_t;

   /****************************************************************************
      FUNCTION F_PARLISTADO_F
      Obtiene el valor Fecha del parámetro de listado.
         param in pcempres : Código de empresa
         param in pcparam  : Código de parámetro
         return            : valor Fecha del parámetro
   *****************************************************************************/
   FUNCTION f_parlistado_f(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN DATE IS
      vctipo         codparam.ctipo%TYPE;
      vtdefecto      codparam.tdefecto%TYPE;
      vcvalpar       DATE;
      vntraza        tab_error.ntraza%TYPE;
   BEGIN
      vntraza := 1;

      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;

      vntraza := 2;

      IF vctipo = 3 THEN
         BEGIN
            SELECT fvalpar
              INTO vcvalpar
              FROM parlistados
             WHERE cempres = pcempres
               AND cparame = pcparam;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vntraza := 3;
               vcvalpar := TO_DATE(vtdefecto, 'ddmmyyyy');
            WHEN OTHERS THEN
               vcvalpar := NULL;
         END;
      ELSE
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARLISTADO_F', vntraza,
                     'CPARAM = ' || pcparam || '; CTIPO = ' || vctipo,
                     'Tipo de parámetro diferente al esperado');
         vcvalpar := NULL;
      END IF;

      RETURN vcvalpar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARLISTADO_F', vntraza,
                     'CPARAM = ' || pcparam, 'Parámetro no definido');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PARAMETROS.F_PARLISTADO_F', vntraza,
                     'CPARAM = ' || pcparam || '; SQLERRM = ' || SQLERRM,
                     'Error no controlado');
         RETURN NULL;
   END f_parlistado_f;

   /****************************************************************************
      FUNCTION F_DESGRPPARAM
      Obtener la descripción de un grupo de parámetros de producto.
         param in pcgrppar     : código del grupo
         param in pcutili      : utilidad del parámetro VF.281 (1.- Porductos, 2.- Actividad, etc¿..)
         param in pcidioma     : código de idioma
         param in out ptgrppar : descripción del grupo
         param in pnformat     : 1 - descripción del grupo
                                 2 - descripción del grupo principal
                                 3 - descripción completa (desc. grupo principal fins 60/desc. grupo)
                                 4 - descripción completa (desc. grupo principal/desc. grupo)
                                 5 - descripción formateada: para grupo principal (descripcion)
                                                             para subgrupo        (descripcion)
         return                : 0 si todo es correcto
                                 código del error en caso de que lo haya
   *****************************************************************************/
   -- BUG 5176 - 06/03/2009 - JRB - Se modifica
   FUNCTION f_desgrpparam(
      pcgrppar IN VARCHAR2,
      pcutili IN NUMBER,
      pcidioma IN NUMBER,
      ptgrppar IN OUT VARCHAR2,
      pnformat IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      v_grppal       VARCHAR2(4);   --codigo del grupo principal
      v_desc         VARCHAR2(60);   --descripcion del grupo
      v_descpal      VARCHAR2(60);   --descripcion del grupo principal
      v_numerror     NUMBER := 0;
   BEGIN
      /*** Cuerpo de la función ***/
      v_grppal := SUBSTR(pcgrppar, 1, 2);
      RETURN 0;

      BEGIN
         SELECT tgrppar
           INTO v_desc
           FROM desgrpparam
          WHERE cgrppar = pcgrppar
            AND cidioma = pcidioma
            AND cutili = pcutili;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_numerror := 800249;
            RAISE salida;
      END;

      --paso := 2;                      --Ha recuperado la descripción del grupo
      BEGIN
         SELECT tgrppar
           INTO v_descpal
           FROM desgrpparam
          WHERE cgrppar = v_grppal
            AND cutili = pcutili
            AND cidioma = pcidioma;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_numerror := 800249;
            RAISE salida;
      END;

      --paso := 3;            --Ha recuperado la descripción del grupo principal
      IF pnformat = 1 THEN
         ptgrppar := v_desc;
      ELSIF pnformat = 2 THEN
         ptgrppar := v_descpal;
      ELSIF pnformat = 3 THEN
         ptgrppar := RPAD(v_descpal, 60, ' ') || ' / ' || v_desc;
      ELSIF pnformat = 4 THEN
         ptgrppar := v_descpal || ' / ' || v_desc;
      ELSIF pnformat = 5 THEN
         IF LENGTH(pcgrppar) = 2 THEN
            ptgrppar := v_desc;
         ELSE
            ptgrppar := LPAD(v_desc, LENGTH(v_desc) + 3, ' ');
         END IF;
      END IF;

      --paso := 4;                                --Ha formateado la descripción
      RAISE salida;
   EXCEPTION
      WHEN salida THEN
         RETURN v_numerror;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_parametros.f_desgrpparam', 1,
                     'when others cgrppar =' || pcgrppar, SQLERRM);
         RETURN v_numerror;
   END f_desgrpparam;

   /****************************************************************************
      FUNCTION F_DESCPARAM
      Obtener la descripción del grupo / parametro.
         param in pcodi    : código del grupo de parámetros o del parámetro
         param in ptipo    : 1 - grupo de parámetros
                             2 - parámetro
         param in pcidioma : código de idioma
         return            : la descripción del grupo / parámetro
   *****************************************************************************/
   -- BUG 5176 - 06/03/2009 - JRB - Se modifica
   FUNCTION f_descparam(pcodi IN VARCHAR2, ptipo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      c_blanc        NUMBER := 3;
      --numero de espacios a la izquierda segun el nivel
      v_cgrppar      codparam.cgrppar%TYPE;   --grupo de parámetros
      v_nivel        NUMBER;   --nivel del grupo de parametros al que pertenece
      v_texto        desparam.tparam%TYPE;
      v_cutili       codparam.cutili%TYPE;
      v_nerror       NUMBER;
   BEGIN
      --paso := 1;                                                     --Inicio
      RETURN 0;

      /*** Cuerpo de la función ***/
      IF ptipo = 2 THEN
         BEGIN
            SELECT cgrppar, cutili
              INTO v_cgrppar, v_cutili
              FROM codparam
             WHERE cparam = pcodi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN NULL;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_parametros.f_descparam', 1,
                           'when others pcodi =' || pcodi, SQLERRM);
               v_cgrppar := NULL;
         END;

         IF v_cgrppar IS NOT NULL THEN
            IF LENGTH(v_cgrppar) = 2 THEN
               v_nivel := 1;
            ELSE
               v_nivel := 2;
            END IF;
         ELSE
            v_nivel := 0;
         END IF;

         BEGIN
            SELECT tparam
              INTO v_texto
              FROM desparam
             WHERE cparam = pcodi
               AND cidioma = pcidioma;
         EXCEPTION
            WHEN OTHERS THEN
               v_texto := pcodi;
               v_texto := LPAD(v_texto, LENGTH(v_texto) +(c_blanc * v_nivel), ' ');
         END;

         v_texto := LPAD(v_texto, LENGTH(v_texto) +(c_blanc * v_nivel), ' ');
      ELSE
         v_nerror := f_desgrpparam(pcodi, v_cutili, pcidioma, v_texto, 5);

         IF v_nerror <> 0
            OR v_texto IS NULL THEN
            v_texto := pcodi;
         END IF;
      END IF;

      RETURN v_texto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_parametros.f_descparam', 1,
                     'when others pcodi =' || pcodi, SQLERRM);
         RETURN NULL;
   END f_descparam;

   /****************************************************************************
      FUNCTION F_DESCDETPARAM
      Obtener la descripción del valor del parametro
         param in pcparam   : codigo del parametro
         param in pcvalpar  : codigo del valor del parametro
         param in pcidioma  : idioma
         return             : descripción del valor del parametro
     Bug 8999 - 22/10/2009 - AMC
   *****************************************************************************/
   FUNCTION f_descdetparam(pcparam IN VARCHAR2, pcvalpar IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      vtvalpar       VARCHAR2(250);   -- Bug 18945/89297 - 26/09/2011
   BEGIN
      SELECT tvalpar
        INTO vtvalpar
        FROM detparam
       WHERE cparam = pcparam
         AND cidioma = pcidioma
         AND cvalpar = pcvalpar;

      RETURN vtvalpar;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_parametros.f_descdetparam', 1,
                     'pcparam=' || pcparam || ' pcvalpar=' || pcvalpar || ' pcidioma='
                     || pcidioma,
                     SQLERRM);
         RETURN NULL;
   END f_descdetparam;
   --
   --INI BUG 0050601 - 26/03/2019 - CASL - Se crea funcion que obtiene los correos
   --
   /****************************************************************************
      FUNCTION f_parproductomodmail_t
      Obtiene el valor Texto del parámetro de producto y modaliad.
         return            : valor Texto del parámetro
   *****************************************************************************/
   --
   FUNCTION f_parproductomodmail_t(psproduc    IN NUMBER  ,
                                   pcmodalidad IN VARCHAR2,
                                   pcparam     IN VARCHAR2)
      RETURN CLOB
   IS
      --
      vctipo    codparam.ctipo   %TYPE;
      vtdefecto codparam.tdefecto%TYPE;
      vcvalpar  parproductosmail.tvalpar%TYPE;
      vntraza   tab_error.ntraza %TYPE;
      --
      vparam VARCHAR2(100) := ' -psproduc: '    ||psproduc   ||
                              ' -pcmodalidad: ' ||pcmodalidad||
                              ' -pcparam: '     ||pcparam;
      --
   BEGIN
      --
      vntraza := 1;
      --
      SELECT ctipo, tdefecto
        INTO vctipo, vtdefecto
        FROM codparam
       WHERE cparam = pcparam;
      --
      vntraza := 2;
      --
      vparam := vparam || ' ctipo: ' || vctipo;
      --
      IF vctipo = 1
      THEN
         --
         BEGIN
            --
            SELECT tvalpar
              INTO vcvalpar
              FROM parproductosmail
             WHERE sproduc    = psproduc
               AND cmodalidad = NVL(pcmodalidad, 9999999999)
               AND cparpro    = pcparam;
            --
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               --
               BEGIN
                  --
                  SELECT tvalpar
                    INTO vcvalpar
                    FROM parproductosmail
                   WHERE sproduc    = 0
                     AND cmodalidad = NVL(pcmodalidad, 9999999999)
                     AND cparpro    = pcparam;
                  --
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     --
                     vntraza := 3;
                     --
                     vcvalpar := vtdefecto;
                     --
                  WHEN OTHERS
                  THEN
                     --
                     vcvalpar := NULL;
                     --
               END;
               --
            WHEN OTHERS
            THEN
               --
               vcvalpar := NULL;
               --
         END;
         --
      ELSE
         --
         p_tab_error(pferror   => f_sysdate,
                     pcusuari  => f_user,
                     ptobjeto  => 'PAC_PARAMETROS.f_parproductomodmail_t',
                     pntraza   => vntraza,
                     ptdescrip => vparam,
                     pterror   => 'Tipo de parámetro diferente al esperado');
         --
         vcvalpar := NULL;
         --
      END IF;
      --
      RETURN vcvalpar;
      --
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         --
         p_tab_error(pferror   => f_sysdate,
                     pcusuari  => f_user,
                     ptobjeto  => 'PAC_PARAMETROS.f_parproductomodmail_t',
                     pntraza   => vntraza,
                     ptdescrip => vparam,
                     pterror   => 'Parámetro no definido');
         --
         RETURN NULL;
         --
      WHEN OTHERS THEN
         --
         p_tab_error(pferror   => f_sysdate,
                     pcusuari  => f_user,
                     ptobjeto  => 'PAC_PARAMETROS.f_parproductomodmail_t',
                     pntraza   => vntraza,
                     ptdescrip => vparam || ' -SQLERRM: ' || SQLERRM,
                     pterror   => 'Error no controlado');
         --
         RETURN NULL;
         --
   END f_parproductomodmail_t;
   --
   --FIN BUG 0050601 - 26/03/2019 - CASL
   --
END pac_parametros;