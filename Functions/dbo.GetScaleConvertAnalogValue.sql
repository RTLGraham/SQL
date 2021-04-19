SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetScaleConvertAnalogValue] 
(
	@value SMALLINT,
	@index SMALLINT,
	@vid UNIQUEIDENTIFIER,
	@tempmult FLOAT,
	@liquidmult FLOAT
)
RETURNS FLOAT
AS
BEGIN

	DECLARE @scale FLOAT,
			@result FLOAT
	
	SELECT @scale = ISNULL(AnalogSensorScaleFactor, 1) 
	FROM dbo.VehicleSensor vs
	INNER JOIN dbo.Sensor s ON vs.SensorId = s.SensorId
	WHERE VehicleIntId = dbo.GetVehicleIntFromId(@vid) 
	  AND s.SensorIndex = @index
	  AND s.SensorType = 'A' -- Analog Sensors only
	  
	SET @result = @value * @scale
	  
	SELECT @result = CASE WHEN @tempmult = 1.8 THEN @result * @tempmult + 32 ELSE @result * @tempmult END

	/*
	Rework this code to support the liquid sensors. Requires addition of the sensor type (e.g. temperature, liquid, flow, pressure, etc.)
	IF @scale IN (0.00390625) -- The value is a temperature
		SELECT @result = CASE WHEN @tempmult = 1.8 THEN @result * @tempmult + 32 ELSE @result * @tempmult END
	ELSE IF @scale IN (0.1) -- The value is a liquid volume
		SELECT @result = @result * @liquidmult
	*/

	RETURN @result
END



GO
