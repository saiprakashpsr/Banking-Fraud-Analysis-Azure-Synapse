IF OBJECT_ID('banking.Dim_ApplicationProfile', 'U') IS NOT NULL
    DROP TABLE banking.Dim_ApplicationProfile;
GO
CREATE TABLE banking.Dim_ApplicationProfile
WITH
(
    DISTRIBUTION = REPLICATE, 
    CLUSTERED COLUMNSTORE INDEX
)
AS
SELECT 
    ROW_NUMBER() OVER(ORDER BY payment_type) AS ApplicationProfileKey,
    CAST(UPPER(payment_type) AS VARCHAR(50)) AS PaymentType,
    TRY_CAST(foreign_request AS INT) AS IsForeignRequest,
    TRY_CAST(keep_alive_session AS INT) AS KeepAliveSession
FROM 
    (SELECT DISTINCT payment_type, foreign_request, keep_alive_session 
     FROM banking.raw_data WHERE payment_type IS NOT NULL) AS DistinctApps;
