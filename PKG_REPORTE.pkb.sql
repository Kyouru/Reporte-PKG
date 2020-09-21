CREATE OR REPLACE PACKAGE BODY SISGODBA.PKG_REPORTE IS

  /****************************************************************************************************
  -- Objetivo    : Almacenar Funciones o Procedimientos para la generacion de reportes excel.
  -- Responsable : Luis Chileno
  -- Fecha       : 09/04/2018
  *****************************************************************************************************/
 

  /****************************************************************************************************
  Objeto      : FUN_SENT_SELECT
  Responsable : Luis Chileno
  Fecha       : 09/04/2018
  Objetivo: Retornar la sentencia select de un determinado reporte.
  *****************************************************************************************************/
    FUNCTION FUN_SENT_SELECT(P_CODREPORTE REPORTE.CODREPORTE%TYPE) RETURN REPORTE.SENTSELECT%TYPE IS 

      vSentencia REPORTE.SENTSELECT%TYPE;
      
    BEGIN 

      BEGIN 
        SELECT REP.SENTSELECT 
        INTO vSentencia
        FROM REPORTE REP   
        WHERE REP.CODREPORTE =P_CODREPORTE;	
      EXCEPTION 
        WHEN OTHERS THEN 
          vSentencia:=NULL; 
      END; 
        
        IF vSentencia IS NOT NULL  
           AND  RTRIM(LTRIM(PKG_REPORTE.FUN_REPORTE_SIN_PARAM(P_CODREPORTE)))='NO' THEN      
              
          FOR X IN ( SELECT PR.CODPARAMETRO, PR.NOMPARAREPORT, ST.TBLDETALLE   
                     FROM PARAMETRO_REPORTE PR , SYST900 ST  
                     WHERE PR.CODREPORTE= P_CODREPORTE 
                     AND ST.TBLCODTAB = 968 
                     AND ST.TBLCODARG = PR.CODPARAMETRO ) LOOP  
          
            vSentencia:= REPLACE( vSentencia, X.NOMPARAREPORT, ' '||RTRIM(LTRIM(X.TBLDETALLE))||' ') ;
          
          END LOOP;
                                 
        END IF;
        
      RETURN vSentencia;
           
    EXCEPTION
      WHEN NO_DATA_FOUND THEN   
        RETURN NULL;
         
      WHEN OTHERS THEN 
        RAISE_APPLICATION_ERROR(-21000,'Error en funcion PKG_REPORTE.FUN_SENT_SELECT. '||SQLERRM); 

              
    END FUN_SENT_SELECT;

    /****************************************************************************************************
    Objeto      : PRO_REG_CAMPOS_SELECT
    Responsable : Luis Chileno
    Fecha       : 09/04/2018
    Objetivo: Registrar la estructura de los campos de la sentencia select de un reporte.
    *****************************************************************************************************/
    PROCEDURE PRO_REG_CAMPOS_SELECT(P_CODREPORTE REPORTE.CODREPORTE%TYPE) IS    

       PRAGMA AUTONOMOUS_TRANSACTION;
       
       TYPE ref_cursor IS REF CURSOR;
       rc         ref_cursor;  
       c          NUMBER;
       i          NUMBER;
       col_count  NUMBER;
       desc_tab   DBMS_SQL.DESC_TAB;
       
       vSentSelect  REPORTE.SENTSELECT%TYPE;

    BEGIN 
    
       DELETE FROM COLUMNA_REPORTE CR 
       WHERE CR.CODREPORTE = P_CODREPORTE;
              
       vSentSelect:= FUN_SENT_SELECT(P_CODREPORTE) ;
              
       OPEN rc FOR vSentSelect;
       c := DBMS_SQL.to_cursor_number(rc);

       DBMS_SQL.DESCRIBE_COLUMNS(c, col_count, desc_tab);

       FOR i IN 1..col_count LOOP
       
         
         IF desc_tab(i).col_name IS NOT NULL THEN  

           INSERT INTO COLUMNA_REPORTE( CODREPORTE, SECCOLUMNA, NOMCOLUMNA, TIPDATO, ANCHO, TITULO, USUCREA, FECCREA)
           VALUES (P_CODREPORTE, i, RTRIM(LTRIM( desc_tab(i).col_name)), 1, 60, RTRIM(LTRIM( desc_tab(i).col_name)) , USER , SYSDATE); 
             
         END IF;  
         
       END LOOP;

       DBMS_SQL.CLOSE_CURSOR(c);
       
       COMMIT;
       
    EXCEPTION     
      WHEN OTHERS THEN       
        RAISE_APPLICATION_ERROR(-21000,'Error en procedimiento PKG_REPORTE.PRO_REG_CAMPOS_SELECT. '||SQLERRM); 
          
    END PRO_REG_CAMPOS_SELECT;

    
    /****************************************************************************************************
    Objeto      : FUN_EXIST_PARAM_REPORTE
    Responsable : Luis Chileno
    Fecha       : 09/04/2018
    Objetivo: Validar si un reporte tiene parametros registrados.
    *****************************************************************************************************/    
    FUNCTION FUN_EXIST_PARAM_REPORTE(P_CODREPORTE PARAMETRO_REPORTE.CODREPORTE%TYPE) RETURN VARCHAR2 IS   
     
      vExists VARCHAR2(2);
        
    BEGIN  

       SELECT DECODE(COUNT(1),0 ,'NO' ,'SI' )
       INTO vExists   
       FROM PARAMETRO_REPORTE PR  
       WHERE PR.CODREPORTE = P_CODREPORTE;
          
       RETURN vExists;
       
    EXCEPTION 
     WHEN NO_DATA_FOUND THEN 
       RETURN 'NO';
         
     WHEN OTHERS THEN             
       RAISE_APPLICATION_ERROR(-21000,'Error en funcion PKG_REPORTE.FUN_EXIST_PARAM_REPORTE. '||SQLERRM); 
             
    END FUN_EXIST_PARAM_REPORTE; 


    /****************************************************************************************************
    Objeto      : FUN_CANT_CAMPOS
    Responsable : Luis Chileno
    Fecha       : 09/04/2018
    Objetivo: Retornar la cantidad de campos de un determinado reporte.
    *****************************************************************************************************/           
    FUNCTION FUN_CANT_CAMPOS(P_CODREPORTE PARAMETRO_REPORTE.CODREPORTE%TYPE) RETURN NUMBER IS    

        nCantCampos NUMBER:=0;
       
    BEGIN

        SELECT COUNT(1) 
        INTO nCantCampos  
        FROM COLUMNA_REPORTE CR 
        WHERE CR.CODREPORTE = P_CODREPORTE;

    RETURN nCantCampos;

    EXCEPTION 
      WHEN NO_DATA_FOUND THEN  
        RETURN 0;
      
      WHEN OTHERS THEN   
        RAISE_APPLICATION_ERROR(-21000,'Error en funcion PKG_REPORTE.FUN_CANT_CAMPOS. '||SQLERRM); 
               
    END FUN_CANT_CAMPOS;
  

    /****************************************************************************************************
    Objeto      : FUN_SENT_SELECT_FINAL
    Responsable : Luis Chileno
    Fecha       : 09/04/2018
    Objetivo: Retornar la sentencia select final de un reporte.
    *****************************************************************************************************/             
    FUNCTION FUN_SENT_SELECT_FINAL(P_CODREPORTE  REPORTE.CODREPORTE%TYPE,                                   
                                   P_FEC_EXACTA  DATE DEFAULT NULL, 
                                   P_FEC_INICIO  DATE DEFAULT NULL, 
                                   P_FEC_FINAL   DATE DEFAULT NULL, 
                                   P_COD_ESTADO  SYST900.TBLCODTAB%TYPE) 
                                   RETURN REPORTE.SENTSELECT%TYPE IS  

       vSentencia REPORTE.SENTSELECT%TYPE;
      
    BEGIN 

      BEGIN 
        SELECT REP.SENTSELECT  
        INTO vSentencia 
        FROM REPORTE REP    
        WHERE REP.CODREPORTE =P_CODREPORTE; 	
      EXCEPTION  
        WHEN OTHERS THEN  
          vSentencia:=NULL;  
      END; 
        
    IF vSentencia IS NOT NULL 
      AND  RTRIM(LTRIM(PKG_REPORTE.FUN_REPORTE_SIN_PARAM(P_CODREPORTE)))='NO' THEN  
        
        FOR X IN (SELECT PR.CODPARAMETRO, PR.NOMPARAREPORT, ST.TBLDETALLE        
                  FROM PARAMETRO_REPORTE PR, SYST900 ST 
                  WHERE PR.CODREPORTE= P_CODREPORTE 
                  AND ST.TBLCODTAB = 968 
                  AND ST.TBLCODARG = PR.CODPARAMETRO ) LOOP    
         
         IF X.CODPARAMETRO = 1 THEN --Fecha exacta.
          
            vSentencia:= REPLACE( vSentencia, X.NOMPARAREPORT, ' TRUNC( TO_DATE( '''|| TO_CHAR( P_FEC_EXACTA ,'DD/MM/YYYY')|| ''',''DD/MM/YYYY'' ) ) '  ) ;
                      
         ELSIF X.CODPARAMETRO = 2 THEN --Fecha incial
          
            vSentencia:= REPLACE( vSentencia, X.NOMPARAREPORT, ' TRUNC( TO_DATE( '''|| TO_CHAR( P_FEC_INICIO ,'DD/MM/YYYY')|| ''',''DD/MM/YYYY'' ) ) '  ) ;
            
         ELSIF X.CODPARAMETRO = 3 THEN --Fecha Final
         
            vSentencia:= REPLACE( vSentencia, X.NOMPARAREPORT, ' TRUNC( TO_DATE( '''|| TO_CHAR( P_FEC_FINAL ,'DD/MM/YYYY')|| ''',''DD/MM/YYYY'' ) ) '  ) ;
           
         ELSIF X.CODPARAMETRO = 4 THEN --Estado, se debe determinar el codigo de estado 
         
            vSentencia:= REPLACE( vSentencia, X.NOMPARAREPORT, ' '||RTRIM(LTRIM(TO_CHAR(P_COD_ESTADO)))||' ') ;
               
         END IF;  
         
        END LOOP;
                             
    END IF;

    RETURN vSentencia;

    EXCEPTION 
      WHEN NO_DATA_FOUND THEN   
        RETURN NULL; 
      
      WHEN OTHERS THEN   
        RAISE_APPLICATION_ERROR(-21000,'Error en funcion PKG_REPORTE.FUN_SENT_SELECT_FINAL. '||SQLERRM);
       
    END FUN_SENT_SELECT_FINAL; 
  
    /****************************************************************************************************
    Objeto      : PRO_REG_DATOS_TMP
    Responsable : Luis Chileno
    Fecha       : 09/04/2018
    Objetivo: Registrar datos en tabla temporal para la generacion de un determinado reporte.
    *****************************************************************************************************/               
    PROCEDURE PRO_REG_DATOS_TMP(P_CODREPORTE  REPORTE.CODREPORTE%TYPE,                                   
                                P_FEC_EXACTA  DATE DEFAULT NULL, 
                                P_FEC_INICIO  DATE DEFAULT NULL, 
                                P_FEC_FINAL   DATE DEFAULT NULL, 
                                P_COD_ESTADO  SYST900.TBLCODTAB%TYPE DEFAULT NULL) IS
               
    PRAGMA AUTONOMOUS_TRANSACTION;
                
    vSentSelect REPORTE.SENTSELECT%TYPE;
    vCampos     REPORTE.SENTSELECT%TYPE; 
    nCantCampos NUMBER;   

    BEGIN  

        DELETE FROM TMP_REPORTENUEVO;
           
        vCampos:='INSERT INTO TMP_REPORTENUEVO(';  
        nCantCampos:=PKG_REPORTE.FUN_CANT_CAMPOS(P_CODREPORTE);

        FOR X IN  1..nCantCampos LOOP

            IF nCantCampos = X THEN 
             vCampos:=vCampos||'CAMPO'||TO_CHAR(X);
            ELSE
             vCampos:=vCampos||'CAMPO'||TO_CHAR(X)||', ';
            END IF;

        END LOOP; 
        
        vCampos:=vCampos||') ' ;

        vSentSelect:=FUN_SENT_SELECT_FINAL(P_CODREPORTE,                       
                                           P_FEC_EXACTA,
                                           P_FEC_INICIO,
                                           P_FEC_FINAL,
                                           P_COD_ESTADO);
                                                  
        EXECUTE IMMEDIATE vCampos||vSentSelect;

        COMMIT;
      
    EXCEPTION 
      WHEN OTHERS THEN  
        RAISE_APPLICATION_ERROR(-21000,'Error en procedimiento PKG_REPORTE.PRO_REG_DATOS_TMP. '||SQLERRM);
            
    END PRO_REG_DATOS_TMP;

    /*******************************************************
        Objeto      : PRO_REG_DATOS_TMP_K
        Responsable : Kenji Jhoncon
        Fecha       : 21/09/2020
        Objetivo    : Ejecutar funcion de pkg antes de registrar los datos del reporte temporal
    *******************************************************/                
    PROCEDURE PRO_REG_DATOS_TMP_K(P_CODREPORTE  REPORTE.CODREPORTE%TYPE,                                   
                                P_FEC_EXACTA  DATE DEFAULT NULL, 
                                P_FEC_INICIO  DATE DEFAULT NULL, 
                                P_FEC_FINAL   DATE DEFAULT NULL, 
                                P_COD_ESTADO  SYST900.TBLCODTAB%TYPE DEFAULT NULL) IS
               
    PRAGMA AUTONOMOUS_TRANSACTION;
                
    vSentSelect REPORTE.SENTSELECT%TYPE;
    vCampos     REPORTE.SENTSELECT%TYPE; 
    nCantCampos NUMBER;

        
    ejecutar_pkg VARCHAR2(300);

    BEGIN  

        EXECUTE IMMEDIATE 'TRUNCATE TABLE TMP_REPORTENUEVO'; --DELETE FROM TMP_REPORTENUEVO;
        
        BEGIN
          SELECT PKGREPORTE
          INTO ejecutar_pkg
          FROM REPORTE r
          WHERE r.codreporte = P_CODREPORTE;

          IF ejecutar_pkg IS NOT NULL THEN
            ejecutar_pkg := REPLACE(REPLACE(REPLACE(ejecutar_pkg, 'P_FEC_EXACTA', TO_CHAR(P_FEC_EXACTA, 'DD/MM/RR')), 'P_FEC_INICIO', TO_CHAR(P_FEC_INICIO, 'DD/MM/RR')), 'P_FEC_FINAL', TO_CHAR(P_FEC_FINAL, 'DD/MM/RR'));
            BEGIN
              EXECUTE IMMEDIATE ejecutar_pkg;
            EXCEPTION
              WHEN OTHERS THEN
                --RAISE_APPLICATION_ERROR(-20000,'ERROR AL EJECUTAR EL PKG '||ejecutar_pkg);
                DBMS_OUTPUT.PUT_LINE(SQLERRM || ' - ' || SQLERRM || ' - ERROR AL EJECUTAR LA FUNCION ' || ejecutar_pkg);
            END;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;

        /*******************************************************/

        vCampos:='INSERT INTO TMP_REPORTENUEVO(';  
        nCantCampos:=PKG_REPORTE.FUN_CANT_CAMPOS(P_CODREPORTE);

        FOR X IN  1..nCantCampos LOOP

            IF nCantCampos = X THEN 
             vCampos:=vCampos||'CAMPO'||TO_CHAR(X);
            ELSE
             vCampos:=vCampos||'CAMPO'||TO_CHAR(X)||', ';
            END IF;

        END LOOP; 
        
        vCampos:=vCampos||') ' ;

        vSentSelect:=FUN_SENT_SELECT_FINAL(P_CODREPORTE,                       
                                           P_FEC_EXACTA,
                                           P_FEC_INICIO,
                                           P_FEC_FINAL,
                                           P_COD_ESTADO);
                                                  
        EXECUTE IMMEDIATE vCampos||vSentSelect;

        COMMIT;
      
    EXCEPTION 
      WHEN OTHERS THEN  
        RAISE_APPLICATION_ERROR(-21000,'Error en procedimiento PKG_REPORTE.PRO_REG_DATOS_TMP. '||SQLERRM);
            
    END PRO_REG_DATOS_TMP_K;
  
    /****************************************************************************************************
    Objeto      : FUN_COD_TIPDATOCOL
    Responsable : Luis Chileno
    Fecha       : 09/04/2018
    Objetivo: Retornar el codigo de tipo de dato para una columna de reporte.
    *****************************************************************************************************/  
    FUNCTION FUN_COD_TIPDATOCOL(P_CODREPORTE COLUMNA_REPORTE.CODREPORTE%TYPE,
                                P_SECCOLUMNA COLUMNA_REPORTE.SECCOLUMNA%TYPE) 
                                RETURN COLUMNA_REPORTE.TIPDATO%TYPE IS   

      nCodTipDato COLUMNA_REPORTE.TIPDATO%TYPE;
       
    BEGIN  

      SELECT CR.TIPDATO  
      INTO nCodTipDato      
      FROM COLUMNA_REPORTE CR  
      WHERE CR.CODREPORTE = P_CODREPORTE   
      AND CR.SECCOLUMNA = P_SECCOLUMNA ;   

      RETURN nCodTipDato;   

    EXCEPTION 
      WHEN NO_DATA_FOUND THEN   
        RETURN NULL;
         
      WHEN OTHERS THEN  
        RAISE_APPLICATION_ERROR(-21000,'Error en funcion PKG_REPORTE.FUN_COD_TIPDATOCOL. '||SQLERRM);   

    END FUN_COD_TIPDATOCOL; 

    /****************************************************************************************************
    Objeto      : FUN_OBS_CONT_VALORADO
    Responsable : Luis Chileno
    Fecha       : 09/04/2018
    Objetivo: Retornar el valor del campo de tipo de dato LONG de la tabla CONTROLESVALORADOS.OBSERVACION.
    *****************************************************************************************************/  
    FUNCTION FUN_OBS_CONT_VALORADO(P_PERIODOSOL CONTROLESVALORADOS.PERIODOSOLICITUD%TYPE,
                                   P_NROSOL CONTROLESVALORADOS.NUMEROSOLICITUD%TYPE) RETURN VARCHAR2 IS 
                                   
      vObserv CONTROLESVALORADOS.OBSERVACION%TYPE; 
      vValor  VARCHAR2(500);                       
                                                 
    BEGIN 
                                                               
      BEGIN   
        SELECT CV.OBSERVACION  
        INTO vObserv 
        FROM CONTROLESVALORADOS CV  
        WHERE CV.PERIODOSOLICITUD = P_PERIODOSOL 
        AND CV.numerosolicitud = P_NROSOL; 
      EXCEPTION 
        WHEN OTHERS THEN  
          vObserv:=NULL;
      END;
        
      vValor:=SUBSTR(vObserv,1,500);
      
      RETURN vValor;
       
    EXCEPTION 
      WHEN NO_DATA_FOUND THEN  
        RETURN NULL;
              
      WHEN OTHERS THEN  
        RAISE_APPLICATION_ERROR(-21000,'Error en funcion PKG_REPORTE.FUN_OBS_CONT_VALORADO. '||SQLERRM);  
       
    END FUN_OBS_CONT_VALORADO;                 
    
    
    /****************************************************************************************************
    Objeto      : FUN_REPORTE_SIN_PARAM
    Responsable : Luis Chileno
    Fecha       : 16/04/2018
    Objetivo: Verifica si un reporte tiene el tipo de parametro "NINGUNO".
    *****************************************************************************************************/      
    FUNCTION FUN_REPORTE_SIN_PARAM(P_CODREPORTE PARAMETRO_REPORTE.CODREPORTE%TYPE) RETURN VARCHAR2 IS    
    
      vValor VARCHAR2(2);
      
    BEGIN  

      SELECT DECODE(COUNT(1),0,'NO','SI')  
      INTO vValor   
      FROM PARAMETRO_REPORTE PR     
      WHERE PR.CODREPORTE = P_CODREPORTE    
      AND PR.CODPARAMETRO = 0; 
      
      RETURN vValor;
        
    EXCEPTION 
      WHEN NO_DATA_FOUND THEN
        RETURN 'NO';
        
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-21000,'Error en funcion PKG_REPORTE.FUN_REPORTE_SIN_PARAM. '||SQLERRM);
                 
    END FUN_REPORTE_SIN_PARAM;
    ---
    PROCEDURE P_GEN_EXCEL (PICodReporte      IN  NUMBER,
                           PINombreArchivo   OUT VARCHAR2) IS
                           
        in_file                  UTL_FILE.FILE_TYPE;
        Line                     VARCHAR2(4000);
        vNombreArchivofile       VARCHAR2(800);
        vNombreArchivo           VARCHAR2(800);
        p_ruta_out               VARCHAR2(200):='TEMPORARYFILES';--'SPLAFT_SCORING';--'COMPROBANTE_XML'; --> nombre directorio      
        vc_separador             varchar2(1):=',';        
        nContadorcolumnas        NUMBER;
        nMaximoContadorcolumnas  NUMBER;
        RUN_S                    CLOB;  
        IGNORE                   NUMBER;  
        SOURCE_CURSOR            NUMBER;  
        PWFIELD_COUNT            NUMBER DEFAULT 0;  
        L_DESCTBL                DBMS_SQL.DESC_TAB2;  
        Z_NUMBER                 NUMBER;  
        xdoc                     VARCHAR(500);
        vCantColumnas            NUMBER;
        nTipDatoCol              COLUMNA_REPORTE.TIPDATO%TYPE; 
        n                        NUMBER := 1;
        v                        NUMBER := 1;
        --
        BEGIN
            --
            SELECT nomarchivo||'_'||TO_CHAR(SYSDATE,'YYYYMMDD')||'_'||TO_CHAR(SYSDATE,'HH24MISS')||'_'||USER
              INTO vNombreArchivofile
              FROM reporte
             WHERE codreporte = PICODREPORTE;

            vNombreArchivo := vNombreArchivofile||'.csv';

            in_file := UTL_FILE.fOPEN ( p_ruta_out,vNombreArchivo,'W',32760); --.XLS
           
             --
            FOR X IN (SELECT CR.TITULO TITULO 
                        FROM COLUMNA_REPORTE CR 
                       WHERE  CR.CODREPORTE = PICODREPORTE    
                    ORDER BY CR.SECCOLUMNA) LOOP 
                
                SELECT COUNT(1) 
                  INTO vCantColumnas
                  FROM columna_reporte cr 
                 WHERE cr.codreporte = PICodReporte; 
                
                IF  N <>  vCantColumnas THEN
                  Line := Line||RTRIM(LTRIM(x.titulo))||vc_separador;
                ELSif n = vCantColumnas THEN
                  Line := Line||RTRIM(LTRIM(x.titulo));
                END IF;
                N := N+1;
                
            END LOOP;
              
            UTL_FILE.put_line( in_file, Line );
            
            ---------------------
            Line := null;

            RUN_S         := 'SELECT * FROM TMP_REPORTENUEVO';  
            SOURCE_CURSOR := DBMS_SQL.OPEN_CURSOR;  
            DBMS_SQL.PARSE(SOURCE_CURSOR, RUN_S, DBMS_SQL.NATIVE);  
            DBMS_SQL.DESCRIBE_COLUMNS2(SOURCE_CURSOR, PWFIELD_COUNT, L_DESCTBL); -- get record structure  
            FOR I IN 1 .. PWFIELD_COUNT LOOP    
                IF L_DESCTBL(I).COL_TYPE = 2 THEN  
                   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, I, Z_NUMBER);  
                ELSIF L_DESCTBL(I).COL_TYPE = 1 THEN
                   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, I, xdoc,500);  
                null;  
                END IF;  
                NULL;  
            END LOOP; 
         
            IGNORE := DBMS_SQL.EXECUTE(SOURCE_CURSOR);  
          
            LOOP  
              IF DBMS_SQL.FETCH_ROWS(SOURCE_CURSOR) > 0 THEN
                    --
                    SELECT COUNT(1) 
                      INTO nMaximoContadorcolumnas
                      FROM columna_reporte cr
                     WHERE cr.codreporte = PICodReporte;  
                     --
                     nContadorcolumnas := nMaximoContadorcolumnas;
                     --
                 FOR I IN 1 .. nMaximoContadorcolumnas LOOP                    
                     ---
                     DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, I, xdoc);
                     --       
                     nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(PICODREPORTE,I);
                
                     IF nTipDatoCol = 1 THEN 
                        --
                        xdoc := RTRIM(LTRIM(REPLACE(xdoc,',',' ')));
                        --
                     ELSIF nTipDatoCol = 2 THEN 
                        --xdoc := TO_CHAR(RTRIM(LTRIM(xdoc)),'9999999999999999.99');
                        ---xdoc := TO_NUMBER(RTRIM(LTRIM(xdoc)));
                        xdoc := xdoc;
                     ELSIF nTipDatoCol = 3 THEN   
                        IF RTRIM(LTRIM(xdoc)) IS NOT NULL THEN 
                           xdoc := RTRIM(LTRIM(TO_CHAR(TO_DATE(xdoc,'DD/MM/YYYY'), 'YYYY-MM-DD hh24:mi:ss')));   
                        ELSE
                           xdoc := NULL;
                        END IF;  
                     END IF;

                    IF v <> nContadorcolumnas  THEN
                      Line := Line||xdoc||vc_separador;
                    ELSIF  v = nContadorcolumnas THEN
                      Line := Line||xdoc;
                    END IF;
                    v := v+1; 
     
                  END LOOP;
                  --
                  UTL_FILE.put_line( in_file, Line );
                  Line:=NULL;
                  --
              ELSE  
                 EXIT;  
              END IF;
              
            END LOOP;  
        
        PINombreArchivo := vNombreArchivo;
        UTL_FILE.FCLOSE(in_file);
                      
    EXCEPTION WHEN OTHERS THEN
        Raise_Application_Error(-20000,'Error en PROCEDURE P_GEN_EXCEL:'||sqlerrm);
    END P_GEN_EXCEL;
--     
END PKG_REPORTE;
/