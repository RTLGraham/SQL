SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetVehicleGroupNamesByVehicle]
(
	@vid UNIQUEIDENTIFIER
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	--DECLARE @vid UNIQUEIDENTIFIER
	--SET @vid = N'C11CA3C8-2F0B-44D8-AB73-C9B1BB304CBB'
	
	DECLARE @result NVARCHAR(MAX)
	
	SELECT @result = COALESCE(@result + '; ', '') + GroupName 
	FROM dbo.[Group] g
		INNER JOIN dbo.GroupDetail gd ON g.GroupId = gd.GroupId
	WHERE g.Archived = 0 AND g.GroupTypeId = 1 AND g.IsParameter = 0
		AND gd.EntityDataId = @vid
	ORDER BY GroupName ASC
	
	--SELECT @result
	
	RETURN @result
END


GO
