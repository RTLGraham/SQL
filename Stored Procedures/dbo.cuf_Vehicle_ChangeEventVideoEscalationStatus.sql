SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Vehicle_ChangeEventVideoEscalationStatus]
(
	@uid UNIQUEIDENTIFIER,
	@iid BIGINT,
	@newStatus BIT,
	@comment NVARCHAR(MAX)
)
AS
	DECLARE @oldStatus BIT,
			@coachingStatus INT,
			@driverId UNIQUEIDENTIFIER

	/*
	1. Check if the status did change (app layer checks it, but it's still necessary to double-check in case the SP is called from somwhere else
	2. If the status has changed - update the status, raise the trigger event, etc.
	*/
	SELECT TOP 1 @oldStatus = CASE WHEN os.ObjectShareId IS NOT NULL THEN 1 ELSE 0 END, @coachingStatus = i.CoachingStatusId, @driverId = d.DriverId
	FROM dbo.CAM_Incident i
		INNER JOIN dbo.Driver d ON d.DriverIntId = i.DriverIntId
		LEFT OUTER JOIN dbo.ObjectShare os ON i.IncidentId = os.ObjectIntId AND os.ObjectTypeId = 1 AND os.Archived = 0
	WHERE i.IncidentId = @iid
	
	IF @oldStatus != @newStatus
	BEGIN
		IF @newStatus = 1
			INSERT INTO dbo.ObjectShare (ObjectId, ObjectIntId, ObjectTypeId, EntityId, EntityTypeId, LastModifiedDateTime, Archived)
			VALUES  (NULL, @iid, 1, @driverId, 2, GETDATE(), 0)
		ELSE
			UPDATE dbo.ObjectShare
			SET Archived = 1
			WHERE ObjectIntId = @iid AND ObjectTypeId = 1 AND EntityId = @driverId

		IF @comment IS NOT NULL AND @comment != ''
		BEGIN
			INSERT INTO dbo.VideoCoachingHistory
					( IncidentId ,
					  CoachingStatusId ,
					  StatusUserId ,
					  StatusDateTime ,
					  Comments ,
					  LastOperation ,
					  Archived
					)
			VALUES  ( @iid , -- EventVideoId - bigint
					  @coachingStatus , -- CoachingStatusId - smallint
					  @uid , -- StatusUserId - uniqueidentifier
					  GETUTCDATE() , -- StatusDateTime - datetime
					  @comment , -- Comments - nvarchar(max)
					  GETDATE() , -- LastOperation - smalldatetime
					  0  -- Archived - bit
					)
		END

	END




GO
