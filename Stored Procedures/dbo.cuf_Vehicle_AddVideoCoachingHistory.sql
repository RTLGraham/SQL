SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_AddVideoCoachingHistory]
(
	@evid BIGINT,
	@uid UNIQUEIDENTIFIER,
	@comment NVARCHAR(MAX)
)
AS
	DECLARE @status INT
	
	SELECT @status = CoachingStatusId
	FROM dbo.CAM_Incident
	WHERE IncidentId = @evid
	
	INSERT INTO dbo.VideoCoachingHistory
	        ( IncidentId ,
	          CoachingStatusId ,
	          StatusUserId ,
	          StatusDateTime ,
	          Comments ,
	          LastOperation ,
	          Archived
	        )
	VALUES  ( @evid , -- EventVideoId - bigint
	          @status , -- CoachingStatusId - smallint
	          @uid , -- StatusUserId - uniqueidentifier
	          GETUTCDATE() , -- StatusDateTime - datetime
	          @comment , -- Comments - nvarchar(max)
	          GETDATE() , -- LastOperation - smalldatetime
	          0  -- Archived - bit
	        )


GO
