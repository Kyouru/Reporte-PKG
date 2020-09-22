

## Nuevo Reporte Ejecutar Package
***Agregar Columna PKGREPORTE a la tabla Reporte***

ALTER TABLE REPORTE ADD PKGREPORTE VARCHAR(3000);

***Modificar Tamaño de CAMPO1 de la tabla TMP_REPORTENUEVO (Concatenado del Anexo6 tiene +800 caracteres por celda)***

ALTER TABLE SISGODBA.TMP_REPORTENUEVO MODIFY (CAMPO1 varchar2(3000));

***Como usar campo PKGREPORTE***

Se puede llamar multiples PKG, Ejemplo:

	PKG_NUMERO1.PROCEDIMIENTO1(P_FEC_EXACTA);PKG_NUMERO2.PROCEDIMIENTO2(P_FEC_INICIO, P_FEC_FINAL);

Parametros provenientes del Oracle Forms:

	P_FEC_EXACTA
	P_FEC_INICIO
	P_FEC_FINAL
	P_COD_ESTADO

**Ejemplo Rellenar TMP_REPORTENUEVO**

	BEGIN
		PKG_REPORTE.PRO_REG_DATOS_TMP(200, '29/02/2020');
	END;