SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ====================================================================
-- Author:		Dmitrijs Jurins
-- Create date: 09/07/2013
-- Description:	Gets Linked Driver Uniqueidentifier from the VehicleDriver table
-- ====================================================================
CREATE FUNCTION [dbo].[cuf_Vehicle_LinkedDriverID] 
(
	@vehicleid UNIQUEIDENTIFIER
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @driverid UNIQUEIDENTIFIER
	
	SET @driverid = NULL
	
	SELECT @driverid = [dbo].[GetLinkedDriverId] (@vehicleid)

	RETURN @driverid
END


GO
