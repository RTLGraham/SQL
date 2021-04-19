SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_GetVideoCoachingHistory]
(
	@evid BIGINT,
	@uid UNIQUEIDENTIFIER
)
AS
	--DECLARE @evid BIGINT,
	--		@uid UNIQUEIDENTIFIER
	
	--SET @evid = 18996279
	--SET @uid = N'16D7400E-E5AB-4919-B2AB-715442EB506B'

	DECLARE	@TimeZoneName VARCHAR(35)
	SET @TimeZoneName = dbo.UserPref(@uid, 600)

	IF @TimeZoneName IS NULL
	BEGIN
		DECLARE @cid UNIQUEIDENTIFIER
		SELECT @cid = c.CustomerId
		FROM dbo.Customer c 
			INNER JOIN dbo.CustomerDriver cd ON cd.CustomerId = c.CustomerId
			INNER JOIN dbo.Driver d ON cd.DriverId = d.DriverId
		WHERE d.DriverId = @uid AND d.Archived = 0 AND cd.Archived = 0 AND cd.EndDate IS NULL
		ORDER BY d.LastOperation DESC
        
		SET @TimeZoneName = dbo.CustomerPref(@cid, 600)
	END

	SELECT  ISNULL(dbo.TZ_GetTime(vch.StatusDateTime, @TimeZoneName, @uid), vch.StatusDateTime) AS StatusDateTime,
			vch.CoachingStatusId,
			ISNULL(u.Name, dbo.FormatDriverNameByUser(d.DriverId, NULL)) AS UserName,
			vch.Comments AS Comment
	FROM dbo.VideoCoachingHistory vch
		LEFT JOIN dbo.[User] u ON vch.StatusUserId = u.UserID
		LEFT JOIN dbo.Driver d ON vch.StatusUserId = d.DriverId
	WHERE vch.Archived = 0
		AND vch.IncidentId = @evid
	ORDER BY vch.StatusDateTime


GO
