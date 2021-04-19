SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ====================================================================
-- Author:		Dmitrijs Jurins
-- Create date: 09/07/2013
-- Description:	Gets Linked Driver Uniqueidentifier from the VehicleDriver table
-- ====================================================================
CREATE FUNCTION [dbo].[GetLinkedDriverId] 
(
	@vehicleid UNIQUEIDENTIFIER
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @driverid UNIQUEIDENTIFIER
	
	SET @driverid = NULL
	
	SELECT TOP 1 @driverid = DriverId
	FROM dbo.VehicleDriver
	WHERE VehicleId = @vehicleid
		AND Archived = 0
		AND EndDate IS NULL
	ORDER BY LastOperation DESC

	RETURN @driverid
END


GO
