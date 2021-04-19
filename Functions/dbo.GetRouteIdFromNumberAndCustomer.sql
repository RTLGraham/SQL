SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ====================================================================
-- Author:		Graham Pattison
-- Create date: 20/12/2011
-- Description:	Gets Route Uniqueidentifier from the RouteIntegerId
-- ====================================================================
CREATE FUNCTION [dbo].[GetRouteIdFromNumberAndCustomer] 
(
	@Routenumber VARCHAR(50),
	@customerid UNIQUEIDENTIFIER
)
RETURNS INT
AS
BEGIN

	DECLARE @RouteId INT
	DECLARE @sdateinthepast DATETIME, @edateinthefuture DATETIME
	SET @sdateinthepast = '1900-01-01 00:00'
	SET @edateinthefuture = '2100-01-01 00:00'

	SELECT TOP 1 @RouteId = r.RouteId 
	FROM CustomerRoute cr
	INNER JOIN Route r ON cr.RouteId = r.RouteId
	WHERE r.RouteNumber = @Routenumber
	  AND cr.CustomerId = @customerid 
	  AND cr.Archived = 0 
	  AND r.Archived = 0
	  AND (GETDATE() BETWEEN ISNULL(cr.StartDate, @sdateinthepast) AND ISNULL(cr.EndDate, @edateinthefuture))
	ORDER BY r.LastOperation DESC

	RETURN @RouteId

END



GO
