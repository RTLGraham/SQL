SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_CopyRTL2Messaging]
AS
BEGIN
	 --Update the MessageHistory table
	DECLARE @messageId INT,
			@eventName VARCHAR(30),
			@EventDataString VARCHAR(1024),
			@response VARCHAR(1024),
			@responseInt INT,
			@eventId BIGINT,
			@timeSent DATETIME,
			@vid UNIQUEIDENTIFIER,
			@did UNIQUEIDENTIFIER,
			@lat FLOAT,
			@lon FLOAT

	DECLARE Event_data_cur CURSOR FAST_FORWARD FOR
		-- parse and move *before* it leaves the temp table. This keeps the result set sizes down.
		SELECT EventDataName, EventDataString, EventId
		FROM dbo.MessagingEventData
		WHERE Archived = 0
		AND (EventDataName = 'DMSGD' OR EventDataName = 'DMSGR')

	OPEN Event_data_cur
	FETCH NEXT FROM Event_data_cur INTO @eventName, @EventDataString, @eventId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @vid = dbo.GetVehicleIdFromInt(VehicleIntId), @lat = Lat, @lon = Long, @timeSent = EventDateTime
		FROM dbo.Event
		WHERE EventId = @eventId

		--PRINT 'vehicle ' + CAST(@vid AS VARCHAR(300))
		--PRINT 'event ' + @eventName

		IF @eventName = 'DMSGD'
		BEGIN
			--PRINT 'driver stop message'
			BEGIN TRY
				BEGIN TRANSACTION
				-- if it's a driver stop message then there won't be anything in the database
				-- already for this
				INSERT INTO dbo.MessageHistory (MessageText, Lat, Long, [Date], Archived)
				VALUES (@EventDataString, @lat, @lon, GETUTCDATE(), 0)
				
				SELECT @messageId = @@IDENTITY
				
				-- set the message as 'received' and 'done'
				INSERT INTO dbo.MessageVehicle (MessageId, TimeSent, MessageStatusHardwareId, MessageStatusWetwareId, VehicleId, Archived)
				VALUES (@messageId, @timeSent, 102, 101, @vid, 0)

				INSERT INTO dbo.MessageStatusHistory (MessageId, MessageStatusId, LastModified)
				VALUES (@messageId, 101, GETUTCDATE())
				
				UPDATE dbo.VehicleLatestEvent
				SET	AnalogIoAlertTypeId = 8
				WHERE VehicleId = @vid
				
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
				
				SET @messageId = dbo.fnParseString( 3, ',', @EventDataString )
				SET @response = dbo.fnParseString( 2, ',', @EventDataString )
				
				SET @response = SUBSTRING(@response, 1, LEN(@response))
				SET @responseInt = CAST(LTRIM(RTRIM(@response)) AS INT)
				
				--PRINT 'reply ' + CAST(@responseInt AS VARCHAR)
				--PRINT 'message id ' + CAST(@messageId AS VARCHAR)
				
				IF @responseInt = 102
				BEGIN
					-- we've received an ack
					UPDATE dbo.MessageVehicle
					SET MessageStatusHardwareId = @responseInt,
						LastModified = GETUTCDATE()
					WHERE MessageId = @messageId
					AND VehicleId = @vid
				END
				ELSE IF @responseInt = 104
				BEGIN
					-- we've received a delete
					UPDATE dbo.MessageVehicle
					SET HasBeenDeleted = 1,
						LastModified = GETUTCDATE()
					WHERE MessageId = @messageId
					AND VehicleId = @vid
				END
				ELSE
				BEGIN
					--PRINT 'we have received a reply'
					-- we've received a reply
					UPDATE dbo.MessageVehicle
					SET MessageStatusWetwareId = @responseInt,
						LastModified = GETUTCDATE()
					WHERE MessageId = @messageId
					AND VehicleId = @vid
				END
				
				INSERT INTO dbo.MessageStatusHistory (MessageId, MessageStatusId, LastModified)
				VALUES (@messageId, @responseInt, GETUTCDATE())
				
				UPDATE dbo.VehicleLatestEvent
				SET	AnalogIoAlertTypeId = 9
				WHERE VehicleId = @vid
				
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
	
	BEGIN TRY
		BEGIN TRANSACTION
		DELETE FROM MessagingEventData 	
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
	END CATCH
	
END




/*


Message
Executed as user: NT AUTHORITY\SYSTEM. 
Transaction count after EXECUTE indicates that a COMMIT or ROLLBACK TRANSACTION statement is missing. 
Previous count = 0, current count = 1. 
[SQLSTATE 25000] (Error 266)  
Cannot find either column "dbo" or the user-defined function or aggregate "dbo.fnParseString", or the name is ambiguous. [SQLSTATE 42000] (Error 4121).  The step failed.

*/
GO
