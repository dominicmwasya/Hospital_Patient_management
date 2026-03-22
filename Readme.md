#  Hospital Patient Management — Data Analysis Portfolio Project

A end-to-end data analysis project built with **MySQL** and **Power BI**, exploring a hospital patient management dataset of 500 records across 7 departments and 12 months of 2024.

---

##  Project Overview

This project analyses hospital patient data to uncover operational and clinical insights across five key problem areas — length of stay, treatment costs, patient outcomes, doctor workload, and admission trends. The final deliverable is a single-page interactive Power BI dashboard connected to a cleaned and engineered MySQL database.

The project demonstrates skills in:
- Relational database design and SQL querying
- Data cleaning and feature engineering in MySQL
- Analytical querying including window functions and conditional aggregation
- DAX measure creation in Power BI
- Dashboard design and data storytelling

---

## Dataset Description

| Field | Type | Description |
|---|---|---|
| `Patient_ID` | VARCHAR | Unique patient identifier |
| `Patient_Name` | VARCHAR | Patient name |
| `Age` | INT | Patient age in years |
| `Gender` | VARCHAR | Male / Female |
| `Department` | VARCHAR | One of 7 hospital departments |
| `Diagnosis` | VARCHAR | One of 19 diagnosis types |
| `Doctor` | VARCHAR | One of 6 treating doctors |
| `Admission_Type` | VARCHAR | Emergency / Routine / Referral |
| `Admission_Date` | DATE | Date of admission |
| `Discharge_Date` | DATE | Date of discharge |
| `Treatment_Cost` | DECIMAL | Cost in USD ($293 – $4,979) |
| `Payment_Method` | VARCHAR | Cash / Card / Insurance |
| `Status` | VARCHAR | Discharged / Admitted / Transferred |

**Records:** 500 &nbsp;|&nbsp; **Period:** January – December 2024 &nbsp;|&nbsp; **Departments:** 7 &nbsp;|&nbsp; **Doctors:** 6

---

##  Tools & Technologies

| Tool | Purpose |
|---|---|
| **MySQL ** | Database setup, data cleaning, feature engineering, analytical queries |
| **Power BI Desktop** | Data modelling, DAX measures, dashboard design |


---

##  Problem Statements

### Problem 1 — Length of Stay Analysis
> Which departments and admission types are associated with the longest average length of stay, and what clinical factors drive these differences?

Explores LOS patterns across departments and admission types. Key metrics include average LOS per department, percentage of stays exceeding 7 days, and top diagnosis–department pairs by mean LOS.

---

### Problem 2 — Treatment Cost Drivers
> What patient and clinical characteristics are most strongly associated with high treatment costs, and are there significant cost disparities across doctors or departments?

Analyses cost variation by department, diagnosis, and doctor. Includes a doctor cost index comparing each doctor's average cost to the hospital-wide average.

---

### Problem 3 — Patient Outcome Analysis
> Can patient demographic and clinical features predict whether a patient will be discharged, remain admitted, or be transferred?

Breaks down discharge, admission, and transfer rates by department, admission type, and diagnosis. Highlights the highest-risk patient profiles for transfer.

---

### Problem 4 — Doctor Workload Equity
> Is patient workload distributed equitably among doctors, and are certain doctors disproportionately burdened with high-cost or high-severity cases?

Compares patient volume, average cost, average LOS, and emergency case share across all 6 doctors. A workload index flags doctors carrying above-average caseloads.

---

### Problem 5 — Admission Trends & Seasonality
> Are there identifiable seasonal or monthly patterns in patient admissions, and do specific diagnoses show predictable demand peaks?

Analyses monthly admission volumes across 2024 using window functions for running totals and month-over-month change. Identifies peak and trough months per department and diagnosis.

---

##  Dashboard Screenshots

> *Screenshots will be added once the Power BI dashboard is published.*

| Page | Preview |
|---|---|
| One-page dashboard | `https://github.com/dominicmwasya/Hospital_Patient_management/blob/b4e0069e7d5eced00e3d361d9e6c758cd9bdd4ba/Hospital_Patient_Management.png` |





*Dataset contains anonymised synthetic patient data for educational purposes only.*
