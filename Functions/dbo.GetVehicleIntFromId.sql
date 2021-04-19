SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ====================================================================
-- Author:		Graham Pattison
-- Create date: 20/12/2011
-- Description:	Gets Vehicle IntegerId from the VehicleId
-- ====================================================================
CREATE FUNCTION [dbo].[GetVehicleIntFromId] 
(
	@VehicleId UNIQUEIDENTIFIER
)
RETURNS INT
AS
BEGIN

	DECLARE @VehicleIntId INT

	SELECT @VehicleIntId = VehicleIntId FROM [dbo].[Vehicle] WITH (NOLOCK)
	WHERE VehicleId = @VehicleId

	RETURN @VehicleIntId

END

GO
