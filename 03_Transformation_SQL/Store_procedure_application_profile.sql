IF OBJECT_ID('banking.upsert_Dimapplication_profile', 'P') IS NOT NULL
    DROP PROCEDURE banking.upsert_Dimapplication_profile;
GO

CREATE PROCEDURE banking.upsert_Dimapplication_profile
AS
BEGIN
    WITH IncomingData AS (
        SELECT DISTINCT 
            CAST(UPPER(payment_type) AS VARCHAR(50)) AS PaymentType,
            TRY_CAST(foreign_request AS INT) AS IsForeignRequest,
            TRY_CAST(keep_alive_session AS INT) AS KeepAliveSession
        FROM banking.raw_data
        WHERE payment_type IS NOT NULL
    )
    INSERT INTO banking.Dim_applicationprofile (PaymentType, IsForeignRequest, KeepAliveSession)
    SELECT src.PaymentType, src.IsForeignRequest, src.KeepAliveSession
    FROM IncomingData src
    LEFT JOIN banking.Dim_applicationprofile tgt
        ON src.PaymentType = tgt.PaymentType 
       AND src.IsForeignRequest = tgt.IsForeignRequest
       AND src.KeepAliveSession = tgt.KeepAliveSession
    WHERE tgt.PaymentType IS NULL;
END;
GO
