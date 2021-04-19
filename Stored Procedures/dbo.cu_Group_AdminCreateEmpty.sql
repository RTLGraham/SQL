SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_Group_AdminCreateEmpty]
(
	@uid UNIQUEIDENTIFIER,
	@newName NVARCHAR(255),
	@groupType INT
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
