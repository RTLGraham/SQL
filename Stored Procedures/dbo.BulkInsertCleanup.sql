SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[BulkInsertCleanup]
AS
BEGIN
	DECLARE @subject varchar(200), 
			@message varchar(8000),
			@email_recipient varchar(max),
			@countTS INT,
			@countDG INT,
			@countLoad INT,
			@countSnapshots INT,
			@countA INT,
			@countRPM INT,
			@countPC INT
			
	-- add email addresses for email alerts in the line below, delimited by semicolon'
	SET @email_recipient = 'dmitrijs@rtlsystems.co.uk;graham@rtlsystems.co.uk'
	--SET @email_recipient = 'dmitrijs@rtlsystems.co.uk;'
	SET @subject = 'Bulk Insert recovery: Nestle'
	SET @message = 'Periodic Bulk Insert on NG_Fleetwise database failed.' 

	SELECT @countTS = 0, @countDG = 0, @countLoad = 0, @countSnapshots = 0

	SELECT @countTS = COUNT(*)
	FROM dbo.TripsAndStopsTemp tst
		INNER JOIN dbo.TripsAndStops ts ON ts.TripsAndStopsID = tst.TripsAndStopsID
		
	SELECT @countDG = COUNT(*)
	FROM dbo.DgenTemp dt
		INNER JOIN dbo.Dgen d ON d.DgenId = dt.DgenId

	SELECT @countLoad = COUNT(*)
	FROM dbo.[Load] l
		INNER JOIN dbo.LoadTemp lt ON lt.LoadId = l.LoadId

	SELECT @countSnapshots = COUNT(*)
	FROM dbo.[Snapshot] s
		INNER JOIN dbo.SnapshotTemp st ON st.SnapshotId = s.SnapshotId

	SELECT @countA = COUNT(*)
	FROM dbo.Accum a
		INNER JOIN dbo.AccumTemp at ON at.AccumId = a.AccumId

	SELECT @countRPM = COUNT(*)
	FROM dbo.RPM r
		INNER JOIN dbo.RPMTemp rt ON rt.RPMId = r.RPMId

	SELECT @countPC = COUNT(*)
	FROM dbo.PassComf p
		INNER JOIN dbo.PassComfTemp pt ON pt.PassComfId = p.PassComfId

	IF @countTS > 0
	BEGIN
		DELETE FROM dbo.TripsAndStopsTemp
		WHERE TripsAndStopsID IN
		(
			SELECT tst.TripsAndStopsID
			FROM dbo.TripsAndStopsTemp tst
				INNER JOIN dbo.TripsAndStops ts ON ts.TripsAndStopsID = tst.TripsAndStopsID	
		)
		SET @message = @message + ' Trips & Stops duplicates deleted: ' + CAST(@countTS AS NVARCHAR(MAX))
	END

	IF @countDG > 0
	BEGIN	
		DELETE FROM dbo.DgenTemp
		WHERE DgenId IN 
		(
			SELECT dt.DgenId
			FROM dbo.DgenTemp dt
				INNER JOIN dbo.Dgen d ON d.DgenId = dt.DgenId
		)
		SET @message = @message + ' DGEN duplicates deleted: ' + CAST(@countDG AS NVARCHAR(MAX))
	END

	IF @countLoad > 0
	BEGIN	
		DELETE FROM dbo.LoadTemp
		WHERE LoadId IN 
		(
			SELECT l.LoadId
			FROM dbo.LoadTemp lt
				INNER JOIN dbo.[Load] l ON lt.LoadId = l.LoadId
		)
		SET @message = @message + ' Load duplicates deleted: ' + CAST(@countLoad AS NVARCHAR(MAX))
	END

	IF @countSnapshots > 0
	BEGIN	
		DELETE FROM dbo.SnapshotTemp
		WHERE SnapshotId IN 
		(
			SELECT s.SnapshotId
			FROM dbo.SnapshotTemp st
				INNER JOIN dbo.[Snapshot] s ON s.SnapshotId = st.SnapshotId
		)
		SET @message = @message + ' Snapshot duplicates deleted: ' + CAST(@countSnapshots AS NVARCHAR(MAX))
	END

	IF @countRPM > 0
	BEGIN	
		DELETE FROM dbo.RPMTemp
		WHERE RPMId IN 
		(
			SELECT r.RPMId
			FROM dbo.RPMTemp rt
				INNER JOIN dbo.RPM r ON r.RPMId = rt.RPMId
		)
		SET @message = @message + ' RPM duplicates deleted: ' + CAST(@countRPM AS NVARCHAR(MAX))
	END

	IF @countA > 0
	BEGIN	
		DELETE FROM dbo.AccumTemp
		WHERE AccumId IN 
		(
			SELECT a.AccumId
			FROM dbo.AccumTemp at
				INNER JOIN dbo.Accum a ON a.AccumId = at.AccumId
		)
		SET @message = @message + ' Accum duplicates deleted: ' + CAST(@countA AS NVARCHAR(MAX))
	END

	IF @countPC > 0
	BEGIN	
		DELETE FROM dbo.PassComfTemp
		WHERE PassComfId IN 
		(
			SELECT pc.PassComfId
			FROM dbo.PassComfTemp pct
				INNER JOIN dbo.PassComf pc ON pc.PassComfId = pct.PassComfId
		)
		SET @message = @message + ' PassComf duplicates deleted: ' + CAST(@countA AS NVARCHAR(MAX))
	END
	
	IF @countTS = 0 AND @countDG = 0 AND @countLoad = 0 AND @countSnapshots = 0 AND @countA = 0 AND @countPC = 0 AND @countRPM = 0
	BEGIN
		SET @message = @message + ' Problem unknown'
	END

	-- Send the email
	EXEC msdb.dbo.sp_send_dbmail 
		@profile_name = 'Cloud General Mail', 
		@recipients = @email_recipient,
		@subject = @subject,
		@body_format = 'HTML',
		@body = @message
END
GO
