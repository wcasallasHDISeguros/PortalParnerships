CREATE OR REPLACE FUNCTION AXIS.f_pcomisi (
    psseguro   IN     NUMBER,
    pcmodcom   IN     NUMBER,
    pfretenc   IN     DATE,
    ppcomisi      OUT NUMBER,
    ppretenc      OUT NUMBER,
    pcagente   IN     NUMBER DEFAULT NULL,
    pcramo     IN     NUMBER DEFAULT NULL,
    pcmodali   IN     NUMBER DEFAULT NULL,
    pctipseg   IN     NUMBER DEFAULT NULL,
    pccolect   IN     NUMBER DEFAULT NULL,
    pcactivi   IN     NUMBER DEFAULT NULL,
    pcgarant   IN     NUMBER DEFAULT NULL,
    pttabla    IN     VARCHAR2 DEFAULT NULL,
    pfuncion   IN     VARCHAR2 DEFAULT 'CAR',
    pfecha     IN     DATE DEFAULT f_sysdate, -- Bug 19612 - JRH - 07/11/2011 - 0019612: LCOL_T004: Formulación productos Vida Individual. Anualidad por parámetro.
    pnanuali   IN     NUMBER DEFAULT NULL,  -- Fi Bug 19612 - JRH - 07/11/2011
    pccomind   IN     NUMBER DEFAULT 0, -- Bug 20999 - APD - 26/01/2011 - 0.-Comision NO indirecta, 1.-Comision Indirecta
    pnriesgo   IN     NUMBER DEFAULT 1, -- Bug 19427 - 29/06/2012 - JRH - Puntos de reducción de comisión
    pnmovimi   IN     NUMBER DEFAULT NULL, --JLV bug 30055 - 06/02/2013, si ha habido un movimiento de cambio de comisión debemos de conocer el movimiento.
    psCaller   IN     VARCHAR2 DEFAULT NULL)
    -- Bug 30642/170640 - 24/03/2014 - AMC
    RETURN NUMBER
IS
    /******************************************************************************
       NOMBRE:     F_PCOMISI
       PROPÓSITO:  Función que encuentra la comisión y la retención dependiendo de los parametros de
                   entrada informados(por el producto o por el sseguro)

       REVISIONES:
       Ver        Fecha        Autor             Descripción
       ---------  ----------  ---------------  ------------------------------------
       2.0                                     Cambio para leer primero la posible comisión de la tabla COMISIONGAR
       3.0                                     Se añaden los parametros funcion y tabla para el calculo del primer recibo al tarifar,
                                               el parametro tabla indica a que tablas tiene que ir a buscar importes ('EST','SOL',NULLL),
                                               el parametro función indica si estoy tarifando (TAR) o en la cartera o previo de cartera (CAR)
       4.0        22/07/2008                   Buscar si están informadas las nuevas preguntas automáticas "Gastos Externos"
                                               si lo está esta será la nueva comisión ha aplicar.
       5.0        11/02/2011  JMP              BUG 0015137: Tener en cuenta la fecha de vigencia
       6.0        08/09/2011  ICV              0018852: LCOL_C001 - Incorporar nuevas alturas de comisión
       7.0        25/10/2011  JRH              0019873: GIP003-Comisión de Cobro
       8.0        26/10/2011  JMF              0019682: LCOL_T001: Adaptación Comisiones especiales por póliza
       9.0        08/11/2011  APD              0019316: CRT - Adaptar pantalla de comisiones
      10.0        19/12/2011  APD              0020384: LCOL_C001: Ajuste de comisiones para los cierres
      11.0        26/01/2012  APD              0020999: LCOL_C001: Comisiones Indirectas para ADN Bancaseguros
      12.0        26/06/2012  JRH              21947: Añadir nriesgo como parámetro
      13.0        20/11/2012  LCF               0024753: MDP - Trazas en las funciones de generación de recibos cuando se produce error
      14.0        11/03/2015  MAV              0035054-0200497:QT_0017346 - MAV - 11/03/2013-- MEJORAMIENTO DE PROCESOS
      15.0        07/05/2018  AF               BUG-0042691 AF Control de excepción poliza y comisión inexistente, tablas est. - GASE_0001 - RCM - 09/05/2018 - BUG-0043500 - RCM - 23/05/2018
      16.0        27/07/2018  JAE              44870: PUAC / Caratula / Suplemento Cambio de comisión de especial póliza a "No tiene".
      17.0        07/03/2019  NPR              	0049494: COMISIONES IAXIS CLAVES DIRECTAS
      18.0        07/06/2019  NACR              51461: TÉCNICO PUAC// COMISION // LA COMISION POR CERTIFICADO LA TOMA DEL PLAN Y NO POR CERTIFICADO
      19.0        09/03/2022  MAV               0073998: Consulta por Query - Informe coa Cedido Primas Recaudadas iAxis

    ******************************************************************************/
    num_error          NUMBER := 0;
    xctipcom           NUMBER := 0;
    xcagente           NUMBER := 0;
    xcramo             NUMBER := 0;
    xcmodali           NUMBER := 0;
    xctipseg           NUMBER := 0;
    xccolect           NUMBER := 0;
    xcactivi           NUMBER := 0;
    xcretenc           NUMBER := 0;
    xccomisi           NUMBER := 0;
    xnanuali           NUMBER;
    vctipretr          NUMBER;
    xgastoext          NUMBER;
    w_ccampanya        detcampanya.ccampanya%TYPE;
    w_nversio          detcampanya.nversio%TYPE;
    -- Bug 19873 - 25/10/2011 - JRH - 0019873: GIP003-Comisión de Cobro
    vcomisextra        NUMBER;
    -- Fi Bug 19873 - 25/10/2011
    --INI BUG 44870 - JAE - 27/07/2018 - Porcentaje de comisión heredado Plan/Riesgo
    vsseguro_0         NUMBER;
    v_plan             NUMBER;
    vpcomisi           NUMBER;
    v_resp_9283        pregunpolseg.crespue%TYPE;
    --FIN BUG 44870 - JAE - 27/07/2018
    --INI BUG 51461 - NACR - 07/06/2019
    vpcertifpuac       NUMBER;
    --FIN BUG 51461 - NACR - 07/06/2019
    -- 9  0024753: MDP - Trazas en las funciones de generación de recibos cuando se produce error
    vobj               VARCHAR2 (200) := 'f_pcomisi';
    vpas               NUMBER := 1;
    vpar               VARCHAR2 (500)
        := SUBSTR (
                  'psseguro  : '
               || psseguro
               || ' - pcmodcom  : '
               || pcmodcom
               || ' - pfretenc  : '
               || TO_CHAR (pfretenc, 'dd/mm/yyyy')
               || ' - pcagente  : '
               || pcagente
               || ' - pcramo  : '
               || pcramo
               || ' - pcmodali  : '
               || pcmodali
               || ' - pctipseg  : '
               || pctipseg
               || ' - pccolect  : '
               || pccolect
               || ' - pcactivi  : '
               || pcactivi
               || ' - pcgarant  : '
               || pcgarant
               || ' - pttabla  : '
               || pttabla
               || ' - pfuncion  : '
               || pfuncion
               || ' - pfecha  : '
               || TO_CHAR (pfecha, 'dd/mm/yyyy')
               || ' - pnanuali : '
               || pnanuali,
               1,
               500);
    --9. 0024753: MDP - Trazas en las funciones de generación de recibos cuando se produce error

    -- Bug 19169 - APD - 17/11/2011
    vpasexec           NUMBER (8) := 1;
    vparam             VARCHAR2 (2000)
        :=    'psseguro  : '
           || psseguro
           || ' - pcmodcom  : '
           || pcmodcom
           || ' - pfretenc  : '
           || TO_CHAR (pfretenc, 'dd/mm/yyyy')
           || ' - pcagente  : '
           || pcagente
           || ' - pcramo  : '
           || pcramo
           || ' - pcmodali  : '
           || pcmodali
           || ' - pctipseg  : '
           || pctipseg
           || ' - pccolect  : '
           || pccolect
           || ' - pcactivi  : '
           || pcactivi
           || ' - pcgarant  : '
           || pcgarant
           || ' - pttabla  : '
           || pttabla
           || ' - pfuncion  : '
           || pfuncion
           || ' - pfecha  : '
           || TO_CHAR (pfecha, 'dd/mm/yyyy')
           || ' - pnanuali : '
           || pnanuali;                          --JRH Anualidad por parámetro
    -- FIN Bug 19169 - APD - 17/11/2011
    -- Bug 19954 - APD - 31/10/2011 - Incluir sobrecomisión en el cálculo de la comisión
    xcsobrecomisi      NUMBER := 0;
    vpsobrecomisi      NUMBER;
    -- Bug 19427 - 29/06/2012 - JRH - Puntos de reducción de comisión
    vredcom            NUMBER := 0;
    itotcanvicomi      NUMBER;
    vsproduc           NUMBER;
    bCalculaComision   BOOLEAN := FALSE;
    --Inicio NPR 	0049494: COMISIONES IAXIS CLAVES DIRECTAS 07/03/2019
    lc                 NUMBER;
    ltiene_corretaje   NUMBER;
    --Fin NPR 	0049494: COMISIONES IAXIS CLAVES DIRECTAS 07/03/2019

    FUNCTION f_red_comision (ptablas    IN VARCHAR2,
                             psseguro   IN NUMBER,
                             pnriesgo   IN NUMBER,
                             pcgarant   IN NUMBER)
        RETURN NUMBER
    IS
        xgastoext   NUMBER;
    BEGIN
        IF ptablas = 'EST'
        THEN
            BEGIN
                SELECT crespue
                  INTO xgastoext
                  FROM estpregungaranseg
                 WHERE     sseguro = psseguro
                       AND cgarant = pcgarant
                       AND nriesgo = NVL (pnriesgo, 1)
                       AND cpregun = 2057                  --> Gastos Externos
                       AND nmovimi =
                           (SELECT MAX (nmovimi)
                              FROM estpregungaranseg
                             WHERE     sseguro = psseguro
                                   AND cgarant = pcgarant
                                   AND nriesgo = NVL (pnriesgo, 1)
                                   AND cpregun = 2057);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    BEGIN
                        SELECT crespue
                          INTO xgastoext
                          FROM estpregunseg
                         WHERE     sseguro = psseguro
                               AND cpregun = 2057          --> Gastos Externos
                               AND nriesgo = NVL (pnriesgo, 1)
                               AND nmovimi =
                                   (SELECT MAX (nmovimi)
                                      FROM estpregunseg
                                     WHERE     sseguro = psseguro
                                           AND nriesgo = NVL (pnriesgo, 1)
                                           AND cpregun = 2057);
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            BEGIN
                                SELECT crespue
                                  INTO xgastoext
                                  FROM estpregunpolseg
                                 WHERE     sseguro = psseguro
                                       AND cpregun = 2057  --> Gastos Externos
                                       AND nmovimi =
                                           (SELECT MAX (nmovimi)
                                              FROM estpregunpolseg
                                             WHERE sseguro = psseguro);
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    xgastoext := NULL;
                            END;
                    END;
            END;
        ELSE
            BEGIN
                SELECT crespue
                  INTO xgastoext
                  FROM pregungaranseg
                 WHERE     sseguro = psseguro
                       AND cgarant = pcgarant
                       AND nriesgo = NVL (pnriesgo, 1)
                       AND cpregun = 2057                  --> Gastos Externos
                       AND nmovimi =
                           (SELECT MAX (nmovimi)
                              FROM estpregungaranseg
                             WHERE     sseguro = psseguro
                                   AND cgarant = pcgarant
                                   AND nriesgo = NVL (pnriesgo, 1)
                                   AND cpregun = 2057);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    BEGIN
                        SELECT crespue
                          INTO xgastoext
                          FROM pregunseg
                         WHERE     sseguro = psseguro
                               AND cpregun = 2057          --> Gastos Externos
                               AND nriesgo = NVL (pnriesgo, 1)
                               AND nmovimi =
                                   (SELECT MAX (nmovimi)
                                      FROM estpregunseg
                                     WHERE     sseguro = psseguro
                                           AND nriesgo = NVL (pnriesgo, 1)
                                           AND cpregun = 2057);
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            BEGIN
                                SELECT crespue
                                  INTO xgastoext
                                  FROM pregunpolseg
                                 WHERE     sseguro = psseguro
                                       AND cpregun = 2057  --> Gastos Externos
                                       AND nmovimi =
                                           (SELECT MAX (nmovimi)
                                              FROM estpregunpolseg
                                             WHERE sseguro = psseguro);
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    xgastoext := NULL;
                            END;
                    END;
            END;
        END IF;

        RETURN NVL (xgastoext, 0);
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN 0;
    END f_red_comision;

    -- Fi Bug 19427 - 29/06/2012
    FUNCTION f_gastext (ptablas    IN VARCHAR2,
                        psseguro   IN NUMBER,
                        pnriesgo   IN NUMBER,
                        pcgarant   IN NUMBER)
        RETURN NUMBER
    IS
        xgastoext   NUMBER;
    BEGIN
        IF ptablas = 'EST'
        THEN
            BEGIN
                SELECT crespue
                  INTO xgastoext
                  FROM estpregungaranseg
                 WHERE     sseguro = psseguro
                       AND nriesgo = NVL (pnriesgo, 1)
                       AND cgarant = pcgarant
                       AND cpregun = 551                   --> Gastos Externos
                       AND nmovimi =
                           (SELECT MAX (nmovimi)
                              FROM estpregungaranseg
                             WHERE     sseguro = psseguro
                                   AND nriesgo = NVL (pnriesgo, 1)
                                   AND cgarant = pcgarant);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    BEGIN
                        SELECT crespue
                          INTO xgastoext
                          FROM estpregunseg
                         WHERE     sseguro = psseguro
                               AND nriesgo = NVL (pnriesgo, 1)
                               AND cpregun = 551           --> Gastos Externos
                               AND nmovimi =
                                   (SELECT MAX (nmovimi)
                                      FROM estpregunseg
                                     WHERE     sseguro = psseguro
                                           AND nriesgo = NVL (pnriesgo, 1));
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            BEGIN
                                SELECT crespue
                                  INTO xgastoext
                                  FROM estpregunpolseg
                                 WHERE     sseguro = psseguro
                                       AND cpregun = 551   --> Gastos Externos
                                       AND nmovimi =
                                           (SELECT MAX (nmovimi)
                                              FROM estpregunpolseg
                                             WHERE sseguro = psseguro);
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    xgastoext := NULL;
                            END;
                    END;
            END;
        ELSIF ptablas = 'SOL'
        THEN
            BEGIN
                SELECT crespue
                  INTO xgastoext
                  FROM solpregungaranseg
                 WHERE     ssolicit = psseguro
                       AND nriesgo = NVL (pnriesgo, 1)
                       AND cgarant = pcgarant
                       AND cpregun = 551;                  --> Gastos Externos
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    BEGIN
                        SELECT crespue
                          INTO xgastoext
                          FROM solpregunseg
                         WHERE     ssolicit = psseguro
                               AND nriesgo = NVL (pnriesgo, 1)
                               AND cpregun = 551           --> Gastos Externos
                               AND nmovimi =
                                   (SELECT MAX (nmovimi)
                                      FROM solpregunseg
                                     WHERE     ssolicit = psseguro
                                           AND nriesgo = NVL (pnriesgo, 1));
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            xgastoext := NULL;
                    END;
            END;
        ELSE
            BEGIN
                SELECT crespue
                  INTO xgastoext
                  FROM pregungaranseg
                 WHERE     sseguro = psseguro
                       AND nriesgo = NVL (pnriesgo, 1)
                       AND cgarant = pcgarant
                       AND cpregun = 551                   --> Gastos Externos
                       AND nmovimi =
                           (SELECT MAX (nmovimi)
                              FROM pregungaranseg
                             WHERE     sseguro = psseguro
                                   AND nriesgo = NVL (pnriesgo, 1)
                                   AND cgarant = pcgarant);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    BEGIN
                        SELECT crespue
                          INTO xgastoext
                          FROM pregunseg
                         WHERE     sseguro = psseguro
                               AND nriesgo = NVL (pnriesgo, 1)
                               AND cpregun = 551           --> Gastos Externos
                               AND nmovimi =
                                   (SELECT MAX (nmovimi)
                                      FROM pregunseg
                                     WHERE     sseguro = psseguro
                                           AND nriesgo = NVL (pnriesgo, 1));
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            BEGIN
                                SELECT crespue
                                  INTO xgastoext
                                  FROM pregunpolseg
                                 WHERE     sseguro = psseguro
                                       AND cpregun = 551   --> Gastos Externos
                                       AND nmovimi =
                                           (SELECT MAX (nmovimi)
                                              FROM pregunpolseg
                                             WHERE sseguro = psseguro);
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    xgastoext := NULL;
                            END;
                    END;
            END;
        END IF;

        RETURN xgastoext;
    END f_gastext;

    -- Bug 19873 - 25/10/2011 - JRH - 0019873: GIP003-Comisión de Cobro
    FUNCTION f_comision_extra (ptablas    IN VARCHAR2,
                               psseguro   IN NUMBER,
                               pcgarant   IN NUMBER)
        RETURN NUMBER
    IS
        vcomisextra   NUMBER;
    BEGIN
        IF ptablas = 'EST'
        THEN
            BEGIN
                SELECT crespue
                  INTO vcomisextra
                  FROM estpregungaranseg
                 WHERE     sseguro = psseguro
                       AND cgarant = pcgarant
                       AND cpregun = 9014                   --> Comisión extra
                       AND nmovimi =
                           (SELECT MAX (nmovimi)
                              FROM estpregungaranseg
                             WHERE sseguro = psseguro AND cgarant = pcgarant);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    BEGIN
                        SELECT crespue
                          INTO vcomisextra
                          FROM estpregunseg
                         WHERE     sseguro = psseguro
                               AND cpregun = 9014           --> Comisión extra
                               AND nmovimi = (SELECT MAX (nmovimi)
                                                FROM estpregunseg
                                               WHERE sseguro = psseguro);
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            BEGIN
                                SELECT crespue
                                  INTO vcomisextra
                                  FROM estpregunpolseg
                                 WHERE     sseguro = psseguro
                                       AND cpregun = 9014   --> Comisión extra
                                       AND nmovimi =
                                           (SELECT MAX (nmovimi)
                                              FROM estpregunpolseg
                                             WHERE sseguro = psseguro);
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    vcomisextra := NULL;
                            END;
                    END;
            END;
        ELSIF ptablas = 'SOL'
        THEN
            BEGIN
                SELECT crespue
                  INTO vcomisextra
                  FROM solpregungaranseg
                 WHERE     ssolicit = psseguro
                       AND cgarant = pcgarant
                       AND cpregun = 9014;                  --> Comisión extra
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    BEGIN
                        SELECT crespue
                          INTO vcomisextra
                          FROM solpregunseg
                         WHERE     ssolicit = psseguro
                               AND cpregun = 9014           --> Comisión extra
                               AND nmovimi = (SELECT MAX (nmovimi)
                                                FROM solpregunseg
                                               WHERE ssolicit = psseguro);
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            vcomisextra := NULL;
                    END;
            END;
        ELSE
            BEGIN
                SELECT crespue
                  INTO vcomisextra
                  FROM pregungaranseg
                 WHERE     sseguro = psseguro
                       AND cgarant = pcgarant
                       AND cpregun = 9014                   --> Comisión extra
                       AND nmovimi =
                           (SELECT MAX (nmovimi)
                              FROM pregungaranseg
                             WHERE sseguro = psseguro AND cgarant = pcgarant);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    BEGIN
                        SELECT crespue
                          INTO vcomisextra
                          FROM pregunseg
                         WHERE     sseguro = psseguro
                               AND cpregun = 9014           --> Comisión extra
                               AND nmovimi = (SELECT MAX (nmovimi)
                                                FROM pregunseg
                                               WHERE sseguro = psseguro);
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            BEGIN
                                SELECT crespue
                                  INTO vcomisextra
                                  FROM pregunpolseg
                                 WHERE     sseguro = psseguro
                                       AND cpregun = 9014   --> Comisión extra
                                       AND nmovimi =
                                           (SELECT MAX (nmovimi)
                                              FROM pregunpolseg
                                             WHERE sseguro = psseguro);
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    vcomisextra := NULL;
                            END;
                    END;
            END;
        END IF;

        RETURN NVL (vcomisextra, 0);
    END f_comision_extra;

    -- Fi Bug 19873 - 25/10/2011 - JRH

    -- ini Bug 0019682 - 26/10/2011 - JMF
    /*********************************************
    CALCULO COMISION HABITUAL
    *********************************************/
    FUNCTION f_local_comhabitual
        RETURN NUMBER
    IS
        -- Bug 18829 - 03/11/2011 - APD - Obtener el porcentaje de comisión en función del Canal, Medio y/o Segmento
        FUNCTION f_comision_nivel
            RETURN NUMBER
        IS
            v_numerr           NUMBER;
            v_preg_9006        pregunpolseg.cpregun%TYPE := 9006; -- Pregunta 'Canal'
            v_preg_9007        pregunpolseg.cpregun%TYPE := 9007; -- Pregunta 'Medio'
            v_preg_9008        pregunpolseg.cpregun%TYPE := 9008; -- Pregunta 'Segmento'
            v_resp_preg_9006   pregunpolseg.crespue%TYPE;  -- Pregunta 'Canal'
            v_resp_preg_9007   pregunpolseg.crespue%TYPE;  -- Pregunta 'Medio'
            v_resp_preg_9008   pregunpolseg.crespue%TYPE; -- Pregunta 'Segmento'
        BEGIN
            ppcomisi := NULL;
            -- Si no estan contestadas las preguntas (esto puede pasar nada más entrar en la
            -- contratacion (axisctr001), al seleccionar el producto) no se quiere que de error,
            -- sino que busque la comision en comisiongar, comisionacti o comisionprod
            -- BUG 0035054-0200497:QT_0017346 - MAV - 11/03/2013
            --v_numerr := pac_preguntas.f_get_pregunpolseg(psseguro, v_preg_9006,
            --                                             NVL(pttabla, 'REA'), v_resp_preg_9006);
            -- se asigna directamente el codigo de error al no existir respuesta a la pregunta 9007
            v_numerr := 120135;

            IF v_numerr <> 0
            THEN
                --RETURN 9001882;   -- No se ha podido recuperar la información de las Respuestas.
                RETURN 0;
            END IF;

            v_numerr :=
                pac_preguntas.f_get_pregunpolseg (psseguro,
                                                  v_preg_9007,
                                                  NVL (pttabla, 'REA'),
                                                  v_resp_preg_9007);

            IF v_numerr <> 0
            THEN
                --RETURN 9001882;   -- No se ha podido recuperar la información de las Respuestas.
                RETURN 0;
            END IF;

            v_numerr :=
                pac_preguntas.f_get_pregunpolseg (psseguro,
                                                  v_preg_9008,
                                                  NVL (pttabla, 'REA'),
                                                  v_resp_preg_9008);

            IF v_numerr <> 0
            THEN
                --RETURN 9001882;   -- No se ha podido recuperar la información de las Respuestas.
                RETURN 0;
            END IF;

            vpar := 55;

            -- Si hay comision a nivel de canal, medio y/segmento, entonces devolver el valor
            -- del porcentaje de la comision
            --Si la sobrecomision está vigente, se devuelve el valor del porcentaje de la sobrecomision
            BEGIN
                SELECT pcomisi
                  INTO ppcomisi
                  FROM comisiongar_nivel cg
                 WHERE     cg.cramo = xcramo
                       AND cg.cmodali = xcmodali
                       AND cg.ctipseg = xctipseg
                       AND cg.ccolect = xccolect
                       AND cg.cactivi = xcactivi
                       AND cg.cgarant = pcgarant
                       AND cg.ccomisi = xccomisi
                       AND cg.cmodcom = pcmodcom
                       --Bug.: 18852 - 08/09/2011 - ICV
                       AND NVL (xnanuali, 1) BETWEEN cg.ninialt
                                                 AND cg.nfinalt
                       AND (NVL (cg.ccanal, v_resp_preg_9006) =
                            v_resp_preg_9006)
                       AND (NVL (cg.cmedio, v_resp_preg_9007) =
                            v_resp_preg_9007)
                       AND (NVL (cg.csegmento, v_resp_preg_9008) =
                            v_resp_preg_9008)
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM comisiongar_nivel cg2
                                 WHERE     cg2.cramo = xcramo
                                       AND cg2.cmodali = xcmodali
                                       AND cg2.ctipseg = xctipseg
                                       AND cg2.ccolect = xccolect
                                       AND cg2.cactivi = xcactivi
                                       AND cg2.cgarant = pcgarant
                                       AND cg2.ccomisi = xccomisi
                                       AND cg2.cmodcom = pcmodcom
                                       --Bug.: 18852 - 08/09/2011 - ICV
                                       AND NVL (xnanuali, 1) BETWEEN cg2.ninialt
                                                                 AND cg2.nfinalt
                                       AND (NVL (cg2.ccanal,
                                                 v_resp_preg_9006) =
                                            v_resp_preg_9006)
                                       AND (NVL (cg2.cmedio,
                                                 v_resp_preg_9007) =
                                            v_resp_preg_9007)
                                       AND (NVL (cg2.csegmento,
                                                 v_resp_preg_9008) =
                                            v_resp_preg_9008)
                                       AND (  DECODE (cg2.ccanal, NULL, 0, 4)
                                            + DECODE (cg2.cmedio, NULL, 0, 2)
                                            + DECODE (cg2.csegmento,
                                                      NULL, 0,
                                                      1)) >
                                           (  DECODE (cg.ccanal, NULL, 0, 4)
                                            + DECODE (cg.cmedio, NULL, 0, 2)
                                            + DECODE (cg.csegmento,
                                                      NULL, 0,
                                                      1)));
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    BEGIN
                        SELECT pcomisi
                          INTO ppcomisi
                          FROM comisionacti_nivel ca
                         WHERE     ca.cramo = xcramo
                               AND ca.cmodali = xcmodali
                               AND ca.ccolect = xccolect
                               AND ca.ctipseg = xctipseg
                               AND ca.cmodcom = pcmodcom
                               AND ca.ccomisi = xccomisi
                               AND ca.cactivi = xcactivi
                               --Bug.: 18852 - 08/09/2011 - ICV
                               AND NVL (xnanuali, 1) BETWEEN ca.ninialt
                                                         AND ca.nfinalt
                               AND (NVL (ca.ccanal, v_resp_preg_9006) =
                                    v_resp_preg_9006)
                               AND (NVL (ca.cmedio, v_resp_preg_9007) =
                                    v_resp_preg_9007)
                               AND (NVL (ca.csegmento, v_resp_preg_9008) =
                                    v_resp_preg_9008)
                               AND NOT EXISTS
                                       (SELECT 1
                                          FROM comisionacti_nivel ca2
                                         WHERE     ca2.cramo = xcramo
                                               AND ca2.cmodali = xcmodali
                                               AND ca2.ccolect = xccolect
                                               AND ca2.ctipseg = xctipseg
                                               AND ca2.cmodcom = pcmodcom
                                               AND ca2.ccomisi = xccomisi
                                               AND ca2.cactivi = xcactivi
                                               --Bug.: 18852 - 08/09/2011 - ICV
                                               AND NVL (xnanuali, 1) BETWEEN ca2.ninialt
                                                                         AND ca2.nfinalt
                                               AND (NVL (ca2.ccanal,
                                                         v_resp_preg_9006) =
                                                    v_resp_preg_9006)
                                               AND (NVL (ca2.cmedio,
                                                         v_resp_preg_9007) =
                                                    v_resp_preg_9007)
                                               AND (NVL (ca2.csegmento,
                                                         v_resp_preg_9008) =
                                                    v_resp_preg_9008)
                                               AND (  DECODE (ca2.ccanal,
                                                              NULL, 0,
                                                              4)
                                                    + DECODE (ca2.cmedio,
                                                              NULL, 0,
                                                              2)
                                                    + DECODE (ca2.csegmento,
                                                              NULL, 0,
                                                              1)) >
                                                   (  DECODE (ca.ccanal,
                                                              NULL, 0,
                                                              4)
                                                    + DECODE (ca.cmedio,
                                                              NULL, 0,
                                                              2)
                                                    + DECODE (ca.csegmento,
                                                              NULL, 0,
                                                              1)));
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            BEGIN
                                SELECT pcomisi
                                  INTO ppcomisi
                                  FROM comisionprod_nivel cp
                                 WHERE     cp.cramo = xcramo
                                       AND cp.cmodali = xcmodali
                                       AND cp.ctipseg = xctipseg
                                       AND cp.ccolect = xccolect
                                       AND cp.cmodcom = pcmodcom
                                       AND cp.ccomisi = xccomisi
                                       --Bug.: 18852 - 08/09/2011 - ICV
                                       AND NVL (xnanuali, 1) BETWEEN cp.ninialt
                                                                 AND cp.nfinalt
                                       AND (NVL (cp.ccanal, v_resp_preg_9006) =
                                            v_resp_preg_9006)
                                       AND (NVL (cp.cmedio, v_resp_preg_9007) =
                                            v_resp_preg_9007)
                                       AND (NVL (cp.csegmento,
                                                 v_resp_preg_9008) =
                                            v_resp_preg_9008)
                                       AND NOT EXISTS
                                               (SELECT 1
                                                  FROM comisionprod_nivel cp2
                                                 WHERE     cp2.cramo = xcramo
                                                       AND cp2.cmodali =
                                                           xcmodali
                                                       AND cp2.ctipseg =
                                                           xctipseg
                                                       AND cp2.ccolect =
                                                           xccolect
                                                       AND cp2.cmodcom =
                                                           pcmodcom
                                                       AND cp2.ccomisi =
                                                           xccomisi
                                                       --Bug.: 18852 - 08/09/2011 - ICV
                                                       AND NVL (xnanuali, 1) BETWEEN cp2.ninialt
                                                                                 AND cp2.nfinalt
                                                       AND (NVL (
                                                                cp2.ccanal,
                                                                v_resp_preg_9006) =
                                                            v_resp_preg_9006)
                                                       AND (NVL (
                                                                cp2.cmedio,
                                                                v_resp_preg_9007) =
                                                            v_resp_preg_9007)
                                                       AND (NVL (
                                                                cp2.csegmento,
                                                                v_resp_preg_9008) =
                                                            v_resp_preg_9008)
                                                       AND (  DECODE (
                                                                  cp2.ccanal,
                                                                  NULL, 0,
                                                                  4)
                                                            + DECODE (
                                                                  cp2.cmedio,
                                                                  NULL, 0,
                                                                  2)
                                                            + DECODE (
                                                                  cp2.csegmento,
                                                                  NULL, 0,
                                                                  1)) >
                                                           (  DECODE (
                                                                  cp.ccanal,
                                                                  NULL, 0,
                                                                  4)
                                                            + DECODE (
                                                                  cp.cmedio,
                                                                  NULL, 0,
                                                                  2)
                                                            + DECODE (
                                                                  cp.csegmento,
                                                                  NULL, 0,
                                                                  1)));
                            EXCEPTION
                                WHEN NO_DATA_FOUND
                                THEN
                                    --RETURN 100933;   -- Comissió inexistent
                                    -- Bug 18829 - APD - 03/11/2011 - en el caso de que no se encuentre
                                    -- la parametrizacion en la tabla comisionprod_nivel se debe devolver
                                    -- 0 y no un error para que se calcule la comision a nivel de garantia,
                                    -- actividad o producto
                                    RETURN 0;
                                WHEN OTHERS
                                THEN
                                    RETURN 103216;
                            --Error al llegir la taula COMISIONPROD
                            END;
                        WHEN OTHERS
                        THEN
                            p_tab_error (
                                f_sysdate,
                                f_user,
                                vobj,
                                vpas,
                                vpar,
                                   'SQLCODE = '
                                || SQLCODE
                                || ' - '
                                || 'SQLERRM = '
                                || SQLERRM
                                || 'error = '
                                || 103628);
                            RETURN 103628; -- Error al llegir la taula COMISIONACTI
                    END;
                WHEN OTHERS
                THEN
                    p_tab_error (
                        f_sysdate,
                        f_user,
                        vobj,
                        vpas,
                        vpar,
                           'SQLCODE = '
                        || SQLCODE
                        || ' - '
                        || 'SQLERRM = '
                        || SQLERRM
                        || 'error = '
                        || 110824);
                    RETURN 110824;       -- Error leyendo la tabla COMISIONGAR
            END;

            RETURN 0;
        END f_comision_nivel;
    -- Fi Bug 18829 - 03/11/2011 - APD
    BEGIN
        BEGIN
            --
            -- Si hay campañas recuperamos el % de la campaña. Si no existe, damos error
            --
            SELECT ccampanya, NVL (nversio, 0)
              INTO w_ccampanya, w_nversio
              FROM detcampanya
             WHERE     cactivi = xcactivi
                   AND cgarant = pcgarant
                   AND sproduc IN
                           (SELECT sproduc
                              FROM productos
                             WHERE     cramo = xcramo
                                   AND cmodali = xcmodali
                                   AND ctipseg = xctipseg
                                   AND ccolect = xccolect)
                   AND NVL (finicam, f_sysdate - 1) <= f_sysdate
                   AND f_sysdate <= NVL (ffincam, f_sysdate + 1);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                w_nversio := -1;
            WHEN OTHERS
            THEN
                w_nversio := -1;
        END;

        --
        -- Si hay una campaña informada, buscamos su comision
        --
        IF w_nversio >= 0
        THEN
            BEGIN
                SELECT pcomisi
                  INTO ppcomisi
                  FROM comisioncamp
                 WHERE     cramo = xcramo
                       AND cmodali = xcmodali
                       AND ctipseg = xctipseg
                       AND ccolect = xccolect
                       AND cactivi = xcactivi
                       AND cgarant = pcgarant
                       AND ccomisi = xccomisi
                       AND cmodcom = pcmodcom
                       AND ccampanya = w_ccampanya
                       AND nversion = w_nversio;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    RETURN 110986;
                WHEN OTHERS
                THEN
                    p_tab_error (
                        f_sysdate,
                        f_user,
                        vobj,
                        vpas,
                        vpar,
                           'SQLCODE = '
                        || SQLCODE
                        || ' - '
                        || 'SQLERRM = '
                        || SQLERRM
                        || 'error = '
                        || 110986);
                    RETURN 110986;
            END;
        ELSE
            -- Bug 18829 - APD - 03/11/2011 - Obtener el porcentaje de comisión en función del Canal, Medio y/o Segmento
            ppcomisi := NULL;

            IF NVL (
                   pac_parametros.f_parempresa_n (
                       pac_md_common.f_get_cxtempresa (),
                       'MODO_CALC_COMISION'),
                   0) =
               1
            THEN
                IF pccomind = 0
                THEN   -- Bug 20999 - APD - 26/01/2012 - comision NO indirecta
                    num_error := f_comision_nivel;

                    IF num_error <> 0
                    THEN
                        RETURN num_error;
                    END IF;
                END IF;                    -- fin Bug 20999 - APD - 26/01/2012
            END IF;

            -- Fin Bug 18829 - APD - 03/11/2011
            -- Bug 18829 - APD - 03/11/2011 - se añade la condicion IF, ya que si se ha obtenido
            -- la comision en funcion del Canal, Medio y/o Segmento ya no se debe calcular a
            -- nivel de garantia, actividad o producto
            IF ppcomisi IS NULL
            THEN
                BEGIN
                    SELECT pcomisi
                      INTO ppcomisi
                      FROM comisiongar cg
                     WHERE     cramo = xcramo
                           AND cmodali = xcmodali
                           AND ctipseg = xctipseg
                           AND ccolect = xccolect
                           AND cactivi = xcactivi
                           AND cgarant = pcgarant
                           AND ccomisi = xccomisi
                           AND cmodcom = pcmodcom
                           --Bug.: 18852 - 08/09/2011 - ICV
                           AND NVL (xnanuali, 1) BETWEEN ninialt AND nfinalt
                           -- Bug 19316 - APD - 08/11/2011 - se modifica la subselect de comisionvig
                           AND finivig =
                               (SELECT finivig
                                  FROM comisionvig
                                 WHERE     ccomisi = xccomisi
                                       AND cestado = 2
                                       AND TRUNC (pfecha) BETWEEN finivig
                                                              AND NVL (
                                                                      ffinvig,
                                                                      TRUNC (
                                                                          pfecha)));
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        BEGIN
                            SELECT pcomisi
                              INTO ppcomisi
                              FROM comisionacti ca
                             WHERE     cramo = xcramo
                                   AND cmodali = xcmodali
                                   AND ccolect = xccolect
                                   AND ctipseg = xctipseg
                                   AND cmodcom = pcmodcom
                                   AND ccomisi = xccomisi
                                   AND cactivi = xcactivi
                                   --Bug.: 18852 - 08/09/2011 - ICV
                                   AND NVL (xnanuali, 1) BETWEEN ninialt
                                                             AND nfinalt
                                   -- Bug 19316 - APD - 08/11/2011 - se modifica la subselect de comisionvig
                                   AND finivig =
                                       (SELECT finivig
                                          FROM comisionvig
                                         WHERE     ccomisi = xccomisi
                                               AND cestado = 2
                                               AND TRUNC (pfecha) BETWEEN finivig
                                                                      AND NVL (
                                                                              ffinvig,
                                                                              TRUNC (
                                                                                  pfecha)));
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN
                                BEGIN
                                    SELECT pcomisi
                                      INTO ppcomisi
                                      FROM comisionprod cp
                                     WHERE     cramo = xcramo
                                           AND cmodali = xcmodali
                                           AND ctipseg = xctipseg
                                           AND ccolect = xccolect
                                           AND cmodcom = pcmodcom
                                           AND ccomisi = xccomisi
                                           --Bug.: 18852 - 08/09/2011 - ICV
                                           AND NVL (xnanuali, 1) BETWEEN ninialt
                                                                     AND nfinalt
                                           -- Bug 19316 - APD - 08/11/2011 - se modifica la subselect de comisionvig
                                           AND finivig =
                                               (SELECT finivig
                                                  FROM comisionvig
                                                 WHERE     ccomisi = xccomisi
                                                       AND cestado = 2
                                                       AND TRUNC (pfecha) BETWEEN finivig
                                                                              AND NVL (
                                                                                      ffinvig,
                                                                                      TRUNC (
                                                                                          pfecha)));
                                EXCEPTION
                                    WHEN NO_DATA_FOUND
                                    THEN
                                        RETURN 100933;  -- Comissió inexistent
                                    WHEN OTHERS
                                    THEN
                                        p_tab_error (
                                            f_sysdate,
                                            f_user,
                                            vobj,
                                            vpas,
                                            vpar,
                                               'SQLCODE = '
                                            || SQLCODE
                                            || ' - '
                                            || 'SQLERRM = '
                                            || SQLERRM
                                            || 'error = '
                                            || 103216);
                                        RETURN 103216;
                                --Error al llegir la taula COMISIONPROD
                                END;
                            WHEN OTHERS
                            THEN
                                p_tab_error (
                                    f_sysdate,
                                    f_user,
                                    vobj,
                                    vpas,
                                    vpar,
                                       'SQLCODE = '
                                    || SQLCODE
                                    || ' - '
                                    || 'SQLERRM = '
                                    || SQLERRM
                                    || 'error = '
                                    || 103628);
                                RETURN 103628; -- Error al llegir la taula COMISIONACTI
                        END;
                    WHEN OTHERS
                    THEN
                        p_tab_error (
                            f_sysdate,
                            f_user,
                            vobj,
                            vpas,
                            vpar,
                               'SQLCODE = '
                            || SQLCODE
                            || ' - '
                            || 'SQLERRM = '
                            || SQLERRM
                            || 'error = '
                            || 110824);
                        RETURN 110824;   -- Error leyendo la tabla COMISIONGAR
                END;
            END IF;                        -- Fin Bug 18829 - APD - 03/11/2011
        END IF;

        RETURN 0;
    END f_local_comhabitual;

    -- fin Bug 0019682 - 26/10/2011 - JMF

    -- Bug 19954 - 31/10/2011 - APD - Incluir sobrecomisión en el cálculo de la comisión
    FUNCTION f_sobrecomision
        RETURN NUMBER
    IS
        vfinivig   DATE;
        vffinvig   DATE;
    BEGIN
        xcsobrecomisi := NULL;

        -- Bug 19954 - APD - 17/11/2011 - primero se debe buscar el cuadro de sobrecomision
        -- de la tabla comisionvig_agente, sino no encuentra datos de la tabla agentes
        BEGIN
            SELECT ca.ccomisi
              INTO xcsobrecomisi
              FROM comisionvig_agente ca, codicomisio c
             WHERE     ca.ccomisi = c.ccomisi
                   AND c.ctipo = 2                             --sobrecomision
                   AND ca.cagente = xcagente
                   AND TRUNC (pfecha) BETWEEN finivig
                                          AND NVL (ffinvig, TRUNC (pfecha))
                   AND ca.ccomind = 0; -- Bug 20999 - APD - 26/01/2012 - comision NO indirecta
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                xcsobrecomisi := NULL;
            WHEN OTHERS
            THEN
                num_error := 100504;                       -- Agent inexistent
                p_tab_error (
                    f_sysdate,
                    f_user,
                    vobj,
                    vpas,
                    vpar,
                       'SQLCODE = '
                    || SQLCODE
                    || ' - '
                    || 'SQLERRM = '
                    || SQLERRM
                    || 'error = '
                    || 100504);
                RETURN num_error;
        END;

        -- fin Bug 19954 - APD - 17/11/2011
        IF xcsobrecomisi IS NOT NULL
        THEN
            BEGIN
                SELECT pcomisi
                  INTO vpsobrecomisi
                  FROM comisiongar cg
                 WHERE     cramo = xcramo
                       AND cmodali = xcmodali
                       AND ctipseg = xctipseg
                       AND ccolect = xccolect
                       AND cactivi = xcactivi
                       AND cgarant = pcgarant
                       AND ccomisi = xcsobrecomisi
                       AND cmodcom = pcmodcom
                       --Bug.: 18852 - 08/09/2011 - ICV
                       AND NVL (xnanuali, 1) BETWEEN ninialt AND nfinalt
                       -- Bug 19316 - APD - 08/11/2011 - se modifica la subselect de comisionvig
                       AND finivig =
                           (SELECT finivig
                              FROM comisionvig
                             WHERE     ccomisi = xcsobrecomisi
                                   AND cestado = 2
                                   AND TRUNC (pfecha) BETWEEN finivig
                                                          AND NVL (
                                                                  ffinvig,
                                                                  TRUNC (
                                                                      pfecha)));
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    BEGIN
                        SELECT pcomisi
                          INTO vpsobrecomisi
                          FROM comisionacti ca
                         WHERE     cramo = xcramo
                               AND cmodali = xcmodali
                               AND ccolect = xccolect
                               AND ctipseg = xctipseg
                               AND cmodcom = pcmodcom
                               AND ccomisi = xcsobrecomisi
                               AND cactivi = xcactivi
                               --Bug.: 18852 - 08/09/2011 - ICV
                               AND NVL (xnanuali, 1) BETWEEN ninialt
                                                         AND nfinalt
                               -- Bug 19316 - APD - 08/11/2011 - se modifica la subselect de comisionvig
                               AND finivig =
                                   (SELECT finivig
                                      FROM comisionvig
                                     WHERE     ccomisi = xcsobrecomisi
                                           AND cestado = 2
                                           AND TRUNC (pfecha) BETWEEN finivig
                                                                  AND NVL (
                                                                          ffinvig,
                                                                          TRUNC (
                                                                              pfecha)));
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            BEGIN
                                SELECT pcomisi
                                  INTO vpsobrecomisi
                                  FROM comisionprod cp
                                 WHERE     cramo = xcramo
                                       AND cmodali = xcmodali
                                       AND ctipseg = xctipseg
                                       AND ccolect = xccolect
                                       AND cmodcom = pcmodcom
                                       AND ccomisi = xcsobrecomisi
                                       --Bug.: 18852 - 08/09/2011 - ICV
                                       AND NVL (xnanuali, 1) BETWEEN ninialt
                                                                 AND nfinalt
                                       -- Bug 19316 - APD - 08/11/2011 - se modifica la subselect de comisionvig
                                       AND finivig =
                                           (SELECT finivig
                                              FROM comisionvig
                                             WHERE     ccomisi =
                                                       xcsobrecomisi
                                                   AND cestado = 2
                                                   AND TRUNC (pfecha) BETWEEN finivig
                                                                          AND NVL (
                                                                                  ffinvig,
                                                                                  TRUNC (
                                                                                      pfecha)));
                            EXCEPTION
                                WHEN NO_DATA_FOUND
                                THEN
                                    --RETURN 100933;   -- Comissió inexistent
                                    RETURN 0; --No ha de devolver error, ha de devolver que no tiene sobrecomsión
                                WHEN OTHERS
                                THEN
                                    p_tab_error (
                                        f_sysdate,
                                        f_user,
                                        vobj,
                                        vpas,
                                        vpar,
                                           'SQLCODE = '
                                        || SQLCODE
                                        || ' - '
                                        || 'SQLERRM = '
                                        || SQLERRM
                                        || 'error = '
                                        || 103216);
                                    RETURN 103216;
                            --Error al llegir la taula COMISIONPROD
                            END;
                        WHEN OTHERS
                        THEN
                            p_tab_error (
                                f_sysdate,
                                f_user,
                                vobj,
                                vpas,
                                vpar,
                                   'SQLCODE = '
                                || SQLCODE
                                || ' - '
                                || 'SQLERRM = '
                                || SQLERRM
                                || 'error = '
                                || 103628);
                            RETURN 103628; -- Error al llegir la taula COMISIONACTI
                    END;
                WHEN OTHERS
                THEN
                    p_tab_error (
                        f_sysdate,
                        f_user,
                        vobj,
                        vpas,
                        vpar,
                           'SQLCODE = '
                        || SQLCODE
                        || ' - '
                        || 'SQLERRM = '
                        || SQLERRM
                        || 'error = '
                        || 110824);
                    RETURN 110824;       -- Error leyendo la tabla COMISIONGAR
            END;
        END IF;

        RETURN 0;
    END f_sobrecomision;
-- Fi Bug 19949 - 31/10/2011 - APD
BEGIN
    IF pcmodcom IS NULL OR pfretenc IS NULL
    THEN
        num_error := 100900;
        RETURN num_error;
    -- se han entrado valores nulos en parámetros OBLIGATORIOS
    END IF;

    vpasexec := 2;
    vpar := 85;

    --INI BUG 44870 - JAE - 27/07/2018 - Porcentaje de comisión heredado Plan/Riesgo
    BEGIN
        --
        SELECT sproduc, sseguro
          INTO vsproduc, vsseguro_0
          FROM seguros
         WHERE     ncertif = 0
               AND npoliza = (SELECT DISTINCT npoliza
                                FROM seguros
                               WHERE sseguro = psseguro);
    --
    EXCEPTION
        WHEN OTHERS
        THEN
            vsproduc := NULL;
            vsseguro_0 := NULL;
    --
    END;
    --
    num_error := pac_productos.f_get_herencia_col (vsproduc, 13, xctipcom);
    IF num_error = 0
    THEN
        --
        IF NVL (xctipcom, 0) = 2            -- Hereda comision del plan/riesgo
        THEN
            --
            BEGIN
                --
                --Selecciona el plan
                -- INI MAV 09/03/2022 - QT73998
                /*
                SELECT crespue
                  INTO v_plan
                  FROM pregunpolseg p
                 WHERE     sseguro = psseguro
                       AND cpregun = 4089
                       AND nmovimi =
                           (SELECT MAX (nmovimi)
                              FROM pregunpolseg pg
                             WHERE     p.sseguro = pg.sseguro
                                   AND p.cpregun = pg.cpregun);
                */
                SELECT crespue
                  INTO v_plan
                  FROM pregunpolseg p
                 WHERE     sseguro = psseguro
                       AND cpregun = 4089
                       AND nmovimi =
                           (SELECT  MAX (nmovimi)
                              FROM pregunpolseg pg
                             WHERE     pg.sseguro = psseguro
                                   AND pg.cpregun = 4089);
                -- FIN MAV 09/03/2022 - QT73998
                --
                --Tipo comisión Plan/Riesgo
                -- INI MAV 09/03/2022 - QT73998
                /*
                SELECT crespue
                  INTO v_resp_9283
                  FROM pregunseg p
                 WHERE     sseguro = vsseguro_0
                       AND nriesgo = v_plan
                       AND cpregun = 9283
                       AND nmovimi =
                           (SELECT MAX (nmovimi)
                              FROM pregunseg pg
                             WHERE     p.sseguro = pg.sseguro
                                   AND p.cpregun = pg.cpregun);
                */
                SELECT crespue
                  INTO v_resp_9283
                  FROM pregunseg p
                 WHERE     sseguro = vsseguro_0
                       AND nriesgo = v_plan
                       AND cpregun = 9283
                       AND nmovimi =
                           (SELECT MAX (nmovimi)
                              FROM pregunseg pg
                             WHERE vsseguro_0 = pg.sseguro
                             AND   pg.nriesgo = v_plan
                               AND 9283 = pg.cpregun);
                -- FIN MAV 09/03/2022 - QT73998
                --
                IF NVL (v_resp_9283, 0) != 99
                THEN
                    --
                    --Obtiene el porcentaje Plan/Riesgo
                    SELECT b.tvalor
                      INTO vpcomisi
                      FROM pregunsegtab  a
                           INNER JOIN pregunsegtab b
                               ON     a.sseguro = b.sseguro
                                  AND a.nriesgo = b.nriesgo
                                  AND a.cpregun = b.cpregun
                                  AND a.nmovimi = b.nmovimi
                                  AND a.nlinea = b.nlinea
                     WHERE     a.ccolumna = 1
                           AND b.ccolumna = 2
                           AND a.sseguro = vsseguro_0
                           AND a.nriesgo = v_plan
                           AND a.cpregun = 9284
                           AND a.nmovimi =
                               (SELECT MAX (nmovimi)
                                  FROM pregunsegtab
                                 WHERE     sseguro = vsseguro_0
                                       AND nriesgo = v_plan
                                       AND cpregun = 9284
                                       AND ccolumna = 1)
                           AND a.nvalor = pcmodcom;
                          --INI BUG 51461 - NACR - 07/06/2019
                            IF pac_mdpar_productos.f_get_parproducto('VAL_FEC_PRO_PUAC', vsproduc) = 1 THEN
                              SELECT ncertif
                              INTO vpcertifpuac
                              FROM seguros
                              WHERE sseguro = psseguro;
                              IF vpcertifpuac > 0 THEN
                                SELECT PCOMISI
                                INTO vpcomisi
                                FROM comisionsegu
                                WHERE SSEGURO = psseguro
                                AND NMOVIMI  IN
                                  (SELECT MAX (nmovimi) FROM comisionsegu WHERE sseguro = psseguro)
                                AND CMODCOM IN
                                  (SELECT MAX (CMODCOM) FROM comisionsegu WHERE sseguro = psseguro);
                              END IF;
                            END IF;
                            --FIN BUG 51461 - NACR - 07/06/2019
                    --
                    ppcomisi := vpcomisi;
                --
                ELSE
                    --
                    ppcomisi := 0;                              --Sin comisión
                --
                END IF;
                --
                RETURN 0;
            --
            EXCEPTION
                WHEN OTHERS
                THEN
                    --
                    NULL;
            --
            END;
        --
        END IF;
    --
    END IF;
    --FIN BUG 44870 - JAE - 27/07/2018
    IF psseguro IS NOT NULL AND pfuncion = 'HIS'
    THEN
        -- Bug 20384 - APD - 20/12/2011 - se debe buscar primero la informacion en la tabla
        -- historicoseguros por si la póliza ha renovado con fecha movimiento posterior a
        -- la fecha de cierre
        -- Bug 20999-03/02/2012 Se añade esta entrada para los cierres
        BEGIN
            SELECT h1.ctipcom,
                   h1.cagente,
                   h1.cactivi,
                   NVL (pnanuali, h1.nanuali) --JRH 11/2011  Anualidad por parámetro
              INTO xctipcom,
                   xcagente,
                   xcactivi,
                   xnanuali
              FROM historicoseguros h1
             WHERE     h1.sseguro = psseguro
                   AND h1.nmovimi =
                       (SELECT MAX (h2.nmovimi)
                          FROM movseguro h2
                         WHERE     h2.sseguro = h1.sseguro
                               AND h2.fefecto <= pfecha);

            -- se debe buscar en la tabla seguros los campos cramo, cmodali, ctipseg, ccolect
            -- ya que estos campos no estan en la tabla historicoseguros
            SELECT cramo,
                   cmodali,
                   ctipseg,
                   ccolect
              INTO xcramo,
                   xcmodali,
                   xctipseg,
                   xccolect
              FROM seguros
             WHERE sseguro = psseguro;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                BEGIN
                    SELECT ctipcom,
                           cagente,
                           cramo,
                           cmodali,
                           ctipseg,
                           ccolect,
                           cactivi,
                           NVL (pnanuali, nanuali), --JRH 11/2011  Anualidad por parámetro
                           sproduc
                      INTO xctipcom,
                           xcagente,
                           xcramo,
                           xcmodali,
                           xctipseg,
                           xccolect,
                           xcactivi,
                           xnanuali,
                           vsproduc
                      FROM seguros
                     WHERE sseguro = psseguro;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        RETURN 100500;                -- sseguro no encontrado
                END;
            WHEN OTHERS
            THEN
                p_tab_error (
                    f_sysdate,
                    f_user,
                    vobj,
                    vpas,
                    vpar,
                       'SQLCODE = '
                    || SQLCODE
                    || ' - '
                    || 'SQLERRM = '
                    || SQLERRM
                    || 'error = '
                    || 100500);
                RETURN 100500;                        -- sseguro no encontrado
        END;

        -- fin Bug 20384 - APD - 20/12/2011}
        vpar := 79;
    ELSIF psseguro IS NOT NULL AND pfuncion = 'CAR'
    THEN
        -- Bug 20999-03/02/2012 Se añade esta entrada para los cierres
        --JLV 30055, hay que verificar que no haya habido un suplemento
        -- de cambio de comisión

        -- Bug 30642/170640 - 24/03/2014 - AMC
        SELECT COUNT (1)
          INTO itotcanvicomi
          FROM movseguro m
         WHERE     sseguro = psseguro
               AND m.nmovimi > pnmovimi
               AND pnmovimi IS NOT NULL;

        -- Fi Bug 30642/170640 - 24/03/2014 - AMC
        IF itotcanvicomi > 0
        THEN
            BEGIN
                SELECT h.ctipcom,
                       NVL (pcagente, s.cagente),
                       s.cramo,
                       s.cmodali,
                       s.ctipseg,
                       s.ccolect,
                       s.cactivi,
                       NVL (pnanuali, s.nanuali), --JRH 11/2011  Anualidad por parámetro
                       s.sproduc
                  INTO xctipcom,
                       xcagente,
                       xcramo,
                       xcmodali,
                       xctipseg,
                       xccolect,
                       xcactivi,
                       xnanuali,
                       vsproduc
                  FROM historicoseguros h, seguros s
                 WHERE     s.sseguro = psseguro
                       AND h.sseguro = s.sseguro
                       AND h.nmovimi = pnmovimi;
            EXCEPTION
                WHEN OTHERS
                THEN
                    BEGIN
                        SELECT ctipcom,
                               NVL (pcagente, cagente),
                               cramo,
                               cmodali,
                               ctipseg,
                               ccolect,
                               cactivi,
                               NVL (pnanuali, nanuali), --JRH 11/2011  Anualidad por parámetro
                               sproduc
                          INTO xctipcom,
                               xcagente,
                               xcramo,
                               xcmodali,
                               xctipseg,
                               xccolect,
                               xcactivi,
                               xnanuali,
                               vsproduc
                          FROM seguros
                         WHERE sseguro = psseguro;
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            RETURN 100500;            -- sseguro no encontrado
                    END;
            END;
        ELSE
            BEGIN
                SELECT ctipcom,
                       NVL (pcagente, cagente),
                       cramo,
                       cmodali,
                       ctipseg,
                       ccolect,
                       cactivi,
                       NVL (pnanuali, nanuali), --JRH 11/2011  Anualidad por parámetro
                       sproduc
                  INTO xctipcom,
                       xcagente,
                       xcramo,
                       xcmodali,
                       xctipseg,
                       xccolect,
                       xcactivi,
                       xnanuali,
                       vsproduc
                  FROM seguros
                 WHERE sseguro = psseguro;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN -- Inicio - BUG-0042691 AF Control de excepción poliza y comisión inexistente, tablas est. GASE_0001 - RCM - 09/05/2018.
                    BEGIN
                        SELECT ctipcom,
                               NVL (pcagente, cagente),
                               cramo,
                               cmodali,
                               ctipseg,
                               ccolect,
                               cactivi,
                               NVL (pnanuali, nanuali),
                               sproduc
                          INTO xctipcom,
                               xcagente,
                               xcramo,
                               xcmodali,
                               xctipseg,
                               xccolect,
                               xcactivi,
                               xnanuali,
                               vsproduc
                          FROM estseguros
                         WHERE sseguro = psseguro;
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            RETURN 100500;            -- sseguro no encontrado
                    END; -- Fin - BUG-0042691 AF Control de excepción poliza y comisión inexistente, tablas est. GASE_0001 - RCM - 09/05/2018.
                WHEN OTHERS
                THEN
                    RETURN 100500;                    -- sseguro no encontrado
            END;
        END IF;
    ELSIF pfuncion = 'TAR'
    THEN
        IF pttabla = 'EST'
        THEN
            BEGIN
                SELECT ctipcom,
                       NVL (pcagente, cagente),
                       cramo,
                       cmodali,
                       ctipseg,
                       ccolect,
                       cactivi,
                       NVL (pnanuali, nanuali), --JRH 11/2011  Anualidad por parámetro
                       sproduc
                  INTO xctipcom,
                       xcagente,
                       xcramo,
                       xcmodali,
                       xctipseg,
                       xccolect,
                       xcactivi,
                       xnanuali,
                       vsproduc
                  FROM estseguros
                 WHERE sseguro = psseguro;
            EXCEPTION
                WHEN OTHERS
                THEN
                    RETURN 100500;
            END;
        ELSIF pttabla = 'SOL'
        THEN
            BEGIN
                SELECT NVL (pcagente, cagente),
                       cramo,
                       cmodali,
                       ctipseg,
                       ccolect,
                       cactivi,
                       NVL (pnanuali, 1), --JRH 11/2011  Anualidad por parámetro
                       sproduc
                  INTO xcagente,
                       xcramo,
                       xcmodali,
                       xctipseg,
                       xccolect,
                       xcactivi,
                       xnanuali,
                       vsproduc
                  FROM solseguros
                 WHERE ssolicit = psseguro;
            EXCEPTION
                WHEN OTHERS
                THEN
                    p_tab_error (
                        f_sysdate,
                        f_user,
                        vobj,
                        vpas,
                        vpar,
                           'SQLCODE = '
                        || SQLCODE
                        || ' - '
                        || 'SQLERRM = '
                        || SQLERRM
                        || 'error = '
                        || 100500);
                    RETURN 100500;
            END;
        END IF;
    ELSE
        xctipcom := 0;
        xcagente := pcagente;
        xcramo := pcramo;
        xcmodali := pcmodali;
        xccolect := pccolect;
        xctipseg := pctipseg;
        xcactivi := pcactivi;
        xnanuali := NVL (pnanuali, 1);

        BEGIN
            SELECT sproduc
              INTO vsproduc
              FROM productos
             WHERE     cramo = pcramo
                   AND cmodali = pcmodali
                   AND ctipseg = pctipseg
                   AND ccolect = pccolect;
        EXCEPTION
            WHEN OTHERS
            THEN
                vsproduc := NULL;
        END;
    END IF;
    --Inicio NPR 	0049494: COMISIONES IAXIS CLAVES DIRECTAS 07/03/2019
    SELECT COUNT(*) INTO lc
    FROM agentes_comp
    WHERE cagente = xcagente
      AND ctipint=5;
    IF lc > 0 THEN -- Agente es clave directa, solo se calcula comisión si existe co-corretaje, sino, la clave directa no tiene comisión
       ltiene_corretaje := pac_corretaje.f_tiene_corretaje(psseguro);
       IF ltiene_corretaje = 0 THEN
          -- No tiene corretaje, la comision es 0
          ppcomisi := 0;
          ppretenc := 0;
          RETURN 0;
       END IF;
    END IF;
    --Fin NPR 0049494: COMISIONES IAXIS CLAVES DIRECTAS 07/03/2019

    vpasexec := 3;

    -- CRE_145 - 22/07/2008
    -- Buscamos los posibles gastos externos modificados
    -- estos sustituirán a la comisión comercial a aplicar
    -- INI BUG 0035054-0200497:QT_0017346 - MAV - 11/03/2013 - Poner xgastoext, vcomisextra y vredcom directamente en null ya que las preguntas no existen
    IF psseguro IS NOT NULL
    THEN
        IF pfuncion IN ('HIS', 'CAR', 'TAR')
        THEN
            IF NVL (f_parproductos_v (vsproduc, 'TIENE_GASTEXT'), 0) = 1
            THEN
                IF pcgarant IS NOT NULL
                THEN
                    IF NVL (f_pargaranpro_v (xcramo,
                                             xcmodali,
                                             xctipseg,
                                             xccolect,
                                             xcactivi,
                                             pcgarant,
                                             'TIPO'),
                            0) IN (3, 4)
                    THEN
                        xgastoext := 0;
                    ELSE
                        bCalculaComision := TRUE;
                    END IF;
                ELSE
                    IF     psCaller IS NOT NULL
                       AND psCaller IN ('CIERRE_AHORRO', 'DETREC_INTAHORRO')
                    THEN
                        bCalculaComision := TRUE;
                    ELSE
                        xgastoext := NULL;
                    END IF;
                END IF;

                IF bCalculaComision
                THEN
                    xgastoext :=
                        CASE
                            WHEN pfuncion IN ('HIS', 'CAR')
                            THEN
                                f_gastext ('SEG',
                                           psseguro,
                                           pnriesgo,
                                           pcgarant)
                            WHEN     pfuncion = 'TAR'
                                 AND pttabla IN ('SOL', 'EST')
                            THEN
                                f_gastext (pttabla,
                                           psseguro,
                                           pnriesgo,
                                           pcgarant)
                            ELSE
                                0
                        END;
                END IF;
            ELSE
                xgastoext := NULL;
            END IF;

            vcomisextra := NULL;
            vredcom := NULL;
        END IF;
    END IF;

    vpasexec := 4;
    vpar := 85;

    -- Bug 19169 - APD - 17/11/2011 - primero se debe buscar el cuadro de comision
    -- de la tabla comisionvig_agente, sino no encuentra datos de la tabla agentes
    BEGIN
        SELECT ca.ccomisi
          INTO xccomisi
          FROM comisionvig_agente ca, codicomisio c
         WHERE     ca.ccomisi = c.ccomisi
               AND c.ctipo = 1                                 --Tipo Comisión
               AND ca.cagente = xcagente
               AND TRUNC (pfecha) BETWEEN finivig
                                      AND NVL (ffinvig, TRUNC (pfecha))
               AND ca.ccomind = pccomind; -- Bug 20999 - APD - 26/01/2012 - comision indirecta
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            BEGIN
                -- Bug 20999 - APD - 26/01/2012 - se añade el DECODE
                -- si la comision a buscar ES INDIRECTA pccomind = 1 --> ccomisi_indirect
                -- si la comision a buscar ES NO INDIRECTA pccomind = 0 --> ccomisi
                SELECT DECODE (pccomind,  0, ccomisi,  1, ccomisi_indirect)
                  INTO xccomisi
                  FROM agentes
                 WHERE cagente = xcagente;
            EXCEPTION
                WHEN OTHERS
                THEN
                    num_error := 100504;                   -- Agent inexistent
                    RETURN num_error;
            END;
        WHEN OTHERS
        THEN
            num_error := 100504;                           -- Agent inexistent
            p_tab_error (
                f_sysdate,
                f_user,
                vobj,
                vpas,
                vpar,
                   'SQLCODE = '
                || SQLCODE
                || ' - '
                || 'SQLERRM = '
                || SQLERRM
                || 'error = '
                || num_error);
            RETURN num_error;
    END;

    -- fin Bug 19169 - APD - 17/11/2011
    vpasexec := 5;
    vpar := 86;

    BEGIN
        SELECT cretenc
          INTO xcretenc
          FROM agentes
         WHERE cagente = xcagente;
    EXCEPTION
        WHEN OTHERS
        THEN
            num_error := 100504;                           -- Agent inexistent
            p_tab_error (
                f_sysdate,
                f_user,
                vobj,
                vpas,
                vpar,
                   'SQLCODE = '
                || SQLCODE
                || ' - '
                || 'SQLERRM = '
                || SQLERRM
                || 'error = '
                || num_error);
            RETURN num_error;
    END;

    vpasexec := 6;

    IF xgastoext IS NOT NULL
    THEN           --> CRE_145 - Si existe gasto externo este será la comisión
        ppcomisi := xgastoext;
    ELSE
        IF xctipcom = 99
        THEN                                                    -- Forzada a 0
            ppcomisi := 0;
        ELSIF xctipcom = 0
        THEN                                                    -- La habitual
            -- ini Bug 0019682 - 26/10/2011 - JMF
            IF pttabla = 'EST'
            THEN
                BEGIN
                    SELECT NVL (ctipretr, 0)
                      INTO vctipretr
                      FROM estseguros
                     WHERE sseguro = psseguro;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        vctipretr := 0;
                END;

                IF vctipretr != 1
                THEN
                    num_error := f_local_comhabitual;
                ELSE
                    ppcomisi := 0;
                END IF;
            --JRH 06/2012
            --ELSIF pttabla = 'POL' THEN
            --FIN JRH
            ELSE
                BEGIN
                    SELECT NVL (ctipretr, 0)
                      INTO vctipretr
                      FROM seguros
                     WHERE sseguro = psseguro;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        vctipretr := 0;
                END;

                IF vctipretr != 1
                THEN
                    num_error := f_local_comhabitual;
                ELSE
                    ppcomisi := 0;
                END IF;
            END IF;

            IF num_error <> 0
            THEN
                RETURN num_error;
            END IF;

            -- fin Bug 0019682 - 26/10/2011 - JMF
            IF pccomind = 0
            THEN       -- Bug 20999 - APD - 26/01/2012 - comision NO indirecta
                -- Bug 19954 - APD - 31/10/2011 - Incluir sobrecomisión en el cálculo de la comisión
                num_error := f_sobrecomision;

                IF num_error <> 0
                THEN
                    RETURN num_error;
                END IF;
            END IF;                        -- fin Bug 20999 - APD - 26/01/2012
        -- Fin Bug 19954 - APD - 31/10/2011
        --ELSIF xctipcom = 90 THEN   --Comissió especial
        ELSIF xctipcom IN (90)
        THEN               --Comissió especial -- BUG 32548 - NSS - 13/08/2014
            -- ini Bug 0019682 - 26/10/2011 - JMF
            IF pttabla = 'EST'
            THEN
                BEGIN
                    SELECT NVL (ctipretr, 0)
                      INTO vctipretr
                      FROM estseguros
                     WHERE sseguro = psseguro;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        vctipretr := 0;
                END;
            ELSE
                BEGIN
                    SELECT NVL (ctipretr, 0)
                      INTO vctipretr
                      FROM seguros
                     WHERE sseguro = psseguro;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN -- INICIO --BUG-0042691 AF Control de excepción poliza y comisión inexistente, tablas est. GASE_0001 - RCM - 09/05/2018.
                        BEGIN
                            SELECT NVL (ctipretr, 0)
                              INTO vctipretr
                              FROM estseguros
                             WHERE sseguro = psseguro;
                        EXCEPTION -- FIN -- BUG-0042691 AF Control de excepción poliza y comisión inexistente, tablas est. GASE_0001 - RCM - 09/05/2018.
                            WHEN NO_DATA_FOUND
                            THEN
                                vctipretr := 0;
                        END;
                END; -- BUG-0042691 AF Control de excepción poliza y comisión inexistente, tablas est. GASE_0001 - RCM - 09/05/2018.
            END IF;

            vpar := 87;

            IF NVL (f_pargaranpro_v (xcramo,
                                     xcmodali,
                                     xctipseg,
                                     xccolect,
                                     xcactivi,
                                     pcgarant,
                                     'AFECTA_COMISESPECIAL'),
                    1) = 1
            THEN
                -- Comision especial
                BEGIN
                    IF pttabla = 'EST'
                    THEN
                        IF vctipretr != 1
                        THEN
                            SELECT pcomisi
                              INTO ppcomisi
                              FROM estcomisionsegu
                             WHERE     sseguro = psseguro
                                   AND NVL (xnanuali, 1) BETWEEN ninialt
                                                             AND nfinalt
                                   AND cmodcom = pcmodcom
                                   AND nmovimi = (SELECT MAX (nmovimi)
                                                    FROM estcomisionsegu
                                                   WHERE sseguro = psseguro); -- Bug 30642/169851 - 20/03/2014 - AMC
                        ELSE
                            ppcomisi := 0;
                        END IF;
                    ELSE
                        IF vctipretr != 1
                        THEN
                            BEGIN -- BUG-0042691 AF Control de excepción poliza y comisión inexistente, tablas est. GASE_0001 - RCM - 09/05/2018.
                                SELECT pcomisi
                                  INTO ppcomisi
                                  FROM comisionsegu
                                 WHERE     sseguro = psseguro
                                       AND NVL (xnanuali, 1) BETWEEN ninialt
                                                                 AND nfinalt
                                       AND cmodcom = pcmodcom
                                       AND nmovimi =
                                           (SELECT MAX (nmovimi)
                                              FROM comisionsegu
                                             WHERE sseguro = psseguro); -- Bug 30642/169851 - 20/03/2014 - AMC
                            EXCEPTION -- INICIO -- BUG-0042691 AF Control de excepción poliza y comisión inexistente, tablas est. GASE_0001 - RCM - 09/05/2018.
                                WHEN NO_DATA_FOUND
                                THEN
                                    SELECT pcomisi
                                      INTO ppcomisi
                                      FROM estcomisionsegu
                                     WHERE     sseguro = psseguro
                                           AND NVL (xnanuali, 1) BETWEEN ninialt
                                                                     AND nfinalt
                                           AND cmodcom = pcmodcom
                                           AND nmovimi =
                                               (SELECT MAX (nmovimi)
                                                  FROM estcomisionsegu
                                                 WHERE sseguro = psseguro);
                            END;
                        ELSE
                            ppcomisi := 0;
                        END IF;
                    -- FIN -- BUG-0042691 AF Control de excepción poliza y comisión inexistente, tablas est. GASE_0001 - RCM - 09/05/2018.
                    END IF;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        num_error := 100933;            -- Comissió inexistent
                        RETURN num_error;
                    WHEN OTHERS
                    THEN
                        num_error := 103627; --Error al llegir la taula COMISIONSEGU
                        p_tab_error (
                            f_sysdate,
                            f_user,
                            vobj,
                            vpas,
                            vpar,
                               'SQLCODE = '
                            || SQLCODE
                            || ' - '
                            || 'SQLERRM = '
                            || SQLERRM
                            || 'error = '
                            || num_error);
                        RETURN num_error;
                END;
            ELSE
                -- Comision habitual
                IF vctipretr != 1
                THEN
                    num_error := f_local_comhabitual;

                    IF num_error <> 0
                    THEN
                        RETURN num_error;
                    END IF;
                ELSE
                    ppcomisi := 0;
                END IF;
            END IF;

            vpar := 88;
        -- fin Bug 0019682 - 26/10/2011 - JMF
        ELSIF xctipcom IN (92)
        THEN                               -- ini Bug 32548 - 13/08/2014 - NSS
            IF pttabla = 'EST'
            THEN
                BEGIN
                    SELECT NVL (ctipretr, 0)
                      INTO vctipretr
                      FROM estseguros
                     WHERE sseguro = psseguro;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        vctipretr := 0;
                END;
            ELSE
                BEGIN
                    SELECT NVL (ctipretr, 0)
                      INTO vctipretr
                      FROM seguros
                     WHERE sseguro = psseguro;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        vctipretr := 0;
                END;
            END IF;

            vpar := 87;

            IF NVL (f_pargaranpro_v (xcramo,
                                     xcmodali,
                                     xctipseg,
                                     xccolect,
                                     xcactivi,
                                     pcgarant,
                                     'AFECTA_COMISESPECIAL'),
                    1) = 1
            THEN
                -- Comision especial
                BEGIN
                    IF pttabla = 'EST'
                    THEN
                        IF vctipretr != 1
                        THEN
                            SELECT pcomisi
                              INTO ppcomisi
                              FROM estcomisionsegu
                             WHERE     sseguro = psseguro
                                   AND cmodcom = pcmodcom
                                   AND nmovimi = (SELECT MAX (nmovimi)
                                                    FROM estcomisionsegu
                                                   WHERE sseguro = psseguro);
                        ELSE
                            ppcomisi := 0;
                        END IF;
                    ELSE
                        IF vctipretr != 1
                        THEN
                            SELECT pcomisi
                              INTO ppcomisi
                              FROM comisionsegu
                             WHERE     sseguro = psseguro
                                   AND cmodcom = pcmodcom
                                   AND nmovimi = (SELECT MAX (nmovimi)
                                                    FROM comisionsegu
                                                   WHERE sseguro = psseguro);
                        ELSE
                            ppcomisi := 0;
                        END IF;
                    END IF;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        num_error := 100933;            -- Comissió inexistent
                        RETURN num_error;
                    WHEN OTHERS
                    THEN
                        num_error := 103627; --Error al llegir la taula COMISIONSEGU
                        p_tab_error (
                            f_sysdate,
                            f_user,
                            vobj,
                            vpas,
                            vpar,
                               'SQLCODE = '
                            || SQLCODE
                            || ' - '
                            || 'SQLERRM = '
                            || SQLERRM
                            || 'error = '
                            || num_error);
                        RETURN num_error;
                END;
            ELSE
                -- Comision habitual
                IF vctipretr != 1
                THEN
                    num_error := f_local_comhabitual;

                    IF num_error <> 0
                    THEN
                        RETURN num_error;
                    END IF;
                ELSE
                    ppcomisi := 0;
                END IF;
            END IF;

            vpar := 88;
        -- fin Bug 32548 - 13/08/2014 - NSS
        ELSIF xctipcom = 91
        THEN                                               --Comissió especial
            IF pttabla = 'EST'
            THEN
                BEGIN
                    SELECT NVL (ctipretr, 0)
                      INTO vctipretr
                      FROM estseguros
                     WHERE sseguro = psseguro;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        vctipretr := 0;
                END;
            ELSE
                BEGIN
                    SELECT NVL (ctipretr, 0)
                      INTO vctipretr
                      FROM seguros
                     WHERE sseguro = psseguro;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        vctipretr := 0;
                END;
            END IF;

            -- ini Bug 0021947 - 18/04/2012 - BFP
            IF NVL (f_pargaranpro_v (xcramo,
                                     xcmodali,
                                     xctipseg,
                                     xccolect,
                                     xcactivi,
                                     pcgarant,
                                     'AFECTA_COMISESPECIAL'),
                    1) = 1
            THEN
                -- Comision especial
                BEGIN
                    IF pttabla = 'EST'
                    THEN
                        IF vctipretr != 1
                        THEN
                            SELECT pcomisi
                              INTO ppcomisi
                              FROM estgaransegcom e, estgaranseg g
                             WHERE     e.sseguro = psseguro
                                   --JRH 26/06/2012
                                   AND e.cgarant = pcgarant
                                   AND e.nriesgo = NVL (pnriesgo, 1)
                                   AND NVL (xnanuali, 1) BETWEEN e.ninialt
                                                             AND e.nfinalt
                                   AND e.cmodcom = pcmodcom
                                   AND g.cgarant = e.cgarant
                                   AND g.nriesgo = e.nriesgo
                                   AND g.nmovimi = e.nmovimi
                                   AND g.sseguro = e.sseguro
                                   AND g.finiefe = e.finiefe
                                   AND (g.finiefe <= pfecha)
                                   AND (   (    g.ffinefe > pfecha
                                            AND g.ffinefe IS NOT NULL)
                                        OR (g.ffinefe IS NULL));
                        ELSE
                            ppcomisi := 0;
                        END IF;
                    ELSE
                        IF vctipretr != 1
                        THEN
                            SELECT pcomisi
                              INTO ppcomisi
                              FROM garansegcom e, garanseg g
                             WHERE     e.sseguro = psseguro
                                   --JRH 26/06/2012
                                   AND e.cgarant = pcgarant
                                   AND NVL (xnanuali, 1) BETWEEN e.ninialt
                                                             AND e.nfinalt
                                   AND e.nriesgo = NVL (pnriesgo, 1)
                                   AND e.cmodcom = pcmodcom
                                   AND g.cgarant = e.cgarant
                                   AND g.nriesgo = e.nriesgo
                                   AND g.nmovimi = e.nmovimi
                                   AND g.sseguro = e.sseguro
                                   AND g.finiefe = e.finiefe
                                   AND (g.finiefe <= pfecha)
                                   AND (   (    g.ffinefe > pfecha
                                            AND g.ffinefe IS NOT NULL)
                                        OR (g.ffinefe IS NULL));
                        ELSE
                            ppcomisi := 0;
                        END IF;
                    END IF;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        num_error := 100933;            -- Comissió inexistent
                        RETURN num_error;
                    WHEN OTHERS
                    THEN
                        num_error := 103627; --Error al llegir la taula COMISIONSEGCOM
                        p_tab_error (
                            f_sysdate,
                            f_user,
                            vobj,
                            vpas,
                            vpar,
                               'SQLCODE = '
                            || SQLCODE
                            || ' - '
                            || 'SQLERRM = '
                            || SQLERRM
                            || 'error = '
                            || num_error);
                        RETURN num_error;
                END;
            ELSE
                -- Comision habitual
                IF vctipretr != 1
                THEN
                    num_error := f_local_comhabitual;

                    IF num_error <> 0
                    THEN
                        RETURN num_error;
                    END IF;
                ELSE
                    ppcomisi := 0;
                END IF;
            END IF;
        -- fi Bug 0021947 - 18/04/2012 - BFP
        ELSE
            num_error := 100947;       -- valor no válido en SEGUROS (ctipcom)
            RETURN num_error;
        END IF;
    END IF;

    vpasexec := 7;
    --JRH 11/2011 Lo he movido de sitio
    -- Bug 19873 - 25/10/2011 - JRH - 0019873: GIP003-Comisión de Cobro
    -- Bug 19954 - APD -31/10/2011 - Incluir sobrecomisión en el cálculo de la comisión
    ppcomisi := ppcomisi + NVL (vcomisextra, 0) + NVL (vpsobrecomisi, 0);
    -- Fin Bug 19954 - APD -31/10/2011
    --Aquí está el tema, le añadimos una sobrecomisión
    -- Fi Bug 19873 - 25/10/2011 - JRH
    -- JLB - I - 21164
    vpas := 90;

    IF NVL (
           pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa (),
                                          'CALC_RETENC_AGENTE'),
           1) =
       1
    THEN
        BEGIN
            SELECT pretenc
              INTO ppretenc
              FROM retenciones
             WHERE     cretenc = xcretenc
                   AND TRUNC (pfretenc) >= TRUNC (finivig)
                   AND TRUNC (pfretenc) < TRUNC (NVL (ffinvig, pfretenc + 1));
        EXCEPTION
            WHEN OTHERS
            THEN
                num_error := 100726;
                p_tab_error (
                    f_sysdate,
                    f_user,
                    vobj,
                    vpas,
                    vpar,
                       'SQLCODE = '
                    || SQLCODE
                    || ' - '
                    || 'SQLERRM = '
                    || SQLERRM
                    || 'error = '
                    || 100726);
                -- retención no encontrada
                RETURN num_error;
        END;
    ELSE
        ppretenc := 0;
    END IF;

    IF     pcgarant IS NOT NULL
       AND NVL (f_pargaranpro_v (xcramo,
                                 xcmodali,
                                 xctipseg,
                                 xccolect,
                                 xcactivi,
                                 pcgarant,
                                 'AFECTA_COMISESPECIAL'),
                1) = 1
    THEN
        -- Bug 19427 - 29/06/2012 - JRH - Puntos de reducción de comisión
        IF ppcomisi - NVL (vredcom, 0) < 0
        THEN
            ppcomisi := 0;
        ELSE
            ppcomisi := ppcomisi - NVL (vredcom, 0);
        END IF;
    END IF;

    -- Fi Bug 19427 - 29/06/2012
    -- JLB - F - 21164
    --INI BUG 44870 - JAE - 27/07/2018 - Porcentaje de comisión heredado Plan/Riesgo
    BEGIN
        --
        SELECT sproduc, sseguro
          INTO vsproduc, vsseguro_0
          FROM seguros
         WHERE     ncertif = 0
               AND npoliza = (SELECT DISTINCT npoliza
                                FROM seguros
                               WHERE sseguro = psseguro);
    --
    EXCEPTION
        WHEN OTHERS
        THEN
            vsproduc := NULL;
            vsseguro_0 := NULL;
    --
    END;
    --
    num_error := pac_productos.f_get_herencia_col (vsproduc, 13, xctipcom);
    IF num_error = 0
    THEN
        --
        IF NVL (xctipcom, 0) = 2            -- Hereda comision del plan/riesgo
        THEN
            --
            BEGIN
                --
                --Selecciona el plan
                SELECT crespue
                  INTO v_plan
                  FROM pregunpolseg p
                 WHERE     sseguro = psseguro
                       AND cpregun = 4089
                       AND nmovimi =
                           (SELECT MAX (nmovimi)
                              FROM pregunpolseg pg
                             WHERE     p.sseguro = pg.sseguro
                                   AND p.cpregun = pg.cpregun);
                --
                --Tipo comisión
                SELECT crespue
                  INTO v_resp_9283
                  FROM pregunseg p
                 WHERE     sseguro = psseguro
                       AND cpregun = 9283
                       AND nmovimi =
                           (SELECT MAX (nmovimi)
                              FROM pregunseg pg
                             WHERE     p.sseguro = pg.sseguro
                                   AND p.cpregun = pg.cpregun);
                --
                IF NVL (v_resp_9283, 0) != 99
                THEN
                    --
                    --Obtiene el porcentaje Plan/Riesgo
                    SELECT b.tvalor
                      INTO vpcomisi
                      FROM pregunsegtab  a
                           INNER JOIN pregunsegtab b
                               ON     a.sseguro = b.sseguro
                                  AND a.nriesgo = b.nriesgo
                                  AND a.cpregun = b.cpregun
                                  AND a.nmovimi = b.nmovimi
                                  AND a.nlinea = b.nlinea
                     WHERE     a.ccolumna = 1
                           AND b.ccolumna = 2
                           AND a.sseguro = vsseguro_0
                           AND a.nriesgo = v_plan
                           AND a.cpregun = 9284
                           AND a.nmovimi =
                               (SELECT MAX (nmovimi)
                                  FROM pregunsegtab
                                 WHERE     sseguro = vsseguro_0
                                       AND nriesgo = v_plan
                                       AND cpregun = 9284
                                       AND ccolumna = 1)
                           AND a.nvalor = 1;
                           --INI BUG 51461 - NACR - 07/06/2019
                            IF pac_mdpar_productos.f_get_parproducto('VAL_FEC_PRO_PUAC', vsproduc) = 1 THEN
                              SELECT ncertif
                              INTO vpcertifpuac
                              FROM seguros
                              WHERE sseguro = psseguro;
                              IF vpcertifpuac > 0 THEN
                                SELECT PCOMISI
                                INTO vpcomisi
                                FROM comisionsegu
                                WHERE SSEGURO = psseguro
                                AND NMOVIMI  IN
                                  (SELECT MAX (nmovimi) FROM comisionsegu WHERE sseguro = psseguro)
                                AND CMODCOM IN
                                  (SELECT MAX (CMODCOM) FROM comisionsegu WHERE sseguro = psseguro);
                              END IF;
                            END IF;
                            --FIN BUG 51461 - NACR - 07/06/2019
                    --
                    ppcomisi := vpcomisi;
                --
                END IF;
            --
            EXCEPTION
                WHEN OTHERS
                THEN
                    --
                    NULL;
            --
            END;
        --
        END IF;
    --
    END IF;
    --FIN BUG 44870 - JAE - 27/07/2018
    RETURN (0);
END f_pcomisi;