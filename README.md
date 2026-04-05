# credit-risk-analysis-sql
“End-to-end credit risk analysis: from Power BI exploration to SQL-based risk modeling and validation.”

## Overview
Este proyecto analiza el riesgo crediticio utilizando SQL y Power BI, con foco en identificar qué variables explican el default.

## Problem
El modelo inicial en Power BI no segmentaba correctamente el riesgo, ya que la mayoría de los registros caían en un mismo grupo.

## Approach
- Limpieza y validación de datos en SQL
- Corrección del cálculo de default rate
- Segmentación basada en distribución (NTILE)
- Construcción de un risk profile

## Key Insights
- El debt-to-income ratio es el principal driver del riesgo
- Relación directa entre riesgo y default:
  - High Risk: 46%
  - Low Risk: 11%

## Tools
- SQL
- Power BI

El modelo final logra discriminar correctamente entre niveles de riesgo, permitiendo una mejor toma de decisiones crediticias.
