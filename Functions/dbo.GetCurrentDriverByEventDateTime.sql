SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ====================================================================
-- Author:		Graham Pattison
-- Create date: 20/12/2011
-- Description:	Gets Driver Uniqueidentifier from the DriverIntegerId
-- ====================================================================
CREATE FUNCTION [dbo].[GetCurrentDriverByEventDateTime] 
(
	@vintid INT,
	@IVHTypeId INT,
	@eventDateTime DATETIME,
	@did UNIQUEIDENTIFIER
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN

	DECLARE @DriverId UNIQUEIDENTIFIER
	SET @DriverId = NULL
	
	IF @IVHTypeId IN (1,2)
	BEGIN
		SELECT TOP 1 @DriverId = d.DriverId
		FROM [dbo].EventData ed
		INNER JOIN [dbo].[Driver] d ON ed.DriverIntId = d.DriverIntId
		WHERE ed.VehicleIntId = @vintid
		  AND ed.EventDateTime BETWEEN DATEADD(hh, -12, @eventDateTime) AND @eventDateTime
		  AND ed.EventDataName = 'DID'
		  AND ed.CreationCodeId = 0
		ORDER BY ed.EventDateTime DESC
	END
	 
	IF @DriverId IS NULL
	BEGIN
		SET @DriverId = @did
	END
	
	RETURN @DriverId

END


GO
