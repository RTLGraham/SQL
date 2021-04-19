SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_AdminMoveCustomer]
(
	@vid UNIQUEIDENTIFIER,
	@cid UNIQUEIDENTIFIER
)
AS
	--DECLARE @vid UNIQUEIDENTIFIER,
	--		@cid UNIQUEIDENTIFIER
	
	UPDATE dbo.CustomerVehicle
	SET CustomerId = @cid
	WHERE VehicleId = @vid

	DECLARE @groupID UNIQUEIDENTIFIER

	SELECT TOP 1 @groupID = g.GroupId
	FROM dbo.[Group] g
		INNER JOIN dbo.UserGroup ug ON ug.GroupId = g.GroupId
		INNER JOIN dbo.[User] u ON u.UserID = ug.UserId
		INNER JOIN dbo.Customer c ON c.CustomerId = u.CustomerID
	WHERE g.Archived = 0 AND g.IsParameter = 0 AND g.GroupTypeId = 1 AND c.CustomerId = @cid
	ORDER BY g.LastModified ASC

	INSERT INTO dbo.GroupDetail
			( GroupId ,
			  GroupTypeId ,
			  EntityDataId
			)
	VALUES  ( @groupID , -- GroupId - uniqueidentifier
			  1 , -- GroupTypeId - int
			  @vid  -- EntityDataId - uniqueidentifier
			)

GO
