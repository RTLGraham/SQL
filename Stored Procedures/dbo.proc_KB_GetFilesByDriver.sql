SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[proc_KB_GetFilesByDriver] (@did UNIQUEIDENTIFIER)
AS
BEGIN


	--DECLARE @did UNIQUEIDENTIFIER
	--SET @did = N'19517B7A-3D4A-4382-BE1C-2B9E82002365';
	----SET @did = N'457a22a2-63e4-4f24-af44-b46c00313cbc';


	WITH DriverHistory_CTE (DriverIntId, FileId, AccessDateTime, DurationSecs, AssessDateTime, isAssessed, MaxDurationPos, MaxDatePos, MaxAssessPos, isAcknowledged) AS
		(SELECT d.DriverIntId, FileId, kdh.AccessDateTime, kdh.ViewedDuration, kdh.AssessDateTime, kdh.isAssessed,
		ROW_NUMBER() OVER(PARTITION BY d.DriverIntId, kdh.FileId ORDER BY kdh.ViewedDuration DESC), 
		ROW_NUMBER() OVER(PARTITION BY d.DriverIntId, kdh.FileId ORDER BY kdh.AccessDateTime DESC),
		ROW_NUMBER() OVER(PARTITION BY d.DriverIntId, kdh.FileId ORDER BY kdh.AssessDateTime DESC),
		kdh.isAcknowledged
		 FROM dbo.KB_DriverHistory kdh
		 INNER JOIN Driver d ON d.DriverIntId = kdh.DriverIntId
		 WHERE d.DriverId = @did
		 GROUP BY d.DriverIntId, kdh.FileId, kdh.ViewedDuration, kdh.AccessDateTime, kdh.AssessDateTime, kdh.isAcknowledged, kdh.isAssessed)

	-- Identify all media for the customer this driver belongs to
	SELECT DISTINCT d.DriverId, fo.Name AS FolderName,fo.LastOperation AS FolderLastOperation, kf.FileId, kf.FName,kf.Ext, ISNULL(kf.Description,'')AS Description, kf.DurationSecs, kf.FileIdCustom, kf.BucketName, kf.Acknowledge AS FileAcknowledge,kf.LastOperation, kft.Name AS FileType, dhdate.AccessDateTime AS LatestAccessDateTime, dhdate.DurationSecs AS LatestPosition, dhdur.DurationSecs AS MaxPosition,(CASE WHEN ISNULL(CAST(dhdate.isAcknowledged AS INT),0)+ISNULL(CAST(dhdur.isAcknowledged AS INT),0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END) AS isAcknowledged,
				kba.AssessmentId AS AssessmentId, kba.Name AS AssessmentName, kba.Description AS AssessmentDescription, dhassess.AssessDateTime AS LastAssessedDateTime, dhassess.isAssessed
	FROM dbo.Driver d
	INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = d.DriverId
	INNER JOIN dbo.KB_DriverGroupFolder dgf ON dgf.DriverGroupId = gd.GroupId
	INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
	INNER JOIN dbo.KB_File kf ON kf.CustomerId = cd.CustomerId
	INNER JOIN dbo.KB_FileFolder ff ON ff.FileId = kf.FileId
	INNER JOIN dbo.KB_Folder fo ON fo.FolderId = ff.FolderId AND fo.FolderId = dgf.FolderId
	INNER JOIN dbo.KB_FileType kft ON kft.FileTypeId = kf.FileTypeId
	LEFT JOIN DriverHistory_CTE dhdate ON dhdate.DriverIntId = d.DriverIntId AND dhdate.FileId = kf.FileId AND dhdate.MaxDatePos = 1
	LEFT JOIN DriverHistory_CTE dhdur ON dhdur.DriverIntId = d.DriverIntId AND dhdur.FileId = kf.FileId AND dhdur.MaxDurationPos = 1
	LEFT JOIN DriverHistory_CTE dhassess ON dhassess.DriverIntId = d.DriverIntId AND dhassess.FileId = kf.FileId AND dhassess.MaxAssessPos = 1
	LEFT JOIN dbo.KB_Assessment kba ON kba.FileId = kf.FileId AND kba.IsEnabled = 1 AND kba.Archived = 0
	WHERE d.DriverId = @did
	  AND cd.EndDate IS NULL	
	  AND cd.Archived = 0
	  AND kf.Archived = 0
	  AND fo.Archived = 0
	ORDER BY kf.FName ASC

	
	
	IF OBJECT_ID('dbo.DriverMobileActivity') IS NOT NULL 
	BEGIN 
		INSERT INTO dbo.DriverMobileActivity(DriverId,StoredProcedure,StartDate,EndDate,GuidParam,IntParam,StringParam)
		VALUES (@did, OBJECT_NAME(@@PROCID), NULL, NULL, NULL, NULL, NULL)
	END
END

GO
