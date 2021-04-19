SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_Group_AdminCreate]
(
	@uid UNIQUEIDENTIFIER,
	@newName NVARCHAR(255),
	@groupType INT,
	@assets NVARCHAR(MAX)
)
AS
	DECLARE @gid UNIQUEIDENTIFIER
	SET @gid = NEWID()
	
	INSERT INTO dbo.[Group]
	        ( GroupId ,
	          GroupName ,
	          GroupTypeId ,
	          IsParameter ,
	          Archived ,
	          LastModified,
			  IsPhysical
	        )
	VALUES  ( @gid , -- GroupId - uniqueidentifier
	          @newName , -- GroupName - nvarchar(255)
	          @groupType , -- GroupTypeId - int
	          0 , -- IsParameter - bit
	          0 , -- Archived - bit
	          GETDATE(),
			  0
	        )
	        
	INSERT INTO dbo.GroupDetail
	        ( GroupId ,
	          GroupTypeId ,
	          EntityDataId
	        )
	SELECT @uid, @groupType, Value FROM dbo.Split(@assets, ',')
	
	INSERT INTO dbo.UserGroup
	        ( UserId ,
	          GroupId ,
	          Archived ,
	          LastModified
	        )
	VALUES  ( @uid , -- UserId - uniqueidentifier
	          @gid , -- GroupId - uniqueidentifier
	          0 , -- Archived - bit
	          GETDATE()
	        )
	 

GO
