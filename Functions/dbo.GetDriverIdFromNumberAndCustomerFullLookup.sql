SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ====================================================================
-- Author:		Dmitrijs Jurins
-- Create date: 20/12/2011
-- Description:	Gets Driver Uniqueidentifier from the driver number(s), or license number, or emp number
-- ====================================================================
CREATE FUNCTION [dbo].[GetDriverIdFromNumberAndCustomerFullLookup] 
(
	@customerid UNIQUEIDENTIFIER,
	@drivernumber VARCHAR(32) = NULL,
	@licenseNumber NVARCHAR(30) = NULL,
	@empNumber NVARCHAR(30) = NULL
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @l_drivernumber VARCHAR(32),
			@l_customerid UNIQUEIDENTIFIER,
			@l_licenseNumber NVARCHAR(30),
			@l_empNumber NVARCHAR(30)
			
	SET @l_drivernumber = @drivernumber	
	SET @l_customerid = @customerid
	SET @l_licenseNumber = @licenseNumber
	SET @l_empNumber = @empNumber
	
	DECLARE @DriverId UNIQUEIDENTIFIER
	DECLARE @sdateinthepast DATETIME, @edateinthefuture DATETIME
	DECLARE @dintid INT
	SET @sdateinthepast = '1900-01-01 00:00'
	SET @edateinthefuture = '2100-01-01 00:00'

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
			AND GETDATE() >= ISNULL(cd.StartDate, @sdateinthepast) AND cd.EndDate IS NULL
		
		UNION
		
		SELECT d.DriverId, d.PlayInd, d.Lastoperation 
		FROM Driver d WITH (NOLOCK)
		INNER JOIN CustomerDriver cd WITH (NOLOCK) ON cd.DriverId = d.DriverId
		WHERE 
   			   d.LicenceNumber = @l_licenseNumber
			AND cd.CustomerId = @l_customerid 
			AND cd.Archived = 0 
			AND d.Archived = 0
			AND GETDATE() >= ISNULL(cd.StartDate, @sdateinthepast) AND cd.EndDate IS NULL
		
		UNION
		
		SELECT d.DriverId, d.PlayInd, d.Lastoperation 
		FROM Driver d WITH (NOLOCK)
		INNER JOIN CustomerDriver cd WITH (NOLOCK) ON cd.DriverId = d.DriverId
		WHERE 
   			   d.EmpNumber = @l_empNumber
			AND cd.CustomerId = @l_customerid 
			AND cd.Archived = 0 
			AND d.Archived = 0
			AND GETDATE() >= ISNULL(cd.StartDate, @sdateinthepast) AND cd.EndDate IS NULL
		
		) x
	ORDER BY x.PlayInd DESC, x.LastOperation DESC -- ensure any play drivers are returned before work drivers
	OPTION (FORCE ORDER)

	RETURN @DriverId

END


GO
