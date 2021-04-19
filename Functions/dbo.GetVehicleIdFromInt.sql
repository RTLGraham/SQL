SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ====================================================================
-- Author:		Graham Pattison
-- Create date: 20/12/2011
-- Description:	Gets Vehicle Uniqueidentifier from The VehicleIntegerId
-- ====================================================================
CREATE FUNCTION [dbo].[GetVehicleIdFromInt] 
(
	@vintid int
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN

	DECLARE @VehicleId UNIQUEIDENTIFIER

	SELECT @VehicleId = VehicleId FROM [dbo].[Vehicle] WITH (NOLOCK)
	WHERE VehicleIntId = @vintid

	RETURN @VehicleId

END

GO
