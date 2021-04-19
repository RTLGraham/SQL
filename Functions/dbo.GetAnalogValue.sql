SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetAnalogValue] 
(
	@value SMALLINT,
	@index SMALLINT,
	@vid UNIQUEIDENTIFIER
)
RETURNS FLOAT
AS
BEGIN

	DECLARE @scale FLOAT
	
	SELECT @scale = ISNULL(AnalogSensorScaleFactor, 1) 
	FROM dbo.VehicleSensor vs
	INNER JOIN dbo.Sensor s ON vs.SensorId = s.SensorId
	WHERE VehicleIntId = dbo.GetVehicleIntFromId(@vid) 
	  AND s.SensorIndex = @index
	  AND s.SensorType = 'A' -- Analog Sensors only

	RETURN CONVERT(FLOAT, @value) * @scale
END



GO
