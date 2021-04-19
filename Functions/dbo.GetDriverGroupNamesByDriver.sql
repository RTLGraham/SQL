SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [dbo].[GetDriverGroupNamesByDriver]
(
	@did UNIQUEIDENTIFIER
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	--DECLARE @did UNIQUEIDENTIFIER,
	--		@uid UNIQUEIDENTIFIER 
	--SET @did = N'C11CA3C8-2F0B-44D8-AB73-C9B1BB304CBB'
	--SET @uid = N'3DB40C4A-7E79-4F41-8017-DE6E12EC7A20'
	
	DECLARE @result NVARCHAR(MAX)
	
	SELECT @result = COALESCE(@result + '; ', '') + GroupName 
	FROM dbo.[Group] g
		INNER JOIN dbo.GroupDetail gd ON g.GroupId = gd.GroupId
	WHERE g.Archived = 0 AND g.GroupTypeId = 2 AND g.IsParameter = 0
		AND gd.EntityDataId = @did
	ORDER BY GroupName ASC
	
	--SELECT @result
	
	RETURN @result
END



GO
