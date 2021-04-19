SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ====================================================================
-- Author:		Graham Pattison
-- Create date: 20/12/2011
-- Description:	Gets Driver Uniqueidentifier from the DriverIntegerId
-- ====================================================================
CREATE FUNCTION [dbo].[GetDriverIdFromEvent_CFSeries] 
(
	@vid UNIQUEIDENTIFIER,
	@eventdatetime DATETIME
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN

	DECLARE @did UNIQUEIDENTIFIER

	SELECT TOP 1 @did = d.DriverId
	FROM [dbo].EventData ed
		INNER JOIN [dbo].[Driver] d ON ed.DriverIntId = d.DriverIntId
	WHERE ed.VehicleIntId = dbo.GetVehicleIntFromId(@vid)
	  AND ed.EventDateTime BETWEEN DATEADD(dd, -1, @eventdatetime) AND @eventdatetime
	  AND ed.EventDataName = 'DID'
	  AND ed.CreationCodeId = 0
	ORDER BY ed.EventDateTime DESC
	
	RETURN @did

END


GO
