SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ====================================================================
-- Author:		Graham Pattison
-- Create date: 20/12/2011
-- Description:	Gets Vehicle Uniqueidentifier from The VehicleIntegerId
-- ====================================================================
CREATE FUNCTION [dbo].[CFG_GetTemperatureAlertValueFromHistory] 
(
	@vid UNIQUEIDENTIFIER,
	@keyname VARCHAR(255),
	@date DATETIME
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

--	DECLARE	@vid UNIQUEIDENTIFIER,
--			@keyname VARCHAR(255),
--			@date DATETIME
--			
--	SET @vid = N'901BCFF8-BE83-4C2C-90E2-A7E0C80A1D99'
--	SET @keyname = 'Name_1'
--	SET @date = GETUTCDATE()

	DECLARE @KeyValue NVARCHAR(MAX),
			@AlertName NVARCHAR(MAX),
			@Internal SMALLINT,
			@Product SMALLINT,
			@Element SMALLINT,
			@External SMALLINT,
			@AllSensors SMALLINT

	SET @Internal = 1
	SET @Product = 2
	SET @Element = 4
	SET @External = 8
	SET @AllSensors = @Internal | @Product | @Element | @External
	
	-- Set the keyname for the appropriate alert based upon the keyname being tested
	SET @AlertName = CASE @KeyName
						WHEN 'Name_1' THEN 'SensorFlags_1'
						WHEN 'Name_2' THEN 'SensorFlags_2'
						WHEN 'Name_3' THEN 'SensorFlags_3'
						WHEN 'Name_4' THEN 'SensorFlags_4'
						WHEN 'Colour_1' THEN 'SensorFlags_1'
						WHEN 'Colour_2' THEN 'SensorFlags_2'
						WHEN 'Colour_3' THEN 'SensorFlags_3'
						WHEN 'Colour_4' THEN 'SensorFlags_4'						
					  END		
	
	-- Test to see if any sensors are enabled by passing the appropriate Alert bitmask to the TestBits function
	IF (dbo.TestBits(@AllSensors, dbo.CFG_GetKeyValueFromHistory(@vid, 'RTLT', @AlertName, @date)) = 0) -- No sensors enabled for the alert 
		OR (dbo.CFG_GetKeyValueFromHistory(@vid, 'RTLT', @AlertName, @date) IS NULL)  -- No config set up for this AlertName
		-- so return a NULL value for the name
		SET @KeyValue = NULL
	ELSE
		-- At least one sensor is enabled so return the appropriate value
		SELECT @KeyValue = dbo.CFG_GetKeyValueFromHistory(@vid, 'RTLT', @keyname, @date)
		
	RETURN @KeyValue

END

GO
