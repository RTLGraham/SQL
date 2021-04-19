SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Vehicle_GetVideoCoachingHistoryVT]
(
	@evid BIGINT,
	@uid UNIQUEIDENTIFIER
)
AS

	--DECLARE @evid BIGINT,
	--		@uid UNIQUEIDENTIFIER
	--
	--SET @evid = 2
	--SET @uid = N'96097197-8B42-4CB4-B0DC-E1E436C06D26'



	DECLARE	@TimeZoneName VARCHAR(35)
	SET @TimeZoneName = dbo.UserPref(@uid, 600)


	SELECT  dbo.TZ_GetTime(vch.StatusDateTime, @TimeZoneName, @uid) AS StatusDateTime,
			vch.CoachingStatusId,
			u.Name AS UserName,
			vch.Comments AS Comment
	FROM dbo.VideoCoachingHistoryVT vch
		INNER JOIN dbo.[User] u ON vch.StatusUserId = u.UserID
	WHERE vch.Archived = 0
		AND vch.IncidentId = @evid
	ORDER BY vch.StatusDateTime


GO
