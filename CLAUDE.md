# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Medicaid Expenditure Projection Model** — a data analysis and forecasting project. The primary goal is projecting Medicaid spending based on historical MFCU (Medicaid Fraud Control Unit) statistical data.

## Data

The `FY_YYYY_MFCU_Statistical_Chart.xlsx` files contain annual MFCU statistical reports spanning FY 2013–2025. These are the primary data inputs for any forecasting model built in this project.

Note: `FY_2014_MFCU_Statistical_Chart (1).xlsx` has a non-standard filename (includes `(1)`) — handle this when reading files programmatically.

## Project Description

Full project requirements and model specifications are documented in:
`Project_Description-Medicaid_Expenditure_Projection_Model (2).docx`

## Development Setup (if building a model)

No framework is set up yet. If implementing a forecasting model in Python, typical setup would be:

```bash
pip install pandas openpyxl scikit-learn matplotlib
```

To read all Excel data files consistently:
```python
import glob
files = sorted(glob.glob("FY_*_MFCU_Statistical_Chart*.xlsx"))
```
