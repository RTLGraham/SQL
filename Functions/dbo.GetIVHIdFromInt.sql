SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ====================================================================
-- Author:		Graham Pattison
-- Create date: 20/12/2011
-- Description:	Gets IVH Uniqueidentifier from the IVHIntegerId
-- ====================================================================
CREATE FUNCTION [dbo].[GetIVHIdFromInt] 
(
	@ivhintid int
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN

	DECLARE @IVHId UNIQUEIDENTIFIER

	SELECT @IVHId = IVHId FROM [dbo].[IVH]
	WHERE IVHIntId = @ivhintid

	RETURN @IVHId

END

GO
