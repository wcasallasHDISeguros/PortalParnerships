
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
Convert chat to PDF
Convert chat to PDF
Open this chat in Acrobat
Conversación con Gemini
migra esta funcion de oracle a redshift "TO_CHAR(cer.fefecto,'YYYY-MM-DD') fecha_inicio_cer,"

En Amazon Redshift puedes realizar esta conversión de dos formas: usando la misma función TO_CHAR o mediante la función DATE_PART / TO_VARCHAR. La opción más directa y compatible es:

SQL
TO_CHAR(cer.fefecto, 'YYYY-MM-DD') AS fecha_inicio_cer,
Opciones equivalentes en Redshift
Opción 1: TO_CHAR (Recomendada)

Redshift soporta TO_CHAR(date/timestamp, format) de forma nativa con los mismos identificadores de formato que Oracle.

SQL
TO_CHAR(cer.fefecto, 'YYYY-MM-DD') AS fecha_inicio_cer
Opción 2: CAST o conversión explicita a DATE

Si el campo cer.fefecto es de tipo TIMESTAMP y solo necesitas la fecha en formato estándar ISO (YYYY-MM-DD), convertirlo a tipo DATE es más eficiente para lecturas en Redshift:

SQL
CAST(cer.fefecto AS DATE) AS fecha_inicio_cer
por favor migra esta funcion oracle "--decode(pp_tom.ctipide , 24, 'P.P',33, 'C.E',34,'Tarjeta identidad',35,'Registro civil',36,'C.C',37,'NIT',38,'N.U.I.P',40,'Pasaporte',43,'BIC',44,'Carnet Diplomático',45,'NIT E.',46,'Permiso especial de permanencia',47,'PECP',99,'Identificador simulaciones', 0, 'Identificiacion del sistema', 48, 'P.P.T') as tipo_identomador," ha redshift

En Amazon Redshift puedes usar directamente la función DECODE (ya que es compatible con la sintaxis de Oracle) o migrarla a una sentencia CASE, que es el estándar SQL ANSI recomendado en Redshift.

Opción 1: CASE (Estándar recomendado)
SQL
CASE pp_tom.ctipide
    WHEN 0  THEN 'Identificiacion del sistema'
    WHEN 24 THEN 'P.P'
    WHEN 33 THEN 'C.E'
    WHEN 34 THEN 'Tarjeta identidad'
    WHEN 35 THEN 'Registro civil'
    WHEN 36 THEN 'C.C'
    WHEN 37 THEN 'NIT'
    WHEN 38 THEN 'N.U.I.P'
    WHEN 40 THEN 'Pasaporte'
    WHEN 43 THEN 'BIC'
    WHEN 44 THEN 'Carnet Diplomático'
    WHEN 45 THEN 'NIT E.'
    WHEN 46 THEN 'Permiso especial de permanencia'
    WHEN 47 THEN 'PECP'
    WHEN 48 THEN 'P.P.T'
    WHEN 99 THEN 'Identificador simulaciones'
    ELSE NULL
END AS tipo_identomador,
Opción 2: DECODE (Sintaxis nativa compatible)
Redshift soporta la función DECODE de forma nativa, por lo que puedes dejar la estructura original adaptando únicamente los comentarios si los requiere:

SQL
DECODE(
    pp_tom.ctipide,
    0,  'Identificiacion del sistema',
    24, 'P.P',
    33, 'C.E',
    34, 'Tarjeta identidad',
    35, 'Registro civil',
    36, 'C.C',
    37, 'NIT',
    38, 'N.U.I.P',
    40, 'Pasaporte',
    43, 'BIC',
    44, 'Carnet Diplomático',
    45, 'NIT E.',
    46, 'Permiso especial de permanencia',
    47, 'PECP',
    48, 'P.P.T',
    99, 'Identificador simulaciones'
) AS tipo_identomador,
pasame esta función oracle a redshift --> CREATE OR REPLACE FUNCTION AXIS."FF_DESVALORFIJO" (pcvalor IN NUMBER, pcidioma IN NUMBER,

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

En Redshift las funciones almacenadas usan el lenguaje PL/pgSQL (no PL/SQL como Oracle). La principal diferencia es que Redshift no maneja excepciones (EXCEPTION WHEN OTHERS) como Oracle, por lo que para emular ese comportamiento se usa la cláusula STRICT o la gestión explícita de nulos.

Aquí tienes la función traducida a Amazon Redshift:

SQL
CREATE OR REPLACE FUNCTION axis.ff_desvalorfijo (
    pcvalor NUMERIC, 
    pcidioma NUMERIC,
    pcatribu NUMERIC
)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
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
END;
$$;
Cambios clave respecto a Oracle:
Manejo de Excepciones: Si la consulta no devuelve ningún registro en Redshift, la variable vttexto se mantiene como NULL automáticamente y la función retorna NULL, cumpliendo el mismo propósito que el bloque EXCEPTION WHEN OTHERS THEN RETURN NULL; de Oracle.

Tipos de Datos: NUMBER se convierte a NUMERIC (o INT/BIGINT si siempre son enteros) y VARCHAR2 se traduce como VARCHAR.

Cuerpo de la Función: El código va delimitado por bloques $$ y se debe especificar el lenguaje (LANGUAGE plpgsql).

AUTHID current_user: Redshift no soporta la sintaxis AUTHID. Los permisos se gestionan asignando derechos EXECUTE en el esquema/función.

agrega los comentarios origanales de la función

Aquí tienes la función traducida a Amazon Redshift conservando todos los comentarios originales (tanto el encabezado como el comentario de la excepción):

SQL
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



Gemini es una IA y puede cometer errores.

