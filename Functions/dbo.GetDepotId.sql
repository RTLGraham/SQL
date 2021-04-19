SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetDepotId]
(
	@vid UNIQUEIDENTIFIER,
	@vdate DATETIME = NULL
)
RETURNS INT
AS
BEGIN
	DECLARE @depid INT
	
	SELECT TOP 1 @depid = CustomerIntId
	FROM dbo.CustomerVehicle cv
		INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
	WHERE VehicleId = @vid
		AND (@vdate >= StartDate) AND ((@vdate <= EndDate) OR (EndDate IS NULL))

	RETURN @depid
END

GO
