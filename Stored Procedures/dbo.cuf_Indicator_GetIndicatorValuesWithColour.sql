SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Indicator_GetIndicatorValuesWithColour]
(
	@vehicleId UNIQUEIDENTIFIER,
	@indicator INT,
	@rawValue FLOAT = NULL,
	@percentValue FLOAT = NULL,
	@diffValue FLOAT = NULL
)
AS
BEGIN

--DECLARE	@vehicleId UNIQUEIDENTIFIER,
--		@rawValue FLOAT,
--		@indicator INT,
--		@percentValue FLOAT,
--		@diffValue FLOAT

--SET @vehicleId = N'18A6474A-EFF8-48DB-B35B-D81D61CF7B6D'
--SET @indicator = 6
--SET @percentValue = 30
--SET @diffValue = 30
--SET @rawValue = 10
	
	DECLARE @depid INT
	
	SELECT TOP 1 @depid = CustomerIntId
	FROM dbo.Customer c
		INNER JOIN dbo.CustomerVehicle cv ON c.CustomerId = cv.CustomerId
	WHERE VehicleId = @vehicleId AND (EndDate IS NULL OR EndDate > GETDATE())
	
	SELECT	@vehicleId AS [VehicleId],
			@rawValue AS [Value],
			@indicator AS IndicatorId,
			dbo.[IndWeight]( @indicator ) AS [Weight],
			dbo.[IndDiff]( @indicator, @diffValue ) AS [Diff],
			dbo.[IndPercent]( @indicator, @percentValue ) AS [Percent],
			dbo.[GYRColour]( @rawValue, @indicator, @depid ) AS [Colour]
END

GO
