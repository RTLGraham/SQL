SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_Group_MoveAssets]
(
	@uid UNIQUEIDENTIFIER,
	@fromGroup UNIQUEIDENTIFIER,
	@toGroup UNIQUEIDENTIFIER,
	@groupType INT,
	@assets NVARCHAR(MAX)
)
AS
	
	DELETE FROM dbo.GroupDetail
	WHERE GroupId = @fromGroup	
		AND GroupTypeId = @groupType
		AND EntityDataId IN (SELECT Value FROM dbo.Split(@assets, ','))
		
		
	INSERT INTO dbo.GroupDetail
	        ( GroupId ,
	          GroupTypeId ,
	          EntityDataId
	        )
	SELECT @toGroup, @groupType, Value FROM dbo.Split(@assets, ',')
	 

GO
