# Medicaid Expenditure Projection Model — New York State

A data-driven forecasting project that projects **New York State Total Medicaid Expenditures** through FY 2035 using MFCU (Medicaid Fraud Control Unit) annual statistical reports from FY 2013–2025.

---

## Background

The New York State MFCU publishes annual statistical charts covering fraud investigations, indictments, convictions, civil recoveries, grant expenditures, and total Medicaid spending. This project ingests those 13 years of data and applies multiple statistical and machine-learning models to project future spending trajectories.

---

## Data

| Source | Files | Coverage |
|--------|-------|----------|
| MFCU Statistical Charts | `FY_YYYY_MFCU_Statistical_Chart.xlsx` | FY 2013 – FY 2025 (13 annual files) |

Key columns extracted per state per year:

- Total / Fraud / Abuse-Neglect Investigations, Indictments, Convictions
- Civil Settlements & Judgments, Total Recoveries
- MFCU Grant Expenditures
- **Total Medicaid Expenditures** ← primary forecast target
- Staff On Board

---

## Models

### `regression_model.py` — Regression Baseline

Three time-series regression models fit on FY 2013–2025 NY data, extrapolated to FY 2036:

| Model | Description |
|-------|-------------|
| Linear Regression | Straight-line trend fit to fiscal year |
| Polynomial Regression (deg 2) | Quadratic fit |
| Polynomial Regression (deg 3) | Cubic fit |

A secondary **multi-feature linear regression** uses operational MFCU metrics (investigations, indictments, convictions, recoveries, grant expenditures, staff) as predictors, trained on FY 2013–2022 and tested on FY 2023–2025.

Output: `regression_results.png`

---

### `all_models.py` — Four-Model Comparison

Adds two time-series methods alongside the best polynomial regression:

| Model | Config | Notes |
|-------|--------|-------|
| Polynomial Regression | Best degree (1–3) by train R² | Trend-extrapolation baseline |
| ARIMA | Auto-selected order (p,d,q) by AIC | Classical time-series |
| Holt-Winters | Additive trend, no seasonality | **Recommended model** |
| Prophet | Linear trend, no sub-annual seasonality | Facebook/Meta forecasting library |

Train/test split: **FY 2013–2022 training, FY 2023–2025 held-out test**.

Output: `all_models_results.png`, `forecast_table.csv`

---

## Results

### Model Accuracy (Test Set FY 2023–2025)

> *Lower is better. Values in $Billions / percent.*

| Model | MAE ($B) | RMSE ($B) | MAPE (%) |
|-------|----------|-----------|----------|
| Poly Regression | (high — see note) | — | — |
| ARIMA | — | — | — |
| **Holt-Winters** | — | — | — |
| Prophet | — | — | — |

*Run `all_models.py` to populate exact figures — they print to stdout and are reflected in the chart.*

### 10-Year Forecast Summary (FY 2026–2035, $Billions)

| Year | Poly Regression | ARIMA | Holt-Winters | Prophet |
|------|----------------|-------|--------------|---------|
| 2026 | $135.49B | $102.70B | $101.37B | $101.43B |
| 2027 | $161.20B | $102.70B | $105.21B | $105.26B |
| 2028 | $193.05B | $102.70B | $109.04B | $109.11B |
| 2029 | $231.72B | $102.70B | $112.88B | $112.94B |
| 2030 | $277.89B | $102.70B | $116.71B | $116.77B |
| 2031 | $332.23B | $102.70B | $120.55B | $120.61B |
| 2032 | $395.43B | $102.70B | $124.38B | $124.45B |
| 2033 | $468.17B | $102.70B | $128.22B | $128.28B |
| 2034 | $551.12B | $102.70B | $132.05B | $132.12B |
| 2035 | $644.96B | $102.70B | $135.89B | $135.95B |

**Key observation:** Polynomial regression diverges exponentially (reaching ~$645B by 2035), while ARIMA, Holt-Winters, and Prophet converge on a much more conservative linear growth path (~$102–136B). The **Holt-Winters** model is recommended as it captures the additive upward trend without overfitting and produces credible 95% confidence intervals.

---

## Visualizations

### `regression_results.png`
Four-panel chart:
1. Regression lines + forecast overlay (Linear, Poly-2, Poly-3)
2. Bar chart — historical actuals vs. best-model forecast to FY 2036
3. Historical in-sample fit comparison across all three regression models
4. Feature coefficients from the multi-feature regression (MFCU operational metrics)

### `all_models_results.png`
Four-panel chart:
1. Conservative models (ARIMA, Holt-Winters, Prophet) with 95% CI shading
2. Model accuracy comparison — grouped MAE / RMSE / MAPE horizontal bars
3. Holt-Winters deep-dive with labeled forecast values and CI band
4. Grouped bar chart comparing all four models at FY 2026, 2030, and 2035

---

## Setup

```bash
pip install pandas openpyxl scikit-learn matplotlib statsmodels prophet
```

### Run

```bash
# Regression baseline (outputs regression_results.png)
python regression_model.py

# All four models (outputs all_models_results.png + forecast_table.csv)
python all_models.py
```

Both scripts auto-discover data files via:
```python
glob.glob("FY_*_MFCU_Statistical_Chart*.xlsx")
```

---

## Repository Structure

```
├── FY_YYYY_MFCU_Statistical_Chart.xlsx   # Raw data (FY 2013–2025, 13 files)
├── regression_model.py                   # Linear / Polynomial / Multi-feature models
├── all_models.py                         # ARIMA + Holt-Winters + Prophet comparison
├── regression_results.png                # Output chart from regression_model.py
├── all_models_results.png                # Output chart from all_models.py
└── forecast_table.csv                    # 10-year forecast table (all four models)
```

---

## Limitations

- **Small sample (n=13):** Only 13 annual observations limit statistical power for complex models.
- **Polynomial extrapolation:** High-degree polynomial fits should not be used for long-horizon projections — they are included for comparison only.
- **No external drivers:** The models do not incorporate policy changes, enrollment shifts, inflation, or demographic trends.
- **ARIMA flat forecast:** The auto-selected ARIMA order produces a near-constant forecast, suggesting the model found no exploitable trend structure beyond the mean — likely a consequence of the small sample size.
