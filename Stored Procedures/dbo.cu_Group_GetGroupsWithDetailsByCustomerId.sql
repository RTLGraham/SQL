SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_Group_GetGroupsWithDetailsByCustomerId]
(
	@customerId UNIQUEIDENTIFIER,
	@groupTypeId INT
)
AS

--DECLARE	@customerId UNIQUEIDENTIFIER,
--		@groupTypeId INT

--SET @customerId = N'36993114-90C0-4697-87E6-97C827D8765A'
--SET	@groupTypeId = 1

DECLARE @dynsql NVARCHAR(MAX),
		@entityDataId UNIQUEIDENTIFIER,
		@entityTable VARCHAR(255),
		@entityTablePrimaryKey VARCHAR(255),
		@groupId UNIQUEIDENTIFIER,
		@isparam BIT

DECLARE @groupTable TABLE
(
	GroupId UNIQUEIDENTIFIER,
	GroupName NVARCHAR(255),
	GroupTypeId INT,
	LastModified DATETIME,
	DetailCount INT,
	IsParameter BIT,
	OriginalGroupId UNIQUEIDENTIFIER
)

INSERT INTO @groupTable (GroupId, GroupName, GroupTypeId, LastModified, DetailCount, IsParameter, OriginalGroupId)
	SELECT	DISTINCT 
			g.GroupId,
			g.GroupName,	
			g.GroupTypeId,
			g.LastModified,
			Count(gd.EntityDataId) AS DetailCount,
			g.IsParameter,
			g.OriginalGroupId
	FROM	[dbo].[Group] g
	LEFT OUTER JOIN [dbo].[GroupDetail] gd ON g.GroupId = gd.GroupId AND g.GroupTypeId = gd.GroupTypeId
	INNER JOIN dbo.UserGroup ug ON g.GroupId = ug.GroupId AND ug.Archived = 0
	INNER JOIN dbo.[User] u ON ug.UserId = u.UserID
	WHERE	u.CustomerID = @customerId
	AND g.Archived = 0
	AND g.IsParameter = 0
	AND g.OriginalGroupId IS NULL
	AND (@groupTypeId IS NULL OR g.GroupTypeId = @groupTypeId)
	GROUP BY g.GroupId, g.GroupName, g.GroupTypeId, g.LastModified, g.OriginalGroupId, g.IsParameter

SELECT * FROM @groupTable

DECLARE group_cur CURSOR FAST_FORWARD FOR
	SELECT GroupId, IsParameter
	FROM @groupTable

DECLARE @ids NVARCHAR(MAX)
DECLARE @groupIdStr VARCHAR(128)

OPEN group_cur
FETCH NEXT FROM group_cur INTO @groupId, @isparam
WHILE @@FETCH_STATUS = 0
BEGIN
	IF @groupTypeId != 4
	BEGIN
		SET @ids = '('
	END
	ELSE
	BEGIN
		SET @ids = ''
		
	END
	
	SET @groupIdStr = 'N''' + CAST(@groupId AS VARCHAR(128)) + ''''
	
	IF @isparam IS NULL
	BEGIN
		DECLARE entity_cursor CURSOR FAST_FORWARD READ_ONLY FOR
			SELECT DISTINCT gd.GroupTypeId, gd.EntityDataId
			FROM [dbo].[GroupDetail] gd
			INNER JOIN [dbo].[UserGroup] ug ON gd.GroupId = ug.GroupId
			INNER JOIN dbo.[User] u ON ug.UserId = u.UserID
			WHERE gd.GroupId = @groupId
			AND u.CustomerID = @customerId
			AND ug.Archived = 0
	END
	ELSE
	BEGIN
		DECLARE entity_cursor CURSOR FAST_FORWARD READ_ONLY FOR
			SELECT gd.GroupTypeId, gd.EntityDataId
			FROM [dbo].[GroupDetail] gd
			WHERE gd.GroupId = @groupId
			
	END
	
	OPEN entity_cursor
	FETCH NEXT FROM entity_cursor INTO @groupTypeId, @entityDataId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @entityTable = EntityTableName, @entityTablePrimaryKey = EntityTablePrimaryKey
		FROM [dbo].[GroupTypeTables]
		WHERE GroupTypeId = @groupTypeId

		IF @groupTypeId != 4
		BEGIN
			SET @ids = @ids + 'N''' + CAST(@entityDataId AS VARCHAR(128)) + ''''
		END
		ELSE
		BEGIN
			SET @ids = @ids + CAST(@entityDataId AS VARCHAR(128))
		END
		 
		FETCH NEXT FROM entity_cursor INTO @groupTypeId, @entityDataId
		
		IF @@FETCH_STATUS != 0
		BEGIN
			IF @groupTypeId != 4
			BEGIN
				SET @ids = @ids + ')'
			END
		END
		ELSE
		BEGIN
			SET @ids = @ids + ','
		END
	END
	CLOSE entity_cursor
	DEALLOCATE entity_cursor

	IF @groupTypeId = 4
	BEGIN
		IF @ids != ' '
		BEGIN
			--SET @dynsql = NULL
			SELECT 	
					[GeofenceId],
					[GeofenceIntId],
					[GeofenceSpatialId],
					[GeofenceTypeId],
					[GeofenceCategoryId],
					[Description],
					[Name],
					[Enabled],
					[Archived],
					[LastModified],
					[CreationDate],
					[CreationUserId],
					[IsLocked],
					CAST([the_geom] AS VARBINARY(MAX)) AS the_geom,
					[SiteId] ,
					[Radius1] ,
					[Radius2] ,
					[CenterLon] ,
					[CenterLat] ,
					[Recipients],
					@groupId AS GroupId
			FROM dbo.Geofence
			WHERE GeofenceId IN (SELECT VALUE FROM dbo.Split(@ids, ','))
			AND Archived = 0
		END
	END
	ELSE
	BEGIN
		SET @dynsql = 'SELECT  e.*, ' + @groupIdStr + ' AS GroupId FROM ' + @entityTable + ' e WHERE e.' + @entityTablePrimaryKey + ' IN ' + @ids + ' AND e.Archived = 0'

		SET QUOTED_IDENTIFIER ON

		IF @ids != '('
		BEGIN
			EXECUTE sp_executesql @dynsql
		END
	END
	
	FETCH NEXT FROM group_cur INTO @groupId, @isparam
END
CLOSE group_cur
DEALLOCATE group_cur


GO
