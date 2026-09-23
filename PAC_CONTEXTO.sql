-----------------------------------------------------------------------------------------------
------------------------------------Paquete PAC_CONTEXTO---------------------------------------
-----------------------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE AXIS."PAC_CONTEXTO" AUTHID CURRENT_USER IS
/****************************************************************************
   NOM:       PAC_CONTEXTO
   PROPÒSIT:

   REVISIONS:
   Ver        Data        Autor             Descripció
   ---------  ----------  ---------------  ----------------------------------
   1.0        ??????????
   1.1        27/04/2009   MSR              Optimització
   1.2        02/06/2009   MSR              Posar funcions pel context per defecte
****************************************************************************/
   --BUG9903 27/07/2009 MSR : Es defineix aquesta constant per evitar accedir a F_PARINTALACION_T
   Context_User   CONSTANT VARCHAR2(30)  := F_PARINSTALACION_T('CONTEXT_USER');
--  Tot això no està definit perquè no és compatible amb PAC_IAX_LOGIN
--   cidioma        CONSTANT IDIOMAS.CIDIOMA%TYPE := SYS_CONTEXT (Context_User,'IAX_IDIOMA');
--   cxtusuario     CONSTANT VARCHAR2(100) := SYS_CONTEXT (Context_User,'IAX_USUARIO');
--   cxtagente      CONSTANT VARCHAR2(100) := SYS_CONTEXT (Context_User,'IAX_AGENTE');
--   cempresa       CONSTANT EMPRESAS.CEMPRESA%TYPE) := SYS_CONTEXT (Context_User,'IAX_EMPRESA');
--   cxtagenteprod  CONSTANT VARCHAR2(100) := SYS_CONTEXT (Context_User,'IAX_AGENTEPROD');
--   cxtterminal    CONSTANT VARCHAR2(100) := SYS_CONTEXT (Context_User,'IAX_TERMINAL');
--   nombre         CONSTANT VARCHAR2(100) := SYS_CONTEXT (Context_User,'NOMBRE');
   --FI BUG9903 27/07/2009 MSR : Es defineix aquesta constant per evitar accedir a F_PARINTALACION_T


   PROCEDURE p_contextoasignaparametro (
      pcnomcontexto    IN   VARCHAR2,
      pcnomparametro   IN   VARCHAR2,
      pvalparametro    IN   VARCHAR2);

-- Funcion que devuelve el valor de uno de los parámetros del contexto pasados por parametro
   FUNCTION f_contextovalorparametro (
      pcnomcontexto    IN   VARCHAR2,
      pcnomparametro   IN   VARCHAR2)
      RETURN VARCHAR2;

   --BUG9903 02/06/2009 MSR : Context per defecte
   PROCEDURE p_contextoasignaparametro (
      pcnomparametro   IN   VARCHAR2,
      pvalparametro    IN   VARCHAR2);

   FUNCTION f_contextovalorparametro (
      pcnomparametro   IN   VARCHAR2)
      RETURN VARCHAR2;
   --FI BUG9903 02/06/2009 MSR : Context per defecte


-- *** 0007870: Inicializar atributos contextuales en nuevas sesiones y parametrización de las imágenes para los listados
-- Funcion para inicilizar los atributos contextuales
   FUNCTION F_InicializarCTX (pcusuari IN USUARIOS.CUSUARI%TYPE,pterminal IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
END pac_contexto;

CREATE OR REPLACE PACKAGE BODY AXIS."PAC_CONTEXTO" IS

    --Define las varibles tipos contexto
    cxtidioma  VARCHAR2(100)    :='IAX_IDIOMA';
    cxtusuario VARCHAR2(100)    :='IAX_USUARIO';
    cxtagente  VARCHAR2(100)    :='IAX_AGENTE';
    cxtempresa VARCHAR2(100)    :='IAX_EMPRESA';
    cxtagenteprod VARCHAR2(100) := 'IAX_AGENTEPROD';
    cxtterminal VARCHAR2(100)   := 'IAX_TERMINAL';

   PROCEDURE p_contextoasignaparametro (
      pcnomcontexto    IN   VARCHAR2,
      pcnomparametro   IN   VARCHAR2,
      pvalparametro    IN   VARCHAR2) IS
   BEGIN
-- Funcion que asigna un parametro y un valor al contexto de personas
      DBMS_SESSION.set_context (pcnomcontexto, pcnomparametro, pvalparametro);
      if pcnomparametro = 'nombre' then
          DBMS_APPLICATION_INFO.set_module (pvalparametro,NULL);
          DBMS_APPLICATION_INFO.SET_ACTION('Hora: '||to_char(f_sysdate,'DD/MM/YYYY HH24:MI:SS' )) ;
      end if;
   END p_contextoasignaparametro;

   FUNCTION f_contextovalorparametro (
      pcnomcontexto    IN   VARCHAR2,
      pcnomparametro   IN   VARCHAR2)
      RETURN VARCHAR2 IS
   BEGIN
-- Funcion que devuelve el valor de uno de los parámetros del contexto pasados por parametro
      RETURN SYS_CONTEXT (pcnomcontexto, pcnomparametro);
   END f_contextovalorparametro;


   --BUG9903 02/06/2009 MSR : Contexte per defecte
   PROCEDURE p_contextoasignaparametro (
      pcnomparametro   IN   VARCHAR2,
      pvalparametro    IN   VARCHAR2) IS
   BEGIN
     p_contextoasignaparametro(Context_User,pcnomparametro,pvalparametro);
   END;

   FUNCTION f_contextovalorparametro (
      pcnomparametro   IN   VARCHAR2)
      RETURN VARCHAR2 IS
   BEGIN
     RETURN f_contextovalorparametro(Context_User,pcnomparametro);
   END;
   --FI BUG9903 02/06/2009 MSR : Contexte per defecte


-- *** 0007870:  Inicializar atributos contextuales en nuevas sesiones y parametrización de las imágenes para los listados

-- Funcion para inicilizar los atributos contextuales
   FUNCTION F_InicializarCTX (pcusuari IN USUARIOS.CUSUARI%TYPE, pterminal IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
     v_cidioma IDIOMAS.CIDIOMA%TYPE;
     v_cempres EMPRESAS.CEMPRES%TYPE;
     v_agente  AGENTES.CAGENTE%TYPE;
   BEGIN
     SELECT cidioma,cempres  ,cdelega
     INTO v_cidioma,v_cempres,v_agente
     FROM USUARIOS
     WHERE cusuari = pcusuari;

     --BUG9903 27/07/2009 MSR : Utilitzo la constant Context_User
     p_contextoasignaparametro (Context_User,cxtusuario,pcusuari);
     p_contextoasignaparametro (Context_User,'nombre',pcusuari);
     p_contextoasignaparametro (Context_User,cxtempresa,v_cempres);
     p_contextoasignaparametro (Context_User,'empresa',v_cempres);
     p_contextoasignaparametro (Context_User,'empresasel',v_cempres);
     p_contextoasignaparametro (Context_User,'multiempres',v_cempres);
     p_contextoasignaparametro (Context_User,cxtidioma,v_cidioma);
     p_contextoasignaparametro (Context_User, 'usu_idioma',v_cidioma);
     p_contextoasignaparametro (Context_User,cxtagente,v_agente);
     p_contextoasignaparametro (Context_User,cxtagenteprod,v_agente);
     p_contextoasignaparametro (Context_User,cxtterminal,pterminal);
     --FI BUG9903 27/07/2009 MSR : Utilitzo la constant Context_User

     RETURN 0;
   EXCEPTION
     WHEN OTHERS THEN RETURN SQLCODE;
   END F_InicializarCTX;
END pac_contexto;