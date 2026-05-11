IF OBJECT_ID('banking.Dim_deviceprofile', 'U') IS NOT NULL
    DROP TABLE banking.Dim_deviceprofile;
GO
CREATE TABLE banking.Dim_deviceprofile
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
)
AS
SELECT
ROW_NUMBER() OVER(ORDER BY device_os, source) AS DeviceProfileKey,
    CAST(UPPER(device_os) AS VARCHAR(100)) AS DeviceOS,
    CAST(UPPER(source) AS VARCHAR(100)) AS ApplicationSource,
    TRY_CAST(email_is_free AS INT) AS EmailIsFree,
    TRY_CAST(phone_home_valid AS INT) AS PhoneHomeValid,
    TRY_CAST(phone_mobile_valid AS INT) AS PhoneMobileValid
FROM 
    (SELECT DISTINCT device_os, source, email_is_free, phone_home_valid, phone_mobile_valid 
     FROM banking.raw_data WHERE device_os IS NOT NULL) AS DistinctDevices;
