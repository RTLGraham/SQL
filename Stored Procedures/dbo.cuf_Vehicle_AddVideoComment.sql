SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Vehicle_AddVideoComment]
(
	@uid UNIQUEIDENTIFIER,
	@iid BIGINT,
	@coachingStatus INT,
	@comment NVARCHAR(MAX)
)
AS
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


GO
