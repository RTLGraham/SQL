SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ====================================================================
-- Author:		Graham Pattison
-- Create date: 20/12/2011
-- Description:	Gets Driver IntegerId from the DriverId
-- ====================================================================
CREATE FUNCTION [dbo].[GetDriverIntFromIdAndCustomerId] 
(
	@DriverId UNIQUEIDENTIFIER,
	@CustomerId UNIQUEIDENTIFIER
)
RETURNS INT
AS
BEGIN

	DECLARE @DriverIntId INT

          IF @DriverId IS NULL OR @DriverID = '00000000-0000-0000-0000-000000000000'
              SELECT TOP 1 @DriverIntId = d.DriverIntId 
              FROM [dbo].[Driver] d
				INNER JOIN dbo.CustomerDriver cd ON d.DriverId = cd.DriverId
				INNER JOIN dbo.Customer c ON cd.CustomerId = c.CustomerId
	          WHERE Number = 'No ID' AND c.CustomerId = @CustomerId
	          ORDER BY d.LastOperation DESC
	          
          ELSE
	          SELECT @DriverIntId = DriverIntId FROM [dbo].[Driver]
	          WHERE DriverId = @DriverId

	RETURN @DriverIntId

END

GO
