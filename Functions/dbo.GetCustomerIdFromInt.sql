SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ====================================================================
-- Author:		Graham Pattison
-- Create date: 20/12/2011
-- Description:	Gets Customer Uniqueidentifier from the CustomerIntegerId
-- ====================================================================
CREATE FUNCTION [dbo].[GetCustomerIdFromInt] 
(
	@customerintid int
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN

	DECLARE @CustomerId UNIQUEIDENTIFIER

	SELECT @CustomerId = CustomerId FROM [dbo].[Customer]
	WHERE CustomerIntId = @customerintid

	RETURN @CustomerId

END

GO
