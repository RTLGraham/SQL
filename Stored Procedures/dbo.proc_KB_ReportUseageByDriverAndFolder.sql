SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[proc_KB_ReportUseageByDriverAndFolder] (@dgids NVARCHAR(MAX), @dids NVARCHAR(MAX), @folders NVARCHAR(MAX), @files NVARCHAR(MAX), @uid UNIQUEIDENTIFIER)
AS
BEGIN

	--DECLARE @dgids NVARCHAR(MAX),
	--		@dids NVARCHAR(MAX),
	--		@folders NVARCHAR(MAX),
	--		@files NVARCHAR(MAX),
	--		@uid UNIQUEIDENTIFIER


--SELECT *
--FROM dbo.[Group] g
--INNER JOIN dbo.GroupDetail gd ON gd.GroupId = g.GroupId
--WHERE g.GroupTypeId = 2
--  AND g.IsParameter = 0
--  AND g.Archived = 0
--  AND g.GroupName = 'PSO - Santa Fe Springs 5210'

	CREATE TABLE #DriverHistory
	(
		DriverIntId INT,
		FileId INT,
		AccessDateTime DATETIME,
		DurationSecs INT,
		AssessDateTime DATETIME,
		isAssessed BIT,
		MaxDurationPos INT,
		MaxDatePos INT,
		MaxAssessPos INT,
		isAcknowledged BIT
	)

	INSERT INTO #DriverHistory (DriverIntId, FileId, AccessDateTime, DurationSecs, AssessDateTime, isAssessed, MaxDurationPos, MaxDatePos, MaxAssessPos, isAcknowledged)
	SELECT d.DriverIntId, kdh.FileId, kdh.AccessDateTime, kdh.ViewedDuration, kdh.AssessDateTime, kdh.isAssessed,
			ROW_NUMBER() OVER(PARTITION BY d.DriverIntId, kdh.FileId ORDER BY kdh.ViewedDuration DESC), 
			ROW_NUMBER() OVER(PARTITION BY d.DriverIntId, kdh.FileId ORDER BY kdh.AccessDateTime DESC),
			ROW_NUMBER() OVER(PARTITION BY d.DriverIntId, kdh.FileId ORDER BY kdh.AssessDateTime DESC),
			kdh.isAcknowledged
		FROM dbo.KB_DriverHistory kdh
		INNER JOIN dbo.KB_FileFolder ff ON ff.FileId = kdh.FileId
		INNER JOIN Driver d ON d.DriverIntId = kdh.DriverIntId
		INNER JOIN dbo.GroupDetail gd ON d.DriverId = gd.EntityDataId
		WHERE gd.GroupId IN (SELECT Value FROM dbo.Split(@dgids, ','))
		AND d.DriverId IN (SELECT Value FROM dbo.Split(@dids, ','))
		AND ff.FolderId IN (SELECT Value FROM dbo.Split(@folders, ','))
		AND ff.FileId IN (SELECT Value FROM dbo.Split(@files, ','))
		GROUP BY d.DriverIntId, kdh.FileId, kdh.ViewedDuration, kdh.AccessDateTime, kdh.AssessDateTime, kdh.isAcknowledged, kdh.isAssessed

	DELETE
    FROM #DriverHistory
	WHERE MaxDurationPos != 1 AND MaxDatePos != 1 AND MaxAssessPos != 1

	CREATE NONCLUSTERED INDEX IX_TempDriverHostory ON #DriverHistory ([DriverIntId],[FileId]);

	SELECT DISTINCT g.GroupId, g.GroupName, d.DriverId, dbo.FormatDriverNameByUser(d.DriverId, @uid) AS DriverName, fo.FolderId, fo.Name AS FolderName, kf.FileId, kf.FName AS FileName, kft.Name AS FileType, 
					CASE WHEN ISNULL(kf.Acknowledge, 0) = 0 AND ISNULL(kba.AssessmentId, 0) = 0 THEN 1 ELSE CASE WHEN ISNULL(kf.Acknowledge, 0) = 1 AND ISNULL(kba.AssessmentId, 0) = 0 THEN 2 ELSE 3 END END AS ReportGroup,
					dhdate.AccessDateTime AS LatestAccessDateTime, 
					CASE WHEN ISNULL(CAST(dhdate.isAcknowledged AS INT),0)+ISNULL(CAST(dhdur.isAcknowledged AS INT),0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END AS isAcknowledged,
					dhassess.isAssessed
	FROM dbo.Driver d
	INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = d.DriverId
	INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
	-- DJ 29/07/2020: added second join to the driver group so driver group doesn't matter (ish)
	INNER JOIN dbo.GroupDetail gd2 ON gd2.EntityDataId = d.DriverId
	INNER JOIN dbo.[Group] g2 ON g2.GroupId = gd2.GroupId
	INNER JOIN dbo.KB_DriverGroupFolder dgf ON dgf.DriverGroupId = g2.GroupId
	INNER JOIN dbo.KB_FileFolder ff ON ff.FolderId = dgf.FolderId
	INNER JOIN dbo.KB_File kf ON kf.FileId = ff.FileId
	INNER JOIN dbo.KB_Folder fo ON fo.FolderId = ff.FolderId AND fo.FolderId = dgf.FolderId
	INNER JOIN dbo.KB_FileType kft ON kft.FileTypeId = kf.FileTypeId
	LEFT JOIN #DriverHistory dhdate ON dhdate.DriverIntId = d.DriverIntId AND dhdate.FileId = kf.FileId AND dhdate.MaxDatePos = 1
	LEFT JOIN #DriverHistory dhdur ON dhdur.DriverIntId = d.DriverIntId AND dhdur.FileId = kf.FileId AND dhdur.MaxDurationPos = 1
	LEFT JOIN #DriverHistory dhassess ON dhassess.DriverIntId = d.DriverIntId AND dhassess.FileId = kf.FileId AND dhassess.MaxAssessPos = 1
	LEFT JOIN dbo.KB_Assessment kba ON kba.FileId = kf.FileId AND kba.IsEnabled = 1 AND kba.Archived = 0
	WHERE g.GroupId IN (SELECT Value FROM dbo.Split(@dgids, ','))
	  AND d.DriverId IN (SELECT Value FROM dbo.Split(@dids, ','))
	  AND fo.FolderId IN (SELECT Value FROM dbo.Split(@folders, ','))
	  AND kf.FileId IN (SELECT Value FROM dbo.Split(@files, ','))
	  AND g.Archived = 0
	  AND g.IsParameter = 0
	  AND g.GroupTypeId = 2
	ORDER BY kf.FName ASC

	DROP TABLE #DriverHistory

END




GO
