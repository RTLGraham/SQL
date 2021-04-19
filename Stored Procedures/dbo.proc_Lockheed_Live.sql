SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Lockheed_Live]
(
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN
	DECLARE @timezone VARCHAR(255)
    SELECT  @timezone = dbo.UserPref(@uid, 600)
    
    /* Check with Kim - they might need multiple orders on the map */
	--DECLARE @id BIGINT
	--SELECT @id = MAX(EventDataId)
	--FROM Test_Database.dbo.LockheedLive
	
	SELECT	EventDataId ,
			dbo.[TZ_GetTime](EventDateTime, @timezone, @uid) AS EventDateTime,
			Lat ,
			Lon ,
			Quantity ,
			PartNo
	FROM Test_Database.dbo.LockheedLive
	--WHERE EventDataId = @id
	
END

GO
