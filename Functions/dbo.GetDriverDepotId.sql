SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetDriverDepotId]
(
	@did UNIQUEIDENTIFIER,
	@vdate DATETIME = NULL
)
RETURNS INT
AS
BEGIN
	DECLARE @depid INT
	
	SELECT @depid = DepotId
	FROM dbo.[DepotsDrivers]
	WHERE DriverId = @did
		AND (@vdate >= StartDate) AND ((@vdate <= EndDate) OR (EndDate IS NULL))

	RETURN @depid
END

GO
