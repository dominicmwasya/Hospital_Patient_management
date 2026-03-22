-- 1. CREAING DATABASE AND LOADING DATA

CREATE DATABASE  IF NOT EXISTS hospital_db;
USE hospital_db;
CREATE TABLE patients (
	Patient_ID VARCHAR(10) PRIMARY KEY,
	Patient_Name VARCHAR(50),
	Age INT,
	Gender VARCHAR(10),
	Department VARCHAR(50),
	Diagnosis VARCHAR(50),
	Doctor VARCHAR(50),
	Admission_Type VARCHAR(20),
	Admission_Date DATE,
	Discharge_Date DATE,
	Treatment_Cost DECIMAL(10,2),
	Payment_Method VARCHAR(20),
	Status VARCHAR(20)
)
;

SELECT * FROM patients;


-- 2.DATA CLEANING

-- Checking for null values
SELECT
SUM(Age IS NULL) AS null_age,
SUM(Treatment_Cost IS NULL) AS null_cost,
SUM(Discharge_Date IS NULL) AS null_discharge
FROM patients;

-- Trim whitespace from all text columns
UPDATE patients
SET
Department = TRIM(Department),
Diagnosis = TRIM(Diagnosis),
Doctor = TRIM(Doctor),
Payment_Method = TRIM(Payment_Method),
Status = TRIM(Status);

-- Standardise Status capitalisation
UPDATE patients
SET Status = CONCAT(UPPER(LEFT(Status,1)), LOWER(SUBSTRING(Status,2)));

-- Flag bad discharge dates
SELECT Patient_ID, Admission_Date, Discharge_Date
FROM patients
WHERE Discharge_Date < Admission_Date;

-- Remove exact duplicates (keep earliest Patient_ID)
DELETE p1
FROM patients p1
INNER JOIN patients p2
ON p1.Patient_Name = p2.Patient_Name
AND p1.Admission_Date = p2.Admission_Date
AND p1.Patient_ID > p2.Patient_ID;




-- DATA TRANSFORMATION

-- Create new columns
ALTER TABLE patients
ADD COLUMN Length_of_Stay INT AFTER Discharge_Date,
ADD COLUMN Age_Group VARCHAR(20) AFTER Age,
ADD COLUMN Admission_Month VARCHAR(10) AFTER Admission_Date,
ADD COLUMN Admission_Week TINYINT AFTER Admission_Month,
ADD COLUMN Cost_Bucket VARCHAR(20) AFTER Treatment_Cost;

-- Length of stay in days
UPDATE patients
SET Length_of_Stay = DATEDIFF(Discharge_Date, Admission_Date);

-- Age grouping
UPDATE patients
SET Age_Group = CASE
	WHEN Age < 13 THEN 'Child (0-12)'
	WHEN Age BETWEEN 13 AND 17 THEN 'Teen (13-17)'
	WHEN Age BETWEEN 18 AND 35 THEN 'Young Adult (18-35)'
	WHEN Age BETWEEN 36 AND 60 THEN 'Middle Age (36-60)'
	ELSE 'Senior (60+)'
END;

-- Calendar features for time-series charts
UPDATE patients
SET
Admission_Month = DATE_FORMAT(Admission_Date, '%b'),
Admission_Week = WEEK(Admission_Date, 3);

-- Cost grouping
UPDATE patients
SET Cost_Bucket = CASE
	WHEN Treatment_Cost < 1000 THEN 'Low (<$1k)'
	WHEN Treatment_Cost BETWEEN 1000 AND 2499 THEN 'Medium ($1k-$2.5k)'
	WHEN Treatment_Cost BETWEEN 2500 AND 3999 THEN 'High ($2.5k-$4k)'
	ELSE 'Very High ($4k+)'
END;


-- PROBLEM ANALYSIS 

-- Problem 1
SELECT
	Department,
	Admission_Type,
	COUNT(*) AS Total_Patients,
	ROUND(AVG(Length_of_Stay), 1) AS Avg_LOS,
	ROUND(MIN(Length_of_Stay), 0) AS Min_LOS,
	ROUND(MAX(Length_of_Stay), 0) AS Max_LOS,
	ROUND(STDDEV(Length_of_Stay), 2) AS StdDev_LOS,
	SUM(Length_of_Stay > 7) AS Stays_Over_7d,
	ROUND(
	SUM(Length_of_Stay > 7) / COUNT(*) * 100, 1
	) AS Pct_Over_7d
FROM patients
GROUP BY Department, Admission_Type
ORDER BY Avg_LOS DESC;

-- Problem 2
SELECT
	Department,
	Diagnosis,
	Doctor,
	COUNT(*) AS Patient_Count,
	ROUND(AVG(Treatment_Cost), 2) AS Avg_Cost,
	ROUND(MIN(Treatment_Cost), 2) AS Min_Cost,
	ROUND(MAX(Treatment_Cost), 2) AS Max_Cost,
	ROUND(MAX(Treatment_Cost) - MIN(Treatment_Cost), 2) AS Cost_Range,
	ROUND(AVG(Treatment_Cost) /(SELECT AVG(Treatment_Cost) FROM patients) * 100, 1) AS Cost_Index_Pct
FROM patients
GROUP BY Department, Diagnosis, Doctor
HAVING Patient_Count >= 3
ORDER BY Avg_Cost DESC
LIMIT 20;

-- Problem 3
SELECT
	Department,
	Admission_Type,
	Diagnosis,
	COUNT(*) AS Total,
	SUM(Status = 'Discharged') AS Discharged,
	SUM(Status = 'Admitted') AS Admitted,
	SUM(Status = 'Transferred') AS Transferred,
	ROUND(SUM(Status = 'Discharged') / COUNT(*) * 100, 1) AS Pct_Discharged,
	ROUND(SUM(Status = 'Transferred') / COUNT(*) * 100, 1) AS Pct_Transferred,
	ROUND(AVG(Length_of_Stay), 1) AS Avg_LOS,
	ROUND(AVG(Treatment_Cost), 2) AS Avg_Cost
FROM patients
GROUP BY Department, Admission_Type, Diagnosis
ORDER BY Pct_Transferred DESC;

-- Problem 4
SELECT
Doctor,
COUNT(*) AS Total_Patients,
ROUND(
COUNT(*) / (SELECT COUNT(*) FROM patients) * 100
, 1) AS Pct_of_Total,
ROUND(AVG(Treatment_Cost), 2) AS Avg_Cost,
ROUND(AVG(Length_of_Stay), 1) AS Avg_LOS,
SUM(Admission_Type = 'Emergency') AS Emergency_Cases,
ROUND(
SUM(Admission_Type = 'Emergency') /
COUNT(*) * 100
, 1) AS Emergency_Pct,
ROUND(
AVG(Treatment_Cost) /
(SELECT AVG(Treatment_Cost) FROM patients) * 100
, 1) AS Doctor_Cost_Index,
GROUP_CONCAT(
DISTINCT Department
ORDER BY Department SEPARATOR ', '
) AS Departments_Covered
FROM patients
GROUP BY Doctor
ORDER BY Total_Patients DESC;

-- Problem 5
SELECT
YEAR(Admission_Date) AS Year,
MONTH(Admission_Date) AS Month_Num,
Admission_Month,
Department,
COUNT(*) AS Admissions,
ROUND(AVG(Treatment_Cost), 2) AS Avg_Cost,
ROUND(AVG(Length_of_Stay), 1) AS Avg_LOS,
SUM(COUNT(*)) OVER (
PARTITION BY Department
ORDER BY YEAR(Admission_Date),
MONTH(Admission_Date)
ROWS BETWEEN UNBOUNDED PRECEDING
AND CURRENT ROW
) AS Running_Total,
LAG(COUNT(*), 1, 0) OVER (
PARTITION BY Department
ORDER BY YEAR(Admission_Date),
MONTH(Admission_Date)
) AS Prev_Month,
ROUND(
(COUNT(*) -
LAG(COUNT(*),1,NULL) OVER (
PARTITION BY Department
ORDER BY YEAR(Admission_Date),
MONTH(Admission_Date)
)
) / NULLIF(
LAG(COUNT(*),1,NULL) OVER (
PARTITION BY Department
ORDER BY YEAR(Admission_Date),
MONTH(Admission_Date)
), 0
) * 100
, 1) AS MoM_Change_Pct
FROM patients
GROUP BY
YEAR(Admission_Date),
MONTH(Admission_Date),
Admission_Month,
Department
ORDER BY Year, Month_Num, Department;