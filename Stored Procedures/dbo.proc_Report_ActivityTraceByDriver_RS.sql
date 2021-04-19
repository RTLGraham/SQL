SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_Report_ActivityTraceByDriver_RS]
          @uid uniqueidentifier,
          @dids nvarchar(MAX),
          @sdate datetime,
          @edate datetime
AS
	SET NOCOUNT ON;

--DECLARE   @dids NVARCHAR(MAX),
--	@sdate DATETIME,
--	@edate DATETIME,
--	@uid UNIQUEIDENTIFIER;
--
----SET @dids = N'BB3428A6-B8A5-4E7A-A081-99806369285F';
--SET @dids = '1B5600D4-85AE-4A78-B071-2EE555EB3300,843EEAB8-EC94-4923-8327-402B09F64F1F,5E9679AC-1B6F-4700-97E8-53BB46B0BC01,0D572BAC-D832-4D53-A192-7F7C56E1D37B,98E7ECE2-6AA1-41D9-BAA9-8B9CAB5D5FD2,983AEB57-6600-42C3-BA24-8D307F5AD57F,BB3428A6-B8A5-4E7A-A081-99806369285F,071410D1-1B88-40E7-8D81-ADE51D9683E9,26C8A9B2-2EB9-49A1-8C8D-DFBA04C697C3,0071EDE5-3222-4A5F-A00C-EB679C17B6FC,51D84E06-84FB-451C-8A02-F86F0219C39A'
--SET @sdate = '2013-11-07 00:00';
--SET @edate = '2013-11-07 23:59';
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5';


          DECLARE @timezone nvarchar(30);
          SET @timezone = dbo.UserPref(@uid, 600);
	
		  SET @sdate = [dbo].[TZ_ToUTC] (@sdate,default,@uid)
		  SET @edate = [dbo].[TZ_ToUTC] (@edate,default,@uid)
		  
          SELECT    DISTINCT dbo.GetDriverIntFromId(Value) AS DriverIntID, Value AS DriverID
          INTO      #Drivers
          FROM      dbo.Split(@dids, ',');

          SELECT    D.DriverIntID, E.EventDateTime, VM.VehicleModeID,
                    ROW_NUMBER() OVER (ORDER BY D.DriverIntID, E.EventDateTime) AS RowNumTime,
                    ROW_NUMBER() OVER (PARTITION BY D.DriverIntID, VM.VehicleModeID ORDER BY D.DriverIntID, E.EventDateTime) AS RowNumMode
          INTO      #Partitions
          FROM      dbo.Event E
	          INNER JOIN dbo.VehicleModeCreationCode MCC ON E.CreationCodeId = MCC.CreationCodeId
	          INNER JOIN dbo.VehicleMode VM ON MCC.VehicleModeId = VM.VehicleModeID
	          INNER JOIN #Drivers D ON E.DriverIntId = D.DriverIntId
          WHERE     E.EventDateTime BETWEEN @sdate AND @edate
          AND       VM.VehicleModeID != 0;

          SELECT    DriverIntID, VehicleModeID, MIN(EventDateTime) AS StartDate,
                    ROW_NUMBER() OVER (PARTITION BY DriverIntID ORDER BY MIN(EventDateTime)) AS RowNumber
          INTO      #Bands
          FROM      #Partitions
          GROUP BY  DriverIntID, RowNumTime - RowNumMode, VehicleModeID;

          DECLARE   @MissingEndDate datetime;
          SELECT    @MissingEndDate = CASE WHEN @edate > GETUTCDATE() THEN GETUTCDATE() ELSE @edate END;

          SELECT    B.DriverIntID, B.VehicleModeID, B.StartDate, B2.StartDate AS EndDate
          INTO      #Results
          FROM      #Bands B
                    LEFT OUTER JOIN #Bands B2 ON B2.RowNumber = B.RowNumber+1 AND B2.DriverIntID = B.DriverIntID;

          INSERT    #Results
          SELECT    DriverIntID, 0, @sdate, MIN(StartDate)
          FROM      #Results
          GROUP BY  DriverIntID;

          UPDATE    #Results
          SET       EndDate = CASE VehicleModeID
										WHEN 3 THEN DATEADD(MINUTE, 1, StartDate)
                                        WHEN 4 THEN DATEADD(MINUTE, 1, StartDate)
                                        ELSE CASE WHEN GETUTCDATE() < @edate THEN GETUTCDATE() ELSE @edate END
                              END
          WHERE     EndDate IS NULL;

          INSERT    #Results
          SELECT    DriverIntID, 0, MAX(EndDate), @edate
          FROM      #Results
          GROUP BY  DriverIntID
          HAVING    MAX(EndDate) < @edate;

--          SELECT    D.DriverID, dbo.FormatDriverNameByUser(D.DriverId, @uid) AS DriverName, 
--					VM.VehicleModeID,
--					[dbo].TZ_GetTime(R.StartDate,@timezone,@uid) AS StartDate,
--					[dbo].TZ_GetTime(R.EndDate,@timezone,@uid) AS EndDate,
--                    DATEDIFF(s, R.StartDate, R.EndDate) AS Duration
--          FROM      #Results R
--	          INNER JOIN dbo.Driver D ON R.DriverIntId = D.DriverIntId
--	          INNER JOIN VehicleMode VM ON R.VehicleModeID = VM.VehicleModeID
--          ORDER BY  R.DriverIntID, R.StartDate;

		  SELECT dbo.FormatDriverNameByUser(drv.DriverId, @uid) AS DriverName,
				 dbo.TZ_GetTime(MIN(StartDate), DEFAULT, @uid) AS ShiftStart,
				 dbo.TZ_GetTime(MAX(EndDate), DEFAULT, @uid) AS ShiftEnd,
				 DATEDIFF(ss,MIN(Startdate),MAX(EndDate)) AS TotalShiftTime,
				 drive.DriveDuration AS TotalDriveTime,
				 idle.IdleDuration AS TotalIdleTime,
				 kon.KeyOnDuration AS TotalKeyOnTime,
				 koff.KeyOffDuration AS TotalKeyOffTime,
				 0 AS TotalStops		 
		  FROM #Results r
		  LEFT JOIN (SELECT rt.DriverIntID, SUM(DATEDIFF(ss, rt.StartDate, rt.EndDate)) AS DriveDuration
					 FROM #Results rt
					 INNER JOIN #Drivers dt ON rt.DriverIntID = dt.DriverIntID
					 WHERE rt.VehicleModeID = 1
					 GROUP BY rt.DriverIntID) drive ON r.DriverIntID = drive.DriverIntID
		  LEFT JOIN (SELECT rt.DriverIntID, SUM(DATEDIFF(ss, rt.StartDate, rt.EndDate)) AS IdleDuration
					 FROM #Results rt
					 INNER JOIN #Drivers dt ON rt.DriverIntID = dt.DriverIntID
					 WHERE rt.VehicleModeID = 2
					 GROUP BY rt.DriverIntID) idle ON r.DriverIntID = idle.DriverIntID
		  LEFT JOIN (SELECT rt.DriverIntID, SUM(DATEDIFF(ss, rt.StartDate, rt.EndDate)) AS KeyOnDuration
					 FROM #Results rt
					 INNER JOIN #Drivers dt ON rt.DriverIntID = dt.DriverIntID
					 WHERE rt.VehicleModeID = 3
					 GROUP BY rt.DriverIntID) kon ON r.DriverIntID = kon.DriverIntID
		  LEFT JOIN (SELECT rt.DriverIntID, SUM(DATEDIFF(ss, rt.StartDate, rt.EndDate)) AS KeyOffDuration
					 FROM #Results rt
					 INNER JOIN #Drivers dt ON rt.DriverIntID = dt.DriverIntID
					 WHERE rt.VehicleModeID = 4
					 GROUP BY rt.DriverIntID) koff ON r.DriverIntID = koff.DriverIntID
		  INNER JOIN #Drivers drv ON r.DriverIntID = drv.DriverIntID
		  WHERE r.VehicleModeID != 0
		  GROUP BY drv.DriverId, drive.DriveDuration, idle.IdleDuration, kon.KeyOnDuration, koff.KeyOffDuration

          DROP TABLE #Results;
          DROP TABLE #Bands;
          DROP TABLE #Partitions;
          DROP TABLE #Drivers;



--SELECT *
--FROM dbo.GroupDetail gd
--INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
--WHERE g.GroupTypeId = 2
--  AND g.IsParameter = 0
--  AND g.Archived = 0
--  AND g.GroupName LIKE '%staad%'

GO
