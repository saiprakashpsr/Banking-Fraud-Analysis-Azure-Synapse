IF OBJECT_ID('banking.Dim_customerprofile', 'U') IS NOT NULL
    DROP TABLE banking.Dim_customerprofile;
GO
CREATE TABLE banking.Dim_customerprofile
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
)
AS
SELECT
    ROW_NUMBER() OVER(ORDER BY customer_age, employment_status) AS customerprofilekey,
    TRY_CAST(customer_age AS INT) AS CustomerAge,
    CAST(UPPER(employment_status) AS VARCHAR(100)) AS EmploymentStatus,
    CAST(UPPER(housing_status) AS VARCHAR(100)) AS HousingStatus,
    TRY_CAST(has_other_cards AS INT) HasOtherCards
FROM 
    (SELECT DISTINCT customer_age, employment_status, housing_status, has_other_cards 
     FROM banking.raw_data WHERE customer_age IS NOT NULL) AS DistinctCustomers; 
