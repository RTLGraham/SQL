SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_AddEventVideoComment]
(
	@evid BIGINT,
	@uid UNIQUEIDENTIFIER,
	@comment NVARCHAR(MAX)
)
AS
	DECLARE @currentStatus INT
	SET @currentStatus = NULL

	SELECT @currentStatus = CoachingStatusId
	FROM dbo.CAM_Incident
	WHERE IncidentId = @evid	

	IF @currentStatus IS NOT NULL AND @comment IS NOT NULL AND LTRIM(RTRIM(@comment)) != ''
	BEGIN
		INSERT INTO dbo.VideoCoachingHistory (IncidentId, CoachingStatusId, StatusUserId, StatusDateTime, Comments, LastOperation, Archived)
		VALUES  (@evid, @currentStatus, @uid, GETUTCDATE(), @comment, GETDATE(), 0)
	END

GO
