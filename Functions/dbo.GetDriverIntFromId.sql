SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ====================================================================
-- Author:		Graham Pattison
-- Create date: 20/12/2011
-- Description:	Gets Driver IntegerId from the DriverId
-- ====================================================================
CREATE FUNCTION [dbo].[GetDriverIntFromId] 
(
	@DriverId UNIQUEIDENTIFIER
)
RETURNS INT
AS
BEGIN

	DECLARE @DriverIntId INT

	SELECT @DriverIntId = DriverIntId FROM [dbo].[Driver] WITH (NOLOCK)
	WHERE DriverId = @DriverId

	RETURN @DriverIntId

END

GO
