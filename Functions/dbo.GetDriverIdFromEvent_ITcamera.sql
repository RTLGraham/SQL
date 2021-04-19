SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- ====================================================================
-- Author:		Dmitrijs Jurins
-- Create date: 01/04/2015
-- Description:	Gets Driver INT Identifier from the linked cheetah unit data
--
-- Updated 4/10/17 GKP: If initial read from EventData does not return a driver
--						probably because driver remained logged in for a long
--						period of time, then try again looking at events for 
--						the previous hour as Cheetah will always provide a 
--						driver number.
--
-- Updated 18/4/18 GKP: Exclude No ID drivers from the EventData search and
--						exclude camera events from the Event search.
-- ====================================================================
CREATE FUNCTION [dbo].[GetDriverIdFromEvent_ITcamera] 
(
	@vIntId INT,
	@eventdatetime DATETIME
)
RETURNS INT
AS
BEGIN

	--DECLARE @vIntId INT,
	--		@eventdatetime DATETIME

	--SET @vIntId = 6011
	--SET @eventdatetime = '2017-06-27 13:20:03.067'

	DECLARE @did INT

	SELECT TOP 1 @did = d.DriverIntId
	FROM [dbo].EventData ed
		INNER JOIN [dbo].[Driver] d ON ed.DriverIntId = d.DriverIntId
	WHERE ed.VehicleIntId = @vIntId
	  AND ed.EventDateTime BETWEEN DATEADD(dd, -1, @eventdatetime) AND @eventdatetime
	  AND ed.EventDataName = 'DID'
	  AND ed.CreationCodeId = 61
	  AND ISNULL(d.Number, '') != 'No ID'
	ORDER BY ed.EventDateTime DESC

	IF @did IS NULL -- try again using events for the last 1 hours
	BEGIN
    
		SELECT TOP 1 @did = d.DriverIntId
		FROM [dbo].Event e
			INNER JOIN [dbo].[Driver] d ON e.DriverIntId = d.DriverIntId
		WHERE e.VehicleIntId = @vIntId
		  AND e.EventDateTime BETWEEN DATEADD(hh, -1, @eventdatetime) AND @eventdatetime
		  AND e.CreationCodeId NOT IN (436, 437, 438, 455, 456, 457, 458) -- exclude any camera events from the lookup
		ORDER BY e.EventDateTime DESC

	END	
	
	RETURN @did

END



GO
