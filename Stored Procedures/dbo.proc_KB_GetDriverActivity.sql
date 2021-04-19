SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[proc_KB_GetDriverActivity] (@did UNIQUEIDENTIFIER)
AS
BEGIN
	
	--DECLARE @did UNIQUEIDENTIFIER
	--SET @did = N'c021a4c0-51ae-4a4c-87c6-2d94e164c6c1';
	


	DECLARE @uid UNIQUEIDENTIFIER

	SELECT TOP 1 @uid = u.UserID
	FROM dbo.[User] u
	INNER JOIN dbo.Customer c ON c.CustomerId = u.CustomerID
	INNER JOIN dbo.CustomerDriver cd ON cd.CustomerId = c.CustomerId
	WHERE cd.DriverId = @did
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL
	  AND u.Archived = 0
	  


	SELECT
    d.DriverId,
    d.FirstName, 
    d.Surname,
	f.FileId,
    f.FName, 
    f.Description, 
    --CASE WHEN dh.ViewedDuration < f.DurationSecs THEN CAST(dh.ViewedDuration AS VARCHAR(MAX)) ELSE CAST(f.DurationSecs AS VARCHAR(MAX)) END + '/' + CAST(f.DurationSecs AS VARCHAR(MAX)) AS SessionProgress,
    --dh.AccessDateTime,
    --dh.AssessDateTime AS AssessmentDateTime,
	dbo.TZ_GetTime(dh.AccessDateTime, DEFAULT, @uid) AS AccessDateTime,
	dbo.TZ_GetTime(dh.AssessDateTime, DEFAULT, @uid) AS AssessmentDateTime,
	
    --dh.AssessDateTime AS AssessmentDateTime,
	--dbo.TZ_GetTime(i.EventDateTime, DEFAULT, @uid) AS EventDateTime,
    dh.isAssessed AS AssessmentScore
FROM dbo.Driver d
    INNER JOIN dbo.KB_DriverHistory dh ON dh.DriverIntId = d.DriverIntId
	INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = d.DriverId
	INNER JOIN dbo.KB_DriverGroupFolder dgf ON dgf.DriverGroupId = gd.GroupId
	INNER JOIN dbo.KB_FileFolder kf ON kf.FolderId = dgf.FolderId
    INNER JOIN dbo.KB_File f ON f.FileId = dh.FileId AND f.FileId = kf.FileId
WHERE  d.Archived = 0 AND d.DriverId = @did AND f.Archived = 0
ORDER BY f.FileId, dh.AccessDateTime

END


GO
