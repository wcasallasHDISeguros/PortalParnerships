
CREATE OR REPLACE FUNCTION AXIS."FF_DESVALORFIJO" (pcvalor IN NUMBER, pcidioma IN NUMBER,
pcatribu IN NUMBER)
RETURN VARCHAR2 AUTHID current_user IS
/***********************************************************************
 Ff_DESVALORFIJO: Obtener la descripción de un Valor Fijo en
  función del idioma del usuario.

***********************************************************************/
 vttexto detvalores.tatribu%TYPE;
 
BEGIN
 SELECT tatribu
 INTO vttexto
 FROM DETVALORES
 WHERE catribu = pcatribu
  AND cidioma = pcidioma
  AND cvalor = pcvalor;
 RETURN vttexto;
EXCEPTION
 WHEN OTHERS THEN
  RETURN null; -- Valor fixe inexistent
END;



-----Version Redshift
CREATE OR REPLACE FUNCTION axis.ff_desvalorfijo (
    pcvalor NUMERIC, 
    pcidioma NUMERIC,
    pcatribu NUMERIC
)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
/***********************************************************************
 Ff_DESVALORFIJO: Obtener la descripción de un Valor Fijo en
  función del idioma del usuario.

***********************************************************************/
DECLARE
    vttexto VARCHAR;
BEGIN
    SELECT tatribu
    INTO vttexto
    FROM axis.detvalores
    WHERE catribu = pcatribu
      AND cidioma = pcidioma
      AND cvalor = pcvalor
    LIMIT 1;

    RETURN vttexto;

    -- Valor fixe inexistent
END;
$$;