SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_WriteRoute] 
	@rid INT = NULL OUTPUT, @customerid UNIQUEIDENTIFIER, @routenumber varchar(50), @routename varchar(255)
AS
	INSERT INTO Route (RouteNumber, RouteName)
	VALUES (@routenumber, @routename)
	SET @rid = SCOPE_IDENTITY()

	INSERT INTO CustomerRoute (CustomerId, RouteId, StartDate, EndDate)
	VALUES (@customerid, @rid, GETDATE(), NULL)

GO
