SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ======================================================================
-- Author:		Graham Pattison
-- Create date: 20/12/2011
-- Description:	Gets the Mileage ClaimRate for a given driver and vehicle 
--				parameters taking default values where appropriate
-- ======================================================================
CREATE FUNCTION [dbo].[GetClaimRateForDriver] 
(
	@DriverId UNIQUEIDENTIFIER,
	@FuelType TINYINT,
	@EngineSize INT,
	@Date DATETIME
)
RETURNS INT
AS
BEGIN

--	DECLARE	@DriverId UNIQUEIDENTIFIER,
--			@FuelType TINYINT,
--			@EngineSize INT,
--			@Date DATETIME
--
--	SET @DriverId = N'1B2D0CA8-9531-403C-B0CF-070829880A2F'
--	SET @FuelType = 1
--	SET @EngineSize = 2500
--	SET @Date = GETDATE()

	DECLARE @ClaimRate INT
	
	SELECT TOP 1 @ClaimRate = x.ClaimRate
	FROM
	(
			SELECT mr.ClaimRate, mr.CustomerId, mr.DriverGroupId
			FROM dbo.CustomerDriver cd
			INNER JOIN dbo.GroupDetail gd ON cd.DriverId = gd.EntityDataId
			INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
			INNER JOIN dbo.UKMileageRate mr ON cd.CustomerId = mr.CustomerId AND mr.DriverGroupId = gd.GroupId
			WHERE @Date BETWEEN mr.StartDate AND ISNULL(mr.EndDate, '2199-12-31 23:59')
			  AND @EngineSize BETWEEN mr.EngineSizeLow AND mr.EngineSizeHigh
			  AND mr.Fueltype = @FuelType
			  AND cd.Archived = 0
			  AND @Date BETWEEN cd.StartDate AND ISNULL(cd.EndDate, '2199-12-31 23:59')
			  AND g.GroupTypeId = 2
			  AND g.Archived = 0
			  AND g.IsParameter = 0
			  AND gd.EntityDataId = @DriverId
			  
			UNION

			SELECT mr.ClaimRate, mr.CustomerId, mr.DriverGroupId
			FROM dbo.CustomerDriver cd
			INNER JOIN dbo.UKMileageRate mr ON cd.CustomerId = mr.CustomerId AND mr.DriverGroupId IS NULL
			WHERE @Date BETWEEN mr.StartDate AND ISNULL(mr.EndDate, '2199-12-31 23:59')
			  AND @EngineSize BETWEEN mr.EngineSizeLow AND mr.EngineSizeHigh
			  AND mr.Fueltype = @FuelType
			  AND cd.Archived = 0
			  AND @Date BETWEEN cd.StartDate AND ISNULL(cd.EndDate, '2199-12-31 23:59')
			  AND cd.DriverId = @DriverId
			
			UNION

			SELECT mr.ClaimRate, mr.CustomerId, mr.DriverGroupId
			FROM dbo.UKMileageRate mr
			WHERE @Date BETWEEN mr.StartDate AND ISNULL(mr.EndDate, '2199-12-31 23:59')
			  AND @EngineSize BETWEEN mr.EngineSizeLow AND mr.EngineSizeHigh
			  AND mr.Fueltype = @FuelType
			  AND mr.CustomerId IS NULL	
	) x	ORDER BY x.DriverGroupId DESC, x.CustomerId DESC

--	SELECT @ClaimRate
	RETURN @ClaimRate

END


GO
