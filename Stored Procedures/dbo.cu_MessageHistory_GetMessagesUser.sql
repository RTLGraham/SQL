SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_MessageHistory_GetMessagesUser]
(
	@VehicleId UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER,
	@Count int = NULL
)
AS
	--DECLARE @vehicleid UNIQUEIDENTIFIER,
	--		@uid UNIQUEIDENTIFIER,
	--		@count INT
	
	--SET @vehicleid = N'CF0BCF73-FD37-4007-90DC-DF9FFBBD2F7A'
	--SET @uid = N'712DBE7D-3F6B-497B-8BBA-A24F66117479'
	--SET @count = 10

	DECLARE @timediff NVARCHAR(30)
	
	SET @timediff = [dbo].[UserPref](@uid, 600)
	
	IF @Count IS NULL
	BEGIN
		SELECT
			mv.MessageId,
			mv.UserId,
			mv.VehicleId,
			m.MessageText,
			m.Lat,
			m.Long,
			[dbo].[GetAddressFromLongLat]( m.Lat, m.Long ) AS ReverseGeoCode,
			mv.MessageStatusHardwareId,
			mv.MessageStatusWetwareId,
			dbo.TZ_GetTime(mv.TimeSent, @timediff, @uid) AS 'TimeSent',
			mv.HasBeenDeleted
		FROM
			[dbo].[MessageVehicle] mv
			INNER JOIN [dbo].[MessageHistory] m ON mv.MessageId = m.MessageId
		WHERE
			mv.VehicleId = @VehicleId
			AND mv.Archived != 1
			AND m.Archived != 1
		ORDER BY mv.TimeSent DESC
	END
	ELSE
	BEGIN
		DECLARE @sqltext NVARCHAR(MAX)
		
		SET @sqltext = 'SELECT TOP ' + CAST(@count AS VARCHAR(10)) + ' mv.MessageId, mv.UserId, mv.VehicleId, m.MessageText, m.Lat, m.Long, [dbo].[GetAddressFromLongLat]( m.Lat, m.Long ) AS ReverseGeoCode, mv.MessageStatusHardwareId, mv.MessageStatusWetwareId, dbo.TZ_GetTime(mv.TimeSent, @timediff, @uid) AS ''TimeSent'', mv.HasBeenDeleted'
		SET @sqltext = @sqltext + ' FROM [dbo].[MessageVehicle] mv INNER JOIN [dbo].[MessageHistory] m ON mv.MessageId = m.MessageId '
		SET @sqltext = @sqltext + ' WHERE mv.VehicleId = @VehicleId AND mv.Archived != 1 AND m.Archived != 1 ORDER BY mv.TimeSent DESC'
		
		EXEC sp_executesql @sqltext, N'@timediff NVARCHAR(30),
									   @uid UNIQUEIDENTIFIER,
									   @VehicleId UNIQUEIDENTIFIER',
									   @timediff, @uid, @vehicleid
	END


GO
