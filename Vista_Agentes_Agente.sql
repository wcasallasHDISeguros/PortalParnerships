-- AXIS.AGENTES_AGENTE source

CREATE OR REPLACE VIEW AXIS.AGENTES_AGENTE
(CAGENTE,CEMPRES)
AS
SELECT a.cagente, a.cempres
     FROM ageredcom a, redcomercial r
    WHERE a.fmovfin IS NULL
      AND r.fmovfin IS NULL
      AND r.cagente = pac_user.ff_get_cagente(f_user)
      AND(a.c00 = r.cpervisio
          OR a.c01 = r.cpervisio
          OR a.c02 = r.cpervisio
          OR a.c03 = r.cpervisio
          OR a.c04 = r.cpervisio
          OR a.c05 = r.cpervisio
          OR a.c06 = r.cpervisio
          OR a.c07 = r.cpervisio
          OR a.c08 = r.cpervisio
          OR a.c09 = r.cpervisio
          OR a.c10 = r.cpervisio
          OR a.c11 = r.cpervisio
          OR a.c12 = r.cpervisio);