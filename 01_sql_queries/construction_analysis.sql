-- ============================================================
-- Construction Analytics - SQL Server Analysis
-- Project: National Infrastructure Projects - Budget Variance & Overrun Insights
-- ============================================================

-- Create Database
CREATE DATABASE ConstructionAnalytics;
GO

-- Use it
USE ConstructionAnalytics;
GO

-- Optional: Check it was created
SELECT name FROM sys.databases WHERE name = 'ConstructionAnalytics';

-- check table name
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';

-- 1. CHECK ROWS - This will work 100% now
SELECT '01_Projects_Master' as TableName, COUNT(*) as TotalRows FROM [dbo].[01_Projects_Master]
UNION ALL
SELECT '02_Cost_Overrun_Details', COUNT(*) FROM [dbo].[02_Cost_Overrun_Details]
UNION ALL
SELECT '03_Maintenance_Logs', COUNT(*) FROM [dbo].[03_Maintenance_Logs];

-- 2. CHECK SAMPLE
SELECT TOP 5 * FROM [dbo].[01_Projects_Master];

-- 3. YOUR BUSINESS INSIGHTS (for Portfolio)
-- Q1: Which Project Type has highest overrun?
SELECT Project_Type, COUNT(*) as Total_Projects, AVG(Overrun_Pct) as Avg_Overrun_Pct, SUM(Cost_Overrun_SAR) as Total_Overrun_SAR
FROM [01_Projects_Master]
GROUP BY Project_Type ORDER BY Avg_Overrun_Pct DESC;

-- Q2: #1 Reason for cost overrun?
SELECT Reason_For_Variance, COUNT(*) as Occurrences, SUM(Variance_SAR) as Total_Loss_SAR
FROM [02_Cost_Overrun_Details]
GROUP BY Reason_For_Variance ORDER BY Total_Loss_SAR DESC;

-- Q3: Equipment with most downtime?
SELECT Equipment, SUM(Downtime_Hours) as Total_Downtime, AVG(Maintenance_Cost_SAR) as Avg_Cost
FROM [03_Maintenance_Logs]
GROUP BY Equipment ORDER BY Total_Downtime DESC;

-- Clean old views if exist
DROP VIEW IF EXISTS vw_Project_KPIs;
DROP VIEW IF EXISTS vw_Cost_Analysis;
DROP VIEW IF EXISTS vw_Equipment_Risk;
GO

-- VIEW 1: For Power BI Dashboard Main KPIs
CREATE VIEW vw_Project_KPIs AS
SELECT 
  Project_ID, Project_Name, Project_Type, Region, Contractor, Project_Status,
  Planned_Budget_SAR, Actual_Cost_SAR, Cost_Overrun_SAR, Overrun_Pct,
  DATEDIFF(DAY, Start_Date, Planned_End_Date) as Planned_Duration,
  Delay_Days,
  CASE WHEN Overrun_Pct > 20 THEN 'High Risk' WHEN Overrun_Pct > 10 THEN 'Medium Risk' ELSE 'Low Risk' END as Risk_Category
FROM [01_Projects_Master];
GO

-- VIEW 2: For Cost Overrun Root Cause
CREATE VIEW vw_Cost_Analysis AS
SELECT c.*, p.Project_Type, p.Region, p.Overrun_Pct
FROM [02_Cost_Overrun_Details] c
JOIN [01_Projects_Master] p ON c.Project_ID = p.Project_ID;
GO

-- VIEW 3: For Equipment Dashboard
CREATE VIEW vw_Equipment_Risk AS
SELECT m.*, p.Project_Type, p.Contractor
FROM [03_Maintenance_Logs] m
JOIN [01_Projects_Master] p ON m.Project_ID = p.Project_ID;
GO

-- Test views
SELECT 'vw_Project_KPIs' as ViewName, COUNT(*) as Rows FROM vw_Project_KPIs
UNION ALL
SELECT 'vw_Cost_Analysis', COUNT(*) FROM vw_Cost_Analysis
UNION ALL
SELECT 'vw_Equipment_Risk', COUNT(*) FROM vw_Equipment_Risk;

-- what is my server name
SELECT @@SERVERNAME as Server_Name, @@SERVICENAME as Instance_Name, SERVERPROPERTY('MachineName') as Machine_Name;

-- 2. What is my current Database?
SELECT DB_NAME() as Current_Database;

-- Check sample
SELECT TOP 5 * FROM [dbo].[01_Projects_Master];
