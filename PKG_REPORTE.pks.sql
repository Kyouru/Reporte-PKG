CREATE OR REPLACE PACKAGE SISGODBA.PKG_REPORTE IS
 
  /****************************************************************************************************
  -- Objetivo    : Almacenar Funciones o Procedimientos para la generacion de reportes excel.
  -- Responsable : Luis Chileno
  -- Fecha       : 09/04/2018
  *****************************************************************************************************/
  
FUNCTION FUN_SENT_SELECT( P_CODREPORTE REPORTE.CODREPORTE%TYPE
                        ) RETURN REPORTE.SENTSELECT%TYPE;
--
PROCEDURE PRO_REG_CAMPOS_SELECT(P_CODREPORTE REPORTE.CODREPORTE%TYPE);
--
FUNCTION FUN_EXIST_PARAM_REPORTE( P_CODREPORTE PARAMETRO_REPORTE.CODREPORTE%TYPE
                                ) RETURN VARCHAR2;
--
FUNCTION FUN_CANT_CAMPOS(P_CODREPORTE PARAMETRO_REPORTE.CODREPORTE%TYPE) RETURN NUMBER;
--
FUNCTION FUN_SENT_SELECT_FINAL( P_CODREPORTE  REPORTE.CODREPORTE%TYPE,                                   
                                P_FEC_EXACTA  DATE DEFAULT NULL, 
                                P_FEC_INICIO  DATE DEFAULT NULL, 
                                P_FEC_FINAL   DATE DEFAULT NULL, 
                                P_COD_ESTADO  SYST900.TBLCODTAB%TYPE
                              ) RETURN REPORTE.SENTSELECT%TYPE;
--
PROCEDURE PRO_REG_DATOS_TMP( P_CODREPORTE  REPORTE.CODREPORTE%TYPE,                                   
                             P_FEC_EXACTA  DATE DEFAULT NULL, 
                             P_FEC_INICIO  DATE DEFAULT NULL, 
                             P_FEC_FINAL   DATE DEFAULT NULL, 
                             P_COD_ESTADO  SYST900.TBLCODTAB%TYPE DEFAULT NULL);  

FUNCTION FUN_COD_TIPDATOCOL( P_CODREPORTE COLUMNA_REPORTE.CODREPORTE%TYPE,
                             P_SECCOLUMNA COLUMNA_REPORTE.SECCOLUMNA%TYPE
                           ) RETURN COLUMNA_REPORTE.TIPDATO%TYPE;
--
FUNCTION FUN_OBS_CONT_VALORADO( P_PERIODOSOL CONTROLESVALORADOS.PERIODOSOLICITUD%TYPE,
                                P_NROSOL CONTROLESVALORADOS.NUMEROSOLICITUD%TYPE
                              ) RETURN VARCHAR2; 
--  
FUNCTION FUN_REPORTE_SIN_PARAM( P_CODREPORTE PARAMETRO_REPORTE.CODREPORTE%TYPE
                              ) RETURN VARCHAR2;
--  
PROCEDURE P_GEN_EXCEL (PICODREPORTE IN  NUMBER,PINombreArchivo OUT VARCHAR2);  
--                                                             
END PKG_REPORTE;
/