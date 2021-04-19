SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_Group_AdminUpdateGroup]
(
	@groupId UNIQUEIDENTIFIER,
	@newName NVARCHAR(255),
	@isPhysical BIT,
	@newGeofenceId UNIQUEIDENTIFIER = NULL 
)
AS
	UPDATE dbo.[Group]
	SET 
	GroupName = @newName,
	IsPhysical = @isPhysical,
	GeofenceId = @newGeofenceId
	WHERE GroupId = @groupId


GO
