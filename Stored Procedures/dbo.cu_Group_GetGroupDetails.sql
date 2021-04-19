SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_Group_GetGroupDetails]
(
	@groupId UNIQUEIDENTIFIER,
	@userId UNIQUEIDENTIFIER
)
AS
	--DECLARE	@groupId UNIQUEIDENTIFIER,
	--		@userId UNIQUEIDENTIFIER

	--SET @groupId = N'2341DF81-E15C-4B4D-A217-E71EFB1994E0'
	--SET @userId = N'4C173651-9B5E-4EB1-871B-85181E40F4B1'

	DECLARE @dynsql NVARCHAR(MAX)
	DECLARE @groupTypeId INT
	DECLARE @entityDataId UNIQUEIDENTIFIER
	DECLARE @entityTable VARCHAR(255)
	DECLARE @entityTablePrimaryKey VARCHAR(255)

	DECLARE @gid UNIQUEIDENTIFIER,
			@isparam BIT
	
	SELECT	@gid = GroupId,
			@isparam = IsParameter
	FROM	[dbo].[Group]
	WHERE	GroupId = @groupId

	DECLARE @ids VARCHAR(MAX)

	SET @ids = '('

	IF @isparam IS NULL
	BEGIN
		DECLARE entity_cursor CURSOR FAST_FORWARD READ_ONLY FOR
			SELECT gd.GroupTypeId, gd.EntityDataId
			FROM [dbo].[GroupDetail] gd
			INNER JOIN [dbo].[UserGroup] ug ON gd.GroupId = ug.GroupId
			WHERE gd.GroupId = @groupId
			AND ug.UserId = @userId
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
		
		SET @ids = @ids + 'N''' + CAST(@entityDataId AS VARCHAR(128)) + ''''
		 
		FETCH NEXT FROM entity_cursor INTO @groupTypeId, @entityDataId
		
		IF @@FETCH_STATUS != 0
		BEGIN
			SET @ids = @ids + ')'
		END
		ELSE
		BEGIN
			SET @ids = @ids + ','
		END
	END
	CLOSE entity_cursor
	DEALLOCATE entity_cursor

	SET @dynsql = 'SELECT * FROM ' + @entityTable + ' WHERE ' + @entityTablePrimaryKey + ' IN ' + @ids + ' AND Archived = 0'

	SET QUOTED_IDENTIFIER ON

	EXECUTE sp_executesql @dynsql

GO
