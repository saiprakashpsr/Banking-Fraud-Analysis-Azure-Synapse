IF OBJECT_ID('banking.Fact_Applicatioons', 'U') IS NOT NULL
    DROP TABLE banking.Fact_Applicatioons;
GO
CREATE TABLE banking.Fact_Applicatioons
WITH(
    DISTRIBUTION = HASH(customerprofilekey),
    CLUSTERED COLUMNSTORE INDEX
)
AS
SELECT
    c.CustomerProfileKey,
    d.DeviceProfileKey,
    a.ApplicationProfileKey,
    ROW_NUMBER() OVER(
        PARTITION BY c.CustomerProfileKey 
        ORDER BY TRY_CAST(r.month AS INT) ASC
    ) AS ApplicationSequenceNumber,
    TRY_CAST(r.fraud_bool AS INT) AS IsFraud,
    TRY_CAST(r.month AS INT) AS ApplicationMonth,
    TRY_CAST(r.income AS DECIMAL(18,2)) AS Income,
    CASE 
        WHEN TRY_CAST(r.intended_balcon_amount AS DECIMAL(18,2)) < 0 THEN 0 
        ELSE TRY_CAST(r.intended_balcon_amount AS DECIMAL(18,2)) 
    END AS IntendedBalconAmount,
    CASE 
        WHEN TRY_CAST(r.credit_risk_score AS INT) < 0 THEN 0 
        ELSE TRY_CAST(r.credit_risk_score AS INT) 
    END AS CreditRiskScore,
    TRY_CAST(r.proposed_credit_limit AS DECIMAL(18,2)) AS ProposedCreditLimit,
    TRY_CAST(r.name_email_similarity AS FLOAT) AS NameEmailSimilarity,
    NULLIF(TRY_CAST(r.bank_months_count AS INT), -1) AS BankMonthsCount,
    NULLIF(TRY_CAST(r.prev_address_months_count AS INT), -1) AS PrevAddressMonthsCount,
    NULLIF(TRY_CAST(r.current_address_months_count AS INT), -1) AS CurrentAddressMonthsCount,
    NULLIF(TRY_CAST(r.session_length_in_minutes AS FLOAT), -1) AS SessionLengthInMinutes,
    NULLIF(TRY_CAST(r.days_since_request AS FLOAT), -1) AS DaysSinceRequest,
    TRY_CAST(r.zip_count_4w AS INT) AS ZipCount4W,
    TRY_CAST(r.velocity_6h AS FLOAT) AS Velocity6H,
    TRY_CAST(r.velocity_24h AS FLOAT) AS Velocity24H,
    TRY_CAST(r.velocity_4w AS FLOAT) AS Velocity4W,
    TRY_CAST(r.bank_branch_count_8w AS INT) AS BankBranchCount8W,
    TRY_CAST(r.date_of_birth_distinct_emails_4w AS INT) AS DOBDistinctEmails4W,
    TRY_CAST(r.device_distinct_emails_8w AS INT) AS DeviceDistinctEmails8W,
    TRY_CAST(r.device_fraud_count AS INT) AS DeviceFraudCount

FROM banking.raw_data r

    LEFT JOIN banking.Dim_CustomerProfile c 
    ON TRY_CAST(r.customer_age AS INT) = c.CustomerAge
    AND CAST(UPPER(r.employment_status) AS VARCHAR(50)) = c.EmploymentStatus
    AND CAST(UPPER(r.housing_status) AS VARCHAR(50)) = c.HousingStatus

LEFT JOIN banking.Dim_DeviceProfile d
    ON CAST(UPPER(r.device_os) AS VARCHAR(50)) = d.DeviceOS
    AND CAST(UPPER(r.source) AS VARCHAR(50)) = d.ApplicationSource

LEFT JOIN banking.Dim_ApplicationProfile a
    ON CAST(UPPER(r.payment_type) AS VARCHAR(50)) = a.PaymentType
    AND TRY_CAST(r.foreign_request AS INT) = a.IsForeignRequest
    AND TRY_CAST(r.keep_alive_session AS INT) = a.KeepAliveSession;
