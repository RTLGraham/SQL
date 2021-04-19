SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the VehicleModeCreationCode table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleModeCreationCode_Find]
(

	@SearchUsingOR bit   = null ,

	@CreationCodeId smallint   = null ,

	@VehicleModeId int   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [CreationCodeId]
	, [VehicleModeId]
    FROM
	[dbo].[VehicleModeCreationCode]
    WHERE 
	 ([CreationCodeId] = @CreationCodeId OR @CreationCodeId IS NULL)
	AND ([VehicleModeId] = @VehicleModeId OR @VehicleModeId IS NULL)
						
  END
  ELSE
  BEGIN
    SELECT
	  [CreationCodeId]
	, [VehicleModeId]
    FROM
	[dbo].[VehicleModeCreationCode]
    WHERE 
	 ([CreationCodeId] = @CreationCodeId AND @CreationCodeId is not null)
	OR ([VehicleModeId] = @VehicleModeId AND @VehicleModeId is not null)
	SELECT @@ROWCOUNT			
  END
				


GO
