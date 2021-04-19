SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the SpeedwiseCustomer table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[SpeedwiseCustomer_Find]
(

	@SearchUsingOR bit   = null ,

	@CustomerDefinitionId uniqueidentifier   = null ,

	@CustomerId uniqueidentifier   = null ,

	@Treshhold float   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [CustomerDefinitionID]
	, [CustomerId]
	, [Treshhold]
    FROM
	[dbo].[SpeedwiseCustomer]
    WHERE 
	 ([CustomerDefinitionID] = @CustomerDefinitionId OR @CustomerDefinitionId IS NULL)
	AND ([CustomerId] = @CustomerId OR @CustomerId IS NULL)
	AND ([Treshhold] = @Treshhold OR @Treshhold IS NULL)
						
  END
  ELSE
  BEGIN
    SELECT
	  [CustomerDefinitionID]
	, [CustomerId]
	, [Treshhold]
    FROM
	[dbo].[SpeedwiseCustomer]
    WHERE 
	 ([CustomerDefinitionID] = @CustomerDefinitionId AND @CustomerDefinitionId is not null)
	OR ([CustomerId] = @CustomerId AND @CustomerId is not null)
	OR ([Treshhold] = @Treshhold AND @Treshhold is not null)
	SELECT @@ROWCOUNT			
  END
				


GO
