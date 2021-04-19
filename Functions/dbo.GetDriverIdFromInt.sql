SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ====================================================================
-- Author:		Graham Pattison
-- Create date: 20/12/2011
-- Description:	Gets Driver Uniqueidentifier from the DriverIntegerId
-- ====================================================================
CREATE FUNCTION [dbo].[GetDriverIdFromInt] 
(
	@dintid int
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN

	DECLARE @DriverId UNIQUEIDENTIFIER

	SELECT @DriverId = DriverId FROM [dbo].[Driver] WITH (NOLOCK)
	WHERE DriverIntId = @dintid

	RETURN @DriverId

END

GO
