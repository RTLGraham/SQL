SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ====================================================================
-- Author:		Graham Pattison
-- Create date: 20/12/2011
-- Description:	Gets Driver Uniqueidentifier from the DriverIntegerId
-- ====================================================================
CREATE FUNCTION [dbo].[GetDriverIdFromNumberAndCustomer] 
(
	@drivernumber VARCHAR(32),
	@customerid UNIQUEIDENTIFIER
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @l_drivernumber VARCHAR(32),
			@l_customerid UNIQUEIDENTIFIER
			
	SET @l_drivernumber = @drivernumber	
	SET @l_customerid = @customerid
	
	DECLARE @DriverId UNIQUEIDENTIFIER
	DECLARE @sdateinthepast DATETIME, @edateinthefuture DATETIME
	DECLARE @dintid INT
	SET @sdateinthepast = '1900-01-01 00:00'
	SET @edateinthefuture = '2100-01-01 00:00'

	--Clean up the driver number if necessary by stripping out any carriage returns in the string
	SET @l_drivernumber = REPLACE(@drivernumber, CHAR(10), '')
	SET @l_drivernumber = REPLACE(@drivernumber, CHAR(13), '')
	SET @l_drivernumber = REPLACE(@drivernumber, CHAR(00), '')

	SELECT TOP 1 @DriverId = x.DriverId
	FROM
		(SELECT d.DriverId, d.PlayInd, d.Lastoperation 
		FROM Driver d WITH (NOLOCK)
		INNER JOIN CustomerDriver cd WITH (NOLOCK) ON cd.DriverId = d.DriverId
		WHERE 
			d.Number = @l_drivernumber
			AND cd.CustomerId = @l_customerid 
			AND cd.Archived = 0 
			AND d.Archived = 0
--			AND (GETDATE() BETWEEN ISNULL(cd.StartDate, @sdateinthepast) AND ISNULL(cd.EndDate, @edateinthefuture))
			AND GETDATE() >= ISNULL(cd.StartDate, @sdateinthepast) AND cd.EndDate IS NULL
		
		UNION
		
		SELECT d.DriverId, d.PlayInd, d.Lastoperation 
		FROM Driver d WITH (NOLOCK)
		INNER JOIN CustomerDriver cd WITH (NOLOCK) ON cd.DriverId = d.DriverId
		WHERE 
			   d.NumberAlternate = @l_drivernumber 
			AND cd.CustomerId = @l_customerid 
			AND cd.Archived = 0 
			AND d.Archived = 0
--			AND (GETDATE() BETWEEN ISNULL(cd.StartDate, @sdateinthepast) AND ISNULL(cd.EndDate, @edateinthefuture))
			AND GETDATE() >= ISNULL(cd.StartDate, @sdateinthepast) AND cd.EndDate IS NULL
		
		UNION
		
		SELECT d.DriverId, d.PlayInd, d.Lastoperation 
		FROM Driver d WITH (NOLOCK)
		INNER JOIN CustomerDriver cd WITH (NOLOCK) ON cd.DriverId = d.DriverId
		WHERE 
   			   d.NumberAlternate2 = @l_drivernumber
			AND cd.CustomerId = @l_customerid 
			AND cd.Archived = 0 
			AND d.Archived = 0
--			AND (GETDATE() BETWEEN ISNULL(cd.StartDate, @sdateinthepast) AND ISNULL(cd.EndDate, @edateinthefuture))) x
			AND GETDATE() >= ISNULL(cd.StartDate, @sdateinthepast) AND cd.EndDate IS NULL) x
	ORDER BY x.PlayInd DESC, x.LastOperation DESC -- ensure any play drivers are returned before work drivers
	OPTION (FORCE ORDER)

	RETURN @DriverId

END


GO
