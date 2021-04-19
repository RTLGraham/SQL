SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================
-- Author:		<Jamie Bartleet>
-- Create date: <2017-08-31>
-- Description:	<Update EventSpeeding table with Posted and Vehicle speed limits>
-- ================================================
CREATE PROCEDURE [dbo].[proc_EventSpeeding_ReprocessPostedSpeedLimits]
	@eventId BIGINT,
	@postedSpeedLimit TINYINT,
	@vehicleSpeedLimit TINYINT,
	@speedUnit CHAR
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @eventId BIGINT,
	--		@postedSpeedLimit TINYINT,
	--		@vehicleSpeedLimit TINYINT,
	--		@speedUnit CHAR
	        
	--		set @eventId = 2056812882
	--		set @postedSpeedLimit = 70
	--		set @vehicleSpeedLimit = 60
	--		set @speedUnit = 'M'
	
	DECLARE @evId BIGINT
	
	SELECT @evId = es.eventId
	FROM dbo.EventSpeeding es
	WHERE es.EventId = @eventId

	if (@evId IS NOT NULL)
	BEGIN
		UPDATE dbo.Eventspeeding 
			SET PostedSpeedLimit = @postedSpeedLimit,
				VehicleSpeedLimit = @vehicleSpeedLimit,
				SpeedUnit = @speedUnit
			where dbo.Eventspeeding.EventId = @evId
	END

END

GO
