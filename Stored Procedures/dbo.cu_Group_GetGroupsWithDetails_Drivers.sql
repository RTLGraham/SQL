SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_Group_GetGroupsWithDetails_Drivers]
(
	@userId UNIQUEIDENTIFIER
)
AS

	--DECLARE	@userId UNIQUEIDENTIFIER
	--SET @userId = N'E90A46FA-B384-4E5B-9351-EBED1C5E4617'

	DECLARE @groupTable TABLE
	(
		GroupId UNIQUEIDENTIFIER,
		GroupName NVARCHAR(255),
		GroupTypeId INT,
		LastModified DATETIME,
		DetailCount INT,
		IsParameter BIT,
		OriginalGroupId UNIQUEIDENTIFIER,
		IsPhysical BIT,
		GeofenceId UNIQUEIDENTIFIER
	)

	INSERT INTO @groupTable (GroupId, GroupName, GroupTypeId, LastModified, DetailCount, IsParameter, OriginalGroupId, IsPhysical, GeofenceId)
		SELECT	g.GroupId,
				g.GroupName,	
				g.GroupTypeId,
				g.LastModified,
				Count(gd.EntityDataId) AS DetailCount,
				g.IsParameter,
				g.OriginalGroupId,
				g.IsPhysical,
				g.GeofenceId
		FROM	[dbo].[Group] g
		LEFT OUTER JOIN [dbo].[GroupDetail] gd ON g.GroupId = gd.GroupId AND g.GroupTypeId = gd.GroupTypeId
		INNER JOIN dbo.UserGroup ug ON g.GroupId = ug.GroupId AND ug.Archived = 0
		WHERE	ug.UserId = @userId
		AND g.Archived = 0
		AND g.IsParameter = 0
		AND g.OriginalGroupId IS NULL
		AND g.GroupTypeId = 2
		GROUP BY g.GroupId, g.GroupName, g.GroupTypeId, g.LastModified, g.OriginalGroupId, g.IsParameter,g.IsPhysical,g.GeofenceId

	SELECT GroupId,
		GroupName,
		GroupTypeId,
		LastModified,
		DetailCount,
		IsParameter,
		OriginalGroupId,
		IsPhysical,
		GeofenceId	 	 
	FROM @groupTable
	ORDER BY GroupName

	SELECT 
			d.DriverId ,
			d.DriverIntId ,
			d.Number ,
			d.NumberAlternate ,
			d.NumberAlternate2 ,
			d.FirstName ,
			d.Surname ,
			d.MiddleNames ,
			d.LastOperation ,
			d.Archived ,
			d.LanguageCultureId ,
			d.LicenceNumber ,
			d.IssuingAuthority ,
			d.LicenceExpiry ,
			d.MedicalCertExpiry ,
			d.Password ,
			d.PlayInd, 
			d.Email,
			g.GroupId,
			d.EmpNumber
	FROM dbo.Driver d
		INNER JOIN dbo.GroupDetail gd on d.DriverId = gd.EntityDataId
		INNER JOIN @groupTable g on g.GroupId = gd.GroupId
	WHERE d.Archived = 0
	ORDER BY g.GroupId, d.Surname

GO
