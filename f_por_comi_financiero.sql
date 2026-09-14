CREATE OR REPLACE FUNCTION AXIS.f_por_comi_financiero(
   psseguro IN NUMBER,
   pnmovimi IN NUMBER,
   pfefecto IN DATE,
   pcagente IN NUMBER,
   ppartici IN NUMBER,
   ptablas IN VARCHAR2,
   pcgarant IN NUMBER)
   RETURN NUMBER IS
   /******************************************************************************
      NOMBRE:     F_PCOMISI
      PROPOSITO:  Funcion que encuentra la comision y la retencion dependiendo de los parametros de
                  entrada informados(por el producto o por el sseguro)

      REVISIONES:
      Ver        Fecha        Autor             Descripcion
      ---------  ----------  ---------------  ------------------------------------
     01.0        10/07/2017  LCA              APCN - Error Comisiones p?lizas No contributivas BUG 35591
   ******************************************************************************/
   --
   v_pasexec      NUMBER(8) := 0;
   v_param        VARCHAR2(500)
      := 'psseguro: ' || psseguro || ', pnmovimi: ' || pnmovimi || ', pcagente: ' || pcagente
         || ', ptablas: ' || ptablas || ', pfefecto: ' || pfefecto || ', ppartici: '
         || ppartici;
   v_object       VARCHAR2(200) := 'F_POR_COMI_FINANCIERO';
   v_numerr       NUMBER := 0;
   v_pretenc      NUMBER;
   v_cramo        NUMBER;
   v_cmodali      NUMBER;
   v_ctipseg      NUMBER;
   v_ccolect      NUMBER;
   v_cactivi      NUMBER;
   v_cidioma      NUMBER;
   v_cmodcom      NUMBER;
   v_ppretenc     NUMBER;
   v_pcomisi      NUMBER;
   v_funcion      VARCHAR2(3);
BEGIN
   v_pasexec := 1;

   IF ptablas = 'EST' THEN
      SELECT cramo, cmodali, ctipseg, ccolect, cactivi, cidioma
        INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi, v_cidioma
        FROM estseguros
       WHERE sseguro = psseguro;
   ELSE
      SELECT cramo, cmodali, ctipseg, ccolect, cactivi, cidioma
        INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi, v_cidioma
        FROM seguros
       WHERE sseguro = psseguro;
   END IF;

   v_pasexec := 2;

   IF f_es_renovacion(psseguro) = 0 THEN   -- es cartera
      v_cmodcom := 2;
   ELSE   -- si es 1 es nueva produccion
      v_cmodcom := 1;
   END IF;

   v_pasexec := 3;

   IF ptablas = 'EST' THEN
      v_funcion := 'TAR';
   ELSE
      v_funcion := 'CAR';
   END IF;

   v_numerr := f_pcomisi(psseguro, v_cmodcom, pfefecto, v_pcomisi, v_ppretenc, pcagente,
                         v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi, pcgarant,
                         ptablas, v_funcion, pfefecto);
   v_pasexec := 3;

   IF v_numerr <> 0 THEN
      p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                  'num_err=' || v_numerr || ' --> Error: '
                  || f_axis_literales(v_numerr, v_cidioma));
      RETURN NULL;
   END IF;

   RETURN v_pcomisi;
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                  'num_err=' || v_numerr || ' --> Error: ' || SQLERRM);
      RETURN NULL;
END f_por_comi_financiero;

--f_por_comi_financiero (car.sseguro, null, car.fefecto, car.cagente, null, 'POL', null) comision,