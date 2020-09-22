
/*******************************************************
    Se Clono PKG_REPORTE.PRO_REG_DATOS_TMP y se agrego las siguientes lineas
    Nuevo Procedimiento PKG_REPORTE.PRO_REG_DATOS_TMP_K
********************************************************/

    ejecutar_pkg VARCHAR2(300);

    --BEGIN  

        EXECUTE IMMEDIATE 'TRUNCATE TABLE TMP_REPORTENUEVO'; --DELETE FROM TMP_REPORTENUEVO;
        
        BEGIN
          SELECT PKGREPORTE
          INTO ejecutar_pkg
          FROM REPORTE r
          WHERE r.codreporte = P_CODREPORTE;

          IF ejecutar_pkg IS NOT NULL THEN
            ejecutar_pkg := "BEGIN " || REPLACE(REPLACE(REPLACE(REPLACE(ejecutar_pkg, 'P_FEC_EXACTA', '''' || TO_CHAR(P_FEC_EXACTA, 'DD/MM/RR') || ''''), 'P_FEC_INICIO', '''' || TO_CHAR(P_FEC_INICIO, 'DD/MM/RR') || ''''), 'P_FEC_FINAL', '''' || TO_CHAR(P_FEC_FINAL, 'DD/MM/RR') || ''''), 'P_COD_ESTADO', '''' || 'P_COD_ESTADO' || '''') || ' END;';
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