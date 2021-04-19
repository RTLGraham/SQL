SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_GetDriverByEventTime]
    (
		@spid INT,
		@vehicleid UNIQUEIDENTIFIER,
		@eventtime DATETIME,
		@depid INT
    )

AS 
--
BEGIN 

--	DECLARE @vehicleid UNIQUEIDENTIFIER,
--			@eventtime DATETIME,
--			@depid INT
--
--	SET @vehicleid = N'044A1143-8A6D-438F-89D0-C03A90D2D3EE'
--	SET @eventtime = '2011-08-05 00:52:35.000'
--	SET @depid = 44
--    
    DECLARE @DriverId UNIQUEIDENTIFIER
			,@DriverName VARCHAR(255)
			,@DriverNumber VARCHAR(255)
			,@VehicleIntId INT

	SELECT TOP 1 @DriverId = DriverId, 
				 @DriverName = d.Surname + ' ' + d.FirstName, 
				 @DriverNumber = d.Number,
				 @VehicleIntId = v.VehicleIntId
	FROM [dbo].Event e
		INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.Driver d ON e.DriverIntId = d.DriverIntId
		LEFT OUTER JOIN [dbo].[EventData] ed ON e.EventId = ed.EventId
	WHERE e.EventDateTime BETWEEN DATEADD(DAY, -1, @eventtime) AND @eventtime 
		AND ((e.CreationCodeId = 61 AND e.OdoGPS != 0) OR (e.CreationCodeId = 0 AND ed.EventDataName = 'DID')) 
		AND v.VehicleId = @vehicleid 
	ORDER BY e.EventDateTime DESC 
	
	INSERT INTO spid_EventDriver (Spid, VehicleIntId, EventTime, CustomerIntId, DriverName)
	VALUES (@spid, @VehicleIntId, @EventTime, @DepId, @DriverName)
    
END


GO
