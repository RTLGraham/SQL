SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_BulkInsertRTL2Messaging]
AS
BEGIN
	-- Update the MessageHistory table
	DECLARE @messageId INT,
			@eventName VARCHAR(30),
			@EventDataString VARCHAR(1024),
			@response VARCHAR(1024),
			@eventId BIGINT,
			@vid UNIQUEIDENTIFIER,
			@lat FLOAT,
			@lon FLOAT

	DECLARE Event_data_cur CURSOR FAST_FORWARD READ_ONLY FOR
		-- parse and move *before* it leaves the temp table. This keeps the result set sizes down.
		SELECT EventDataName, EventDataString, EventId
		FROM dbo.EventDataTemp
		WHERE Archived = 0
		AND (EventDataName = 'DMSGD' OR EventDataName = 'DMSGR')

	OPEN Event_data_cur
	FETCH NEXT FROM Event_data_cur INTO @eventName, @EventDataString, @eventId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @vid = dbo.GetVehicleIdFromInt(VehicleIntId), @lat = Lat, @lon = Long
		FROM dbo.Event
		WHERE EventId = @eventId	-- not ideal, check with J.F.

		IF @eventName = 'DMSGD'
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION
				-- if it's a driver stop message then there won't be anything in the database
				-- already for this
				INSERT INTO dbo.MessageHistory (MessageText, Lat, Long, [Date], Archived)
				VALUES (@EventDataString, @lat, @lon, GETDATE(), 0)
				
				SELECT @messageId = @@IDENTITY
				
				INSERT INTO dbo.MessageVehicle (MessageId, TimeSent, MessageStatusHardwareId, MessageStatusWetwareId, VehicleId, Archived)
				VALUES (@messageId, GETDATE(), 2, NULL, @vid, 0)

				INSERT INTO dbo.MessageStatusHistory (MessageId, MessageStatusId, LastModified)
				VALUES (@messageId, 2, GETDATE())
				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK
			END CATCH		
		END
		ELSE
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION
				
				SET @messageId = dbo.fnParseString( 1, ',', @EventDataString )
				SET @response = dbo.fnParseString( 0, ',', @EventDataString )
				
				UPDATE dbo.MessageVehicle
				SET MessageStatusHardwareId = 2,
					MessageStatusWetwareId = CAST(@response AS INT)
				WHERE MessageId = @messageId
				AND VehicleId = @vid

				INSERT INTO dbo.MessageStatusHistory (MessageId, MessageStatusId, LastModified)
				VALUES (@messageId, CAST(@response AS INT), GETDATE())
				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK
			END CATCH
		END

		FETCH NEXT FROM Event_data_cur INTO @eventName, @EventDataString, @eventId
	END
	CLOSE Event_data_cur
	DEALLOCATE Event_data_cur
END

GO
