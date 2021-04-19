SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Vehicle_GetLinkedDriverID]
(
	@vehicleId UNIQUEIDENTIFIER
)
AS
BEGIN

	DECLARE @driverid UNIQUEIDENTIFIER
	
	SET @driverid = NULL
	
	SELECT @driverid = [dbo].[GetLinkedDriverId] (@vehicleid)
	
	SELECT @driverid
END

GO
