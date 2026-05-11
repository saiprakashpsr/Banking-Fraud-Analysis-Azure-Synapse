IF OBJECT_ID('banking.upsert_Dimdevice_profile', 'P') IS NOT NULL
    DROP PROCEDURE banking.upsert_Dimdevice_profile;
GO

CREATE PROCEDURE banking.upsert_Dimdevice_profile
AS
BEGIN
    WITH IncomingData AS (
        SELECT DISTINCT 
            CAST(UPPER(device_os) AS VARCHAR(50)) AS DeviceOS,
            CAST(UPPER(source) AS VARCHAR(50)) AS ApplicationSource
        FROM banking.raw_data
        WHERE device_os IS NOT NULL
    )
    INSERT INTO banking.Dim_deviceprofile (DeviceOS, ApplicationSource)
    SELECT src.DeviceOS, src.ApplicationSource
    FROM IncomingData src
    LEFT JOIN banking.Dim_deviceprofile tgt
        ON src.DeviceOS = tgt.DeviceOS 
       AND src.ApplicationSource = tgt.ApplicationSource
    WHERE tgt.DeviceOS IS NULL;
END;
GO
