SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_MessageHistory_GetMessages]
(
	@VehicleId UNIQUEIDENTIFIER,
	@Count int = NULL
)
AS
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
			mv.TimeSent
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
		
		SET @sqltext = 'SELECT TOP ' + Cast(@Count AS VARCHAR(10)) + '	mv.MessageId, mv.UserId, mv.VehicleId, m.MessageText, m.Lat, m.Long, [dbo].[GetAddressFromLongLat]( m.Lat, m.Long ) AS ReverseGeoCode, mv.MessageStatusHardwareId, mv.MessageStatusWetwareId,	mv.TimeSent '
		SET @sqltext = @sqltext + ' FROM [dbo].[MessageVehicle] mv INNER JOIN [dbo].[MessageHistory] m ON mv.MessageId = m.MessageId '
		SET @sqltext = @sqltext + ' WHERE mv.VehicleId = ''' + Cast(@VehicleId AS varchar(120)) + ''' AND mv.Archived != 1 AND m.Archived != 1 ORDER BY mv.TimeSent DESC'
		
		EXEC sp_executesql @sqltext
	END

GO
