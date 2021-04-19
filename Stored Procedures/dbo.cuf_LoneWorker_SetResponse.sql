SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_LoneWorker_SetResponse]
(
	@lwid BIGINT,
	@uid UNIQUEIDENTIFIER,
	@responseID INT, 
	@comment NVARCHAR(MAX)
)
AS
	/*
	@responseID:
		1. Acknowledge
		2. Reject
		3. False Alarm
	*/

	INSERT INTO dbo.LW_LoneWorkerAck
	        (LoneWorkerId,
	         ResponseTypeId,
			 UserId,
	         ResponseDateTime,
	         Comment
	        )
	VALUES  (@lwid, -- LoneWorkerId - bigint
	         @responseID, -- ResponseTypeId - int
			 @uid,
	         GETUTCDATE(), -- ResponseDateTime - datetime
	         @comment  -- Comment - nvarchar(max)
	        )

	-- Cancel any outstanding Lone Worker escalations
	UPDATE dbo.TAN_TriggerEvent
	SET ProcessInd = 5 -- Ignore
	FROM dbo.LW_LoneWorker lw
	INNER JOIN dbo.Driver d ON d.DriverId = lw.DriverId
	INNER JOIN dbo.TAN_TriggerEvent tev ON tev.DriverIntId = d.DriverIntId
	WHERE lw.LoneWorkerId = @lwid
	  AND tev.CreationCodeId IN (145, 146) -- Lone Worker Escalations
	  
	SELECT @responseID AS 'Response'

GO
