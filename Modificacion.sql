
alter table reporte drop column PKGREPORTE;
alter table reporte add PKGREPORTE varchar(300);

DECLARE
	ejecutar_pkg VARCHAR2(300);

BEGIN
    BEGIN
        SELECT PKGREPORTE
        INTO ejecutar_pkg
        FROM REPORTE r
        WHERE r.codreporte = P_CODREPORTE;

        IF ejecutar_pkg <> '' THEN
          DBMS_OUTPUT.PUT_LINE(ejecutar_pkg);
          BEGIN
            EXECUTE IMMEDIATE ejecutar_pkg;
          EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE(SQLERRM || ' - ' || SQLERRM || ' - ERROR AL EJECUTAR EL PKG ' || ejecutar_pkg);
          END;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;
END;