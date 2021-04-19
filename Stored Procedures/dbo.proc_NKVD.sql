SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 --=============================================
 --Author:		<Dmitrijs Jurins>
 --Create date: <2012-07-06>
 --Description:	<SP for NKVD to check the database/listener health>
 --2019-01-27 - finally added support for different device types
 --=============================================
CREATE PROCEDURE [dbo].[proc_NKVD] 
	@biSeconds INT
AS
BEGIN
	SET NOCOUNT ON;

 --   DECLARE		@biSeconds INT
	--SET			@biSeconds = 300
	
	DECLARE		@lateDataDiff INT,
				@eventCount INT

	-- Create temporary table to hold list of device types where we have more than 50 live devices
	DECLARE @IvhType TABLE (IvhTypeId INT, Name VARCHAR(50), Number INT)
	INSERT INTO @IvhType (IvhTypeId, Name, Number)
	SELECT i.IVHTypeId, it.Name, COUNT(*)
	FROM dbo.IVH i
	INNER JOIN dbo.Vehicle v ON v.IVHId = i.IVHId
	INNER JOIN dbo.IVHType it ON it.IVHTypeId = i.IVHTypeId
	WHERE i.Archived = 0
	  AND v.Archived = 0
	  AND it.Name != 'Unknown'
	GROUP BY i.IVHTypeId, it.Name
	HAVING COUNT(*) > 50

	SELECT		@lateDataDiff = 
				AVG(DATEDIFF(SECOND, e.EventDateTime, dbo.TZ_ToUtc(e.LastOperation, 'GMT Time', NULL)))
	FROM		dbo.VehicleLatestAllEvent vle
				INNER JOIN dbo.Event e ON vle.EventId = e.EventId
	WHERE		vle.EventDateTime BETWEEN DATEADD(hh, -4, GETUTCDATE()) AND GETUTCDATE()
		
	SELECT		@eventCount = ISNULL(SUM(EventCount), 0)
	FROM		dbo.BulkInserts
	WHERE		InsertDateTime BETWEEN DATEADD(SECOND, @biSeconds * (-1), GETDATE()) AND GETDATE()

	SELECT		@lateDataDiff AS LateDataDiff, 
				@eventCount AS BulkInsertEventCount

	SELECT		it.Name AS TrackerType,
				AVG(DATEDIFF(SECOND, e.EventDateTime, dbo.TZ_ToUtc(e.LastOperation, 'GMT Time', NULL))) AS DataAgeSeconds
	FROM		dbo.VehicleLatestAllEvent vle
				INNER JOIN dbo.Event e WITH (NOLOCK) ON vle.EventId = e.EventId
				INNER JOIN dbo.Vehicle v ON v.VehicleId = vle.VehicleId
				INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
				INNER JOIN @IvhType it ON it.IVHTypeId = i.IVHTypeId
	WHERE		vle.EventDateTime BETWEEN DATEADD(hh, -4, GETUTCDATE()) AND GETUTCDATE()
				AND it.Name NOT IN ('Unknown')
	GROUP BY	it.Name
	ORDER BY	it.Name

	SELECT		it.Name AS TrackerType,
				COUNT(e.EventId) AS EventsRecorded
	FROM		dbo.Event e WITH (NOLOCK)
				RIGHT JOIN dbo.Vehicle v ON v.VehicleIntId = e.VehicleIntId
				INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
				INNER JOIN @IvhType it ON it.IvhTypeId = i.IVHTypeId
	WHERE		e.EventDateTime BETWEEN DATEADD(SECOND, @biSeconds * (-1), GETUTCDATE()) AND GETUTCDATE()
	GROUP BY	it.Name
	ORDER BY	it.Name	

END





GO
