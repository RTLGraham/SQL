SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[TZ_GetFullTimeZones]
      @Language NCHAR(6) = N'en'
AS
    SELECT TimeZoneId, TimeZoneName, UtcOffset, Language, LocationName, DisplayName, DaylightName, StandardName
    FROM TZ_FullTimeZones
    WHERE Language = @Language
    ORDER BY TimeZoneId

GO
