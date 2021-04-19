SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_SPD_GetEventsForSpeeding]
	(@vehicleIntId INT,
	 @tripStartDate DATETIME,
	 @tripEndDate DATETIME)
AS

BEGIN

--DECLARE @vehicleIntId INT,
--        @tripStartDate DATETIME,
--        @tripEndDate DATETIME

--	SET @vehicleIntId = 14937
--	SET @tripStartDate = '2020-07-01 02:59:00'
--	SET @tripEndDate = '2020-07-01 03:31:00'

	SELECT e.EventId, 
			e.Lat, 
			e.Long AS Lon, 
			--e.Speed,
			CASE WHEN ISNULL(i.IVHTypeId, 0) = 8 OR ISNULL(i.IVHTypeId, 0) = 9
				 THEN ISNULL(
						CASE WHEN e.Speed = 254 
							THEN CAST(0 AS SMALLINT)
							ELSE e.Speed 
						END,CAST(0 AS SMALLINT))
				 ELSE e.Speed
			END AS Speed,
			CASE WHEN ISNULL(i.IVHTypeId, 0) = 5 
				THEN ISNULL(
						CASE WHEN e.MaxSpeed = 0 
							THEN CAST(dbo.CAP(ISNULL(e.Speed, 0), 255) AS TINYINT) 
							ELSE e.MaxSpeed 
						END, 
						CAST(dbo.CAP(ISNULL(e.Speed, 0), 255) AS TINYINT)) 
				ELSE CAST(dbo.CAP(ISNULL(e.Speed, 0), 255) AS TINYINT) 
			END AS MaxSpeed,
			ISNULL(e.Heading, 0) AS Heading, 
			e.EventDateTime,
			e.CreationCodeId,
			e.VehicleIntId,
			e.DriverIntId,
			e.CustomerIntId
	FROM dbo.Event e WITH (NOLOCK)
	INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
	LEFT JOIN dbo.IVH i ON i.IVHId = v.IVHId
	WHERE e.VehicleIntId = @vehicleIntId
	  AND e.EventDateTime BETWEEN @tripStartDate AND @tripEndDate
	  AND e.CreationCodeId IN (61, 62, 1, 2, 3, 4, 5, 10, 29, 42, 43, 57, 58, 59, 74, 75, 77, 78, 100, 123,436, 437, 438, 55, 457, 458)

END


GO
