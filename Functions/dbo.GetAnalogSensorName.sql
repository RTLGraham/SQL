SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetAnalogSensorName] 
(
	@index SMALLINT,
	@vid UNIQUEIDENTIFIER
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	--DECLARE @vid UNIQUEIDENTIFIER,
	--		@index SMALLINT
	--SET @vid = N'02EA55B8-EB47-4A27-8BAB-18682C6DA0F2'		
	--SET @index = 0	
			
	DECLARE @result NVARCHAR(MAX)
	SET @result = NULL
	
	SELECT @result = vs.Description
	FROM dbo.VehicleSensor vs
		INNER JOIN dbo.Sensor s ON vs.SensorId = s.SensorId
	WHERE VehicleIntId = dbo.GetVehicleIntFromId(@vid) 
	  AND s.SensorIndex = @index
	  AND s.SensorType = 'A' -- Analog Sensors only
	  AND vs.[Enabled] = 1 

	--SELECT @result
	RETURN @result
END





GO
