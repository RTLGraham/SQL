SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Gets the current vehicle mode for the specified vehicle. Note that this is a bit crap in that
-- the data isn't really returned from the vehicle in that way. Hopefully this will change in the
-- future.
CREATE PROCEDURE [dbo].[cuf_Vehicle_GetVehicleMode]
(
	@vehicleId UNIQUEIDENTIFIER,
	@date DATETIME = NULL
)
AS

--DECLARE @vehicleId uniqueidentifier

--SET @vehicleId = 'DCB4D9F6-DC5E-4C00-B14C-B98C13238FE6'

	-- Current vehicle mode
	SELECT TOP 1 vle.VehicleId, cc.CreationCodeId, cc.Name AS CreationCodeName 
	FROM [dbo].[VehicleLatestEvent] vle
	INNER JOIN [dbo].[CreationCode] cc ON vle.CreationCodeId = cc.CreationCodeId
	WHERE vle.VehicleId = @vehicleId
	-- Fix to remove vehicles which have sent rubbish data from the far future or distant past (i.e. when a box is first installed)
	AND (vle.EventDateTime <= DateAdd(day, 1, GetDate()) AND vle.EventDateTime >= DateAdd(year, -5, GetDate()))
	--AND e.CreationCodeId IN (0,1,3,4,5,10)
	ORDER BY vle.EventDateTime DESC


GO
