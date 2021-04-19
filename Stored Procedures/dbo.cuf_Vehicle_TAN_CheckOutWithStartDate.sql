SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_TAN_CheckOutWithStartDate]
(
	@userId UNIQUEIDENTIFIER,
	@vehicleId UNIQUEIDENTIFIER,
	@reason NVARCHAR(MAX),
	@fromTime DATETIME,
	@toTime DATETIME
)
AS
BEGIN
	
	DECLARE @checkoutCount INT

	-- Check to see if the vehicle is already checked out
	SELECT @checkoutCount = COUNT(*)
	FROM dbo.TAN_EntityCheckOut
	WHERE EntityId = @vehicleId
	  AND (@fromTime BETWEEN CheckOutDateTime AND CheckInDateTime OR @toTime BETWEEN CheckInDateTime AND CheckInDateTime)

	IF @checkoutCount > 0 -- vehicle already checked out
	BEGIN 
		SELECT -1 AS returnStatus
	END ELSE	
	BEGIN
		INSERT INTO dbo.TAN_EntityCheckOut (
				EntityId,
				CheckOutDateTime,
				CheckInDateTime,
				CheckOutUserId,
				CheckOutReason,
				AnalogData0,
				AnalogData1,
				AnalogData2,
				AnalogData3)
		SELECT	VehicleId,
				dbo.TZ_ToUtc(@fromTime, DEFAULT, @userId),
				dbo.TZ_ToUtc(@toTime, DEFAULT, @userId),
				@userid,
				@reason, 
				AnalogData0,
				AnalogData1,
				AnalogData2,
				AnalogData3
		FROM dbo.VehicleLatestEvent vle
		WHERE vle.VehicleId = @vehicleid

		SELECT 0 AS returnStatus
	END	

END

GO
