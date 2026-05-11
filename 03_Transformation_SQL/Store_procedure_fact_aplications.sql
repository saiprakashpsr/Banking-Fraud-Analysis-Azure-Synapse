IF OBJECT_ID('banking.Load_FactApplicatioons', 'P') IS NOT NULL
    DROP PROCEDURE banking.Load_FactApplicatioons;
GO
CREATE PROCEDURE banking.Load_FactApplicatioons
AS
BEGIN
    INSERT INTO banking.Fact_Applicatioons (
        CustomerProfileKey, DeviceProfileKey, ApplicationProfileKey, 
        IsFraud, ApplicationMonth, IntendedBalconAmount, CreditRiskScore,
        Velocity24H, SessionLengthInMinutes
    )
    SELECT
        c.CustomerProfileKey,
        d.DeviceProfileKey,
        a.ApplicationProfileKey,
        TRY_CAST(r.fraud_bool AS INT),
        TRY_CAST(r.month AS INT),
        CASE WHEN TRY_CAST(r.intended_balcon_amount AS DECIMAL(18,2)) < 0 THEN 0 ELSE TRY_CAST(r.intended_balcon_amount AS DECIMAL(18,2)) END,
        CASE WHEN TRY_CAST(r.credit_risk_score AS INT) < 0 THEN 0 ELSE TRY_CAST(r.credit_risk_score AS INT) END,
        TRY_CAST(r.velocity_24h AS FLOAT),
        NULLIF(TRY_CAST(r.session_length_in_minutes AS FLOAT), -1)
    
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
END;
