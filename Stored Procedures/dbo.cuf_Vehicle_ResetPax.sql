SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_ResetPax]
(
	@vehicleId UNIQUEIDENTIFIER,
	@resetAt DATETIME = NULL,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN

-- This stored procedure is currently unused but can be implemented in the future to reset pax counts at a given date in the past
	
--	DECLARE	@vehicleId UNIQUEIDENTIFIER,
--			@resetAt DATETIME,
--			@uid UNIQUEIDENTIFIER
--			
--	SET @vehicleid = N'A6C52170-4395-4850-9696-2FC05D596618'
--	SET @resetAt = '2014-04-17 11:41'
--	SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

	DECLARE @utcReset DATETIME,
			@rowid BIGINT,
			@d1in INT,
			@d2in INT,
			@d3in INT,
			@d1out INT,
			@d2out INT,
			@d3out INT,
			@maxpax INT,
			@startcount INT,
			@endcount INT
			
	SET @utcReset = dbo.TZ_ToUtc(@resetAt, DEFAULT, @uid)
	SET @startcount = 0
	SET @endcount = 0

	DECLARE PCCursor CURSOR FAST_FORWARD READ_ONLY
	FOR
		SELECT PassengerCountId, MaxPax, DeltaInDoor1, DeltaInDoor2, DeltaInDoor3, DeltaOutDoor1, DeltaOutDoor2, DeltaOutDoor3
		FROM dbo.PassengerCount pc
		INNER JOIN dbo.Vehicle v ON pc.VehicleId = v.VehicleId
		WHERE pc.VehicleId = @vehicleId
		  AND DoorsOpenDateTime >= @utcReset
		ORDER BY PassengerCountId

	OPEN PCCursor
	FETCH NEXT FROM PCCursor INTO @rowid, @maxpax, @d1in, @d2in, @d3in, @d1out, @d2out, @d3out
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SELECT @endcount = CASE WHEN @startcount + @d1in + @d2in + @d3in - @d1out - @d2out - @d3out > @maxpax
								THEN @maxpax
								ELSE CASE WHEN @startcount + @d1in + @d2in + @d3in - @d1out - @d2out - @d3out < 0 
									THEN 0
									ELSE @startcount + @d1in + @d2in + @d3in - @d1out - @d2out - @d3out
								END
						   END
						   
		UPDATE dbo.PassengerCount
		SET StartPassengerCount = @startcount, 
			EndPassengerCount = @endcount,
			CalibrationFlag = 2
		WHERE PassengerCountId = @rowid
		
		SET @startcount = @endcount

		FETCH NEXT FROM PCCursor INTO @rowid, @maxpax, @d1in, @d2in, @d3in, @d1out, @d2out, @d3out
		
	END

	CLOSE PCCursor
	DEALLOCATE PCCursor

	-- Finally update VehicleLatestEvent
	UPDATE dbo.VehicleLatestEvent
	SET PaxCount = @endcount
	WHERE VehicleId = @vehicleid
	
END
GO
