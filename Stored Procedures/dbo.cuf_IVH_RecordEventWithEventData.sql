SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_IVH_RecordEventWithEventData]
(
	@trackerid VARCHAR(50),
	@ccid SMALLINT,
	@eventdt DATETIME,
	@evtdname VARCHAR(30),
	@evtstring VARCHAR(1024)
)
AS
	--DECLARE @trackerid VARCHAR(50),
	--		@ccid SMALLINT,
	--		@eventdt DATETIME,
	--		@evtdname VARCHAR(30),
	--		@evtstring VARCHAR(1024)

	--SELECT	@trackerid = '4532099871',
	--		@ccid = 99,
	--		@eventdt = GETUTCDATE(),
	--		@evtdname = 'OTAP',
	--		@evtstring = 'failure'
	

	DECLARE @vintid INT

	SET @vintid = NULL

	SELECT TOP 1 @vintid = v.VehicleIntId
	FROM dbo.Vehicle v
		INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
	WHERE v.Archived = 0 
		AND i.Archived = 0 
		AND i.TrackerNumber = @trackerid
	ORDER BY v.LastOperation DESC

	DECLARE @result TABLE
	(
		CustomerIntId INT,
		VehicleId UNIQUEIDENTIFIER,
		EventId BIGINT,
		Success BIT
	)

	IF @vintid IS NOT NULL
	BEGIN

		DECLARE @customerintid INT,
				@vid UNIQUEIDENTIFIER,
				@eid BIGINT
		
		DECLARE @tmpResult TABLE (EventId BIGINT)
		INSERT INTO @tmpResult 
		EXECUTE [dbo].[proc_WriteEventNewNonIdTemp] 
		   @trackerid
		  ,'No ID'
		  ,@ccid
		  ,0
		  ,0
		  ,0
		  ,0
		  ,0
		  ,0
		  ,0
		  ,@eventdt
		  ,0
		  ,0
		  ,0
		  ,0
		  ,0
		  ,0
		  ,0
		  ,NULL
		  ,@evtstring
		  ,@evtdname
		  ,@customerintid OUTPUT
		  ,@vid OUTPUT
		  ,@eid OUTPUT
		  ,0
		  ,0
		  ,0
		  ,0
		  ,0
		  ,0
		  ,0
		  ,0
		  ,0
		  ,0
		  ,0
		  ,0

		INSERT INTO @result
		        ( CustomerIntId ,
		        VehicleId ,
		        EventId ,
		        Success
		        )
		VALUES  ( @customerintid,
				@vid,
				@eid,
				1
		        )
	END
	ELSE BEGIN
		INSERT INTO @result
		        ( CustomerIntId ,
		        VehicleId ,
		        EventId ,
		        Success
		        )
		VALUES  ( NULL,
				NULL,
				NULL,
				0
		        )
	END

	SELECT CustomerIntId ,
           VehicleId ,
           EventId ,
           Success
	FROM @result


GO
