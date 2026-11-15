# Interest Rates and Exchange Rates: Mexico and Colombia

[Versión en español](README.md)

This project studies the relationship between interest-rate differentials and exchange-rate movements in Mexico and Colombia relative to the United States. It includes data preparation, charts, and an application of the Fama (1984) regression related to Uncovered Interest Rate Parity (UIRP).

## Data and period

The monthly series come from [FRED](https://fred.stlouisfed.org/):

| Variable | Series |
|---|---|
| U.S. interest rate | [IRSTCI01USM156N](https://fred.stlouisfed.org/series/IRSTCI01USM156N) |
| Mexico interest rate | [IRSTCI01MXM156N](https://fred.stlouisfed.org/series/IRSTCI01MXM156N) |
| Colombia interest rate | [COLIRSTCI01STM](https://fred.stlouisfed.org/series/COLIRSTCI01STM) |
| MXN/USD exchange rate | [EXMXUS](https://fred.stlouisfed.org/series/EXMXUS) |
| COP/USD exchange rate | [COLCCUSMA02STM](https://fred.stlouisfed.org/series/COLCCUSMA02STM) |

The intended study period is January 2018 through December 2023. However, the dates currently shared by all series in the processed file provide **60 monthly observations, from January 2019 through December 2023**.

Each interest-rate differential is calculated as the local rate minus the U.S. rate. The monthly log change in each exchange rate is multiplied by 1200 to express it at an annualized rate. Observations are sorted by date before leads and lags are calculated.

## Report summary

The report applies the Fama (1984) regression to annualized exchange-rate changes in the following month and interest-rate differentials. Under UIRP, the null hypothesis is $H_0: \alpha=0$ and $\beta=1$; the alternative is that at least one condition does not hold. The model assumes capital mobility, rational expectations (forecast errors are uncorrelated with available information, including the interest-rate differential), and risk neutrality, meaning a zero currency risk premium. This does not mean that exchange rates are risk-free. It also requires stationary series; the report tests the exchange-rate changes but not the interest-rate differentials. Newey-West standard errors are used for inference.

The linear Fama (1984) specification finds no clear predictive support for UIRP in this sample. The estimated slopes are 7.134 for Mexico (Newey-West p-value = 0.363) and -2.830 for Colombia (p-value = 0.195); neither is statistically different from zero. R reports `Multiple R-squared = 0.01181` for Mexico and `Multiple R-squared = 0.0253` for Colombia.

No individual tests of $\beta=1$ or joint test of $\alpha=0$ and $\beta=1$ were performed. Therefore, the complete hypothesis cannot be said to have been rejected. The insignificant slopes do not prove that they are exactly zero or that UIRP is false: the estimates are imprecise. The normality tests reject normally distributed residuals, consistent with heavy tails and extreme shocks such as those associated with the pandemic. This suggests that risk neutrality may be an unrealistic assumption, although the tests alone do not prove risk aversion or a currency risk premium.

Carry trade is not measured directly in this analysis. The interest-rate differential represents a potential incentive and exchange-rate changes show part of the outcome, but investor positions and capital flows are not observed; therefore, the analysis cannot confirm that these trades occurred or measure their effect.

BibTeX references for all five FRED series are in [`references.bib`](references.bib) and are cited in the R Markdown report.

## Repository structure

- `Data/Source-data/`: original CSV files downloaded from FRED.
- `Data/Csv/UIP_Mexico_Colombia_Clean.csv`: combined data and variables used in the analysis.
- `Script/01-cleaning_and_plots.R`: combines the series, calculates differentials and exchange-rate changes, estimates the regressions, and saves the charts.
- `Plots/`: charts for Mexico, Colombia, and the Fama regression in PDF and PNG formats.
- `Doc/Fama_explicacion.Rmd`: document describing the methodology, results, and charts.
- `references.bib`: BibTeX references for the data series.
