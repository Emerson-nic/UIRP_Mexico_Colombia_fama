# Tasas de interés y tipos de cambio: México y Colombia

[English version](README.en.md)

Este proyecto estudia la relación entre los diferenciales de tasas de interés y los movimientos del tipo de cambio en México y Colombia frente a Estados Unidos. Incluye la preparación de datos, gráficos y una aplicación de la regresión de Fama (1984) relacionada con la Paridad Descubierta de Tasas de Interés (UIRP).

## Datos y periodo

Las series mensuales provienen de [FRED](https://fred.stlouisfed.org/):

| Variable | Serie |
|---|---|
| Tasa de Estados Unidos | [IRSTCI01USM156N](https://fred.stlouisfed.org/series/IRSTCI01USM156N) |
| Tasa de México | [IRSTCI01MXM156N](https://fred.stlouisfed.org/series/IRSTCI01MXM156N) |
| Tasa de Colombia | [COLIRSTCI01STM](https://fred.stlouisfed.org/series/COLIRSTCI01STM) |
| Tipo de cambio MXN/USD | [EXMXUS](https://fred.stlouisfed.org/series/EXMXUS) |
| Tipo de cambio COP/USD | [COLCCUSMA02STM](https://fred.stlouisfed.org/series/COLCCUSMA02STM) |

El periodo previsto para el estudio es enero de 2018 a diciembre de 2023. Sin embargo, la intersección de fechas disponible en el archivo procesado actualmente contiene **60 observaciones mensuales, de enero de 2019 a diciembre de 2023**.

El diferencial se calcula como tasa local menos tasa de Estados Unidos. La variación mensual logarítmica del tipo de cambio se multiplica por 1200 para expresarla en términos anualizados. Antes de calcular rezagos y adelantos, las observaciones se ordenan por fecha.

## Resumen del informe

El informe aplica la regresión de Fama (1984) a las variaciones cambiarias anualizadas del mes siguiente y a los diferenciales de tasas. Bajo la UIRP, la hipótesis nula es $H_0: \alpha=0$ y $\beta=1$; la alternativa es que al menos una de estas condiciones no se cumpla. El modelo supone movilidad de capitales, expectativas racionales —los errores no deben estar relacionados con la información disponible, incluido el diferencial— y neutralidad al riesgo, es decir, una prima de riesgo cambiario igual a cero. Esto no significa que el tipo de cambio esté libre de riesgo. También requiere series estacionarias; en el informe se prueban las variaciones cambiarias, pero no los diferenciales de tasas. Para la inferencia se usan errores estándar Newey-West.

La especificación lineal de Fama (1984) no encuentra respaldo predictivo claro para la UIRP en esta muestra. Las pendientes estimadas son 7.134 para México (valor p Newey-West = 0.363) y -2.830 para Colombia (valor p = 0.195); ninguna es estadísticamente distinta de cero. R reporta `Multiple R-squared = 0.01181` para México y `Multiple R-squared = 0.0253` para Colombia.

No se realizaron pruebas específicas de $\beta=1$ ni la prueba conjunta de $\alpha=0$ y $\beta=1$. Por ello, no se puede afirmar que la hipótesis completa haya sido rechazada. Que las pendientes no sean estadísticamente distintas de cero tampoco demuestra que sean exactamente cero ni que la UIRP sea falsa: las estimaciones son imprecisas. Las pruebas de normalidad rechazan la normalidad de los residuos, un resultado compatible con colas pesadas y choques extremos como los asociados a la pandemia. Esto sugiere que la neutralidad al riesgo puede ser un supuesto poco realista, aunque las pruebas no demuestran por sí solas aversión al riesgo ni una prima cambiaria.

El *carry trade* no se mide directamente en este análisis. El diferencial de tasas representa un incentivo potencial y la variación cambiaria muestra parte del resultado, pero no se observan posiciones ni flujos de inversión; por eso, no se puede comprobar que estas operaciones ocurrieran ni medir su efecto.

Las referencias de las cinco series de FRED están en [`references.bib`](references.bib) y se citan en el documento R Markdown.

## Estructura

- `Data/Source-data/`: archivos CSV originales descargados de FRED.
- `Data/Csv/UIP_Mexico_Colombia_Clean.csv`: datos combinados y variables usadas en el análisis.
- `Script/01-cleaning_and_plots.R`: combina las series, calcula diferenciales y variaciones cambiarias, estima las regresiones y guarda los gráficos.
- `Plots/`: gráficos de México, Colombia y la regresión de Fama, en PDF y PNG.
- `Doc/Fama_explicacion.Rmd`: documento con la metodología, resultados y explicación de los gráficos.
- `references.bib`: referencias BibTeX para las series de datos utilizadas.
