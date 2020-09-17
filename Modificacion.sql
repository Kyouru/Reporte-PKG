
alter table reporte add PKGREPORTE varchar(300);

DECLARE
	ejecutar_pkg VARCHAR2(300);

BEGIN
	SELECT PKGREPORTE
        INTO ejecutar_pkg
        FROM REPORTE r
        WHERE r.codreporte = P_CODREPORTE;

        IF ejecutar_pkg <> '' THEN
          DBMS_OUTPUT.PUT_LINE(ejecutar_pkg);
          EXECUTE IMMEDIATE ejecutar_pkg;
        END IF;
END;