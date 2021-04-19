SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[IsAnalogSensorEnabled] 
(
	@index SMALLINT,
	@vid UNIQUEIDENTIFIER
)
RETURNS BIT
AS
BEGIN
	--DECLARE @vid UNIQUEIDENTIFIER,
	--		@index SMALLINT
	--SET @vid = N'02EA55B8-EB47-4A27-8BAB-18682C6DA0F2'		
	--SET @index = 0	
			
	DECLARE @result BIT
	SET @result = 0
	
	SELECT @result = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
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
