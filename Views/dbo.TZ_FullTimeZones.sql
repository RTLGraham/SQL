SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[TZ_FullTimeZones] 
AS
    SELECT TZ.TimeZoneId, TZ.TimeZoneName, TZ.UtcOffset, TZN.Language, 
        TZN.LocationName, TZN.DisplayName, TZN.DaylightName, TZN.StandardName
    FROM TZ_TimeZones AS TZ
        JOIN TZ_Names AS TZN
            ON TZ.TimeZoneId = TZN.TimeZoneId
GO
