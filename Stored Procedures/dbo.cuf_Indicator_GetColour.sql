SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Indicator_GetColour](
	@vid UNIQUEIDENTIFIER,
	@ind int,
	@value float
)
AS
BEGIN
	--DECLARE @vid UNIQUEIDENTIFIER,
	--		@ind int,
	--		@value float

	--SET @vid = N'18A6474A-EFF8-48DB-B35B-D81D61CF7B6D'
	--SET @ind = 5
	--SET @value = 10
	
	DECLARE @depid int
	SELECT TOP 1 @depid = CustomerIntId
	FROM dbo.Customer c
		INNER JOIN dbo.CustomerVehicle cv ON c.CustomerId = cv.CustomerId
	WHERE VehicleId = @vid AND (EndDate IS NULL OR EndDate > GETDATE())
	
	SELECT dbo.[GYRColour]( @value, @ind, @depid) AS Colour
END

GO
