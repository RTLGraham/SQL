SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ====================================================================
-- Author:		Graham Pattison
-- Create date: 20/12/2011
-- Description:	Gets IVH IntegerId from the IVHId
-- ====================================================================
CREATE FUNCTION [dbo].[GetIVHIntFromId] 
(
	@IVHId UNIQUEIDENTIFIER
)
RETURNS INT
AS
BEGIN

	DECLARE @IVHIntId INT

	SELECT @IVHIntId = IVHIntId FROM [dbo].[IVH]
	WHERE IVHId = @IVHId

	RETURN @IVHIntId

END

GO
