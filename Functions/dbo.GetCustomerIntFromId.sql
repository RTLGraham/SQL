SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ====================================================================
-- Author:		Graham Pattison
-- Create date: 20/12/2011
-- Description:	Gets Customer IntegerId from the CustomerId
-- ====================================================================
CREATE FUNCTION [dbo].[GetCustomerIntFromId] 
(
	@CustomerId UNIQUEIDENTIFIER
)
RETURNS INT
AS
BEGIN

	DECLARE @CustomerIntId INT

	SELECT @CustomerIntId = CustomerIntId FROM [dbo].[Customer]
	WHERE CustomerId = @CustomerId

	RETURN @CustomerIntId

END

GO
