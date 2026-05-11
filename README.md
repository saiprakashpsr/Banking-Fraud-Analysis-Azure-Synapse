**Azure Data Engineering | Synapse Analytics | ADF | Power BI**

## 🚀 Project Overview
This project implements an automated, enterprise-grade ELT pipeline designed to ingest, transform, and analyze banking application data for fraud detection. The architecture follows a **Medallion Architecture** (Staging to Gold) using Azure Synapse Dedicated SQL Pools and Azure Data Factory for orchestration.

## 🏗️ Architecture & Tech Stack
* **Ingestion:** Azure Data Factory (ADF) orchestrating data movement from ADLS Gen2.
* **Data Warehouse:** Azure Synapse Analytics (Dedicated SQL Pool).
* **Data Modeling:** Kimball Star Schema (3 Dimensions, 1 Fact Table).
* **Optimization:** Clustered Columnstore Indexing & Hash Distribution.
* **Visualization:** Power BI (DirectQuery Mode for live analytics).

## 🛠️ Key Engineering Implementations

### 1. The "Anti-Join" Upsert Pattern
To maintain optimal read performance in Power BI, I utilized **Round Robin** and **Replicated** distributions for dimension tables. Since Synapse limits standard `MERGE` operations on these distributions, I engineered a high-performance **Anti-Join pattern** using `INSERT...LEFT JOIN...WHERE Target IS NULL` logic within stored procedures. This ensures zero data duplication while maintaining schema integrity.

### 2. Data Sanitization & Transformation
Raw data was transformed into a refined Gold layer using specialized SQL logic:
* **Case Standardization:** Applied `UPPER()` to categorical features (OS, Source) to prevent duplicate profiles due to string casing inconsistencies.
* **Numeric Sanitization:** Implemented `CASE` statements to handle anomalous negative values in financial metrics (Credit Scores, Balances).
* **Schema Enforcement:** Used `TRY_CAST` and `NULLIF` to convert sentinel values (e.g., -1) into proper SQL `NULL` types for accurate statistical reporting.

### 3. Star Schema Design
* **Dim_customerprofile:** SCD Type 1 tracking applicant demographics.
* **Dim_deviceprofile:** Hardware and source attribution.
* **Dim_applicationprofile:** Session-level behavioral attributes.
* **Fact_Applications:** Centralized metrics (Income, Velocity, Fraud Flags) linked via Surrogate Keys.

## 📊 Analytics Insights
The Power BI dashboard (connected via **DirectQuery**) provides:
* **Bot Attack Detection:** Scatter plot analysis isolating low-session/high-velocity outliers.
* **Platform Vulnerability:** Real-time breakdown of fraud volume by Device OS (identifying Windows as a high-risk vector).
* **Financial Exposure:** Quantifying the "Total Fraud Exposure" using custom DAX measures.

## 📂 Repository Structure
* `01_Ingestion_ADF/`: Pipeline JSON exports and orchestration logic.
* `02_Staging_Layer/`: DDL for raw ingestion tables (Heap/Round Robin).
* `03_Transformation_SQL/`: Stored procedures containing the Anti-Join and data-cleaning logic.
* `04_Gold_Layer/`: Final Star Schema DDL with Columnstore Indexing.
* `05_Analytics_PowerBI/`: PBIX report files and dashboard previews.

## 📝 Usage
1. Execute scripts in `02_Staging_Layer` to initialize the environment.
2. Deploy Stored Procedures in `03_Transformation_SQL`.
3. Import the ADF Pipeline from `01_Ingestion_ADF` and trigger the run.
4. Open the Power BI report in `05_Analytics_PowerBI` to view live insights.
