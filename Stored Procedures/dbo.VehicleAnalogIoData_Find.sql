SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the VehicleAnalogIoData table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleAnalogIoData_Find]
(

	@SearchUsingOR bit   = null ,

	@VehicleAnalogIoDataId bigint   = null ,

	@VehicleIntId int   = null ,

	@DriverIntId int   = null ,

	@EventDateTime datetime   = null ,

	@Lat float   = null ,

	@SafeNameLong float   = null ,

	@Speed tinyint   = null ,

	@KeyOn bit   = null ,

	@Value varchar (MAX)  = null ,

	@Archived bit   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [VehicleAnalogIoDataId]
	, [VehicleIntId]
	, [DriverIntId]
	, [EventDateTime]
	, [Lat]
	, [Long]
	, [Speed]
	, [KeyOn]
	, [Value]
	, [Archived]
    FROM
	[dbo].[VehicleAnalogIoData]
    WHERE 
	 ([VehicleAnalogIoDataId] = @VehicleAnalogIoDataId OR @VehicleAnalogIoDataId IS NULL)
	AND ([VehicleIntId] = @VehicleIntId OR @VehicleIntId IS NULL)
	AND ([DriverIntId] = @DriverIntId OR @DriverIntId IS NULL)
	AND ([EventDateTime] = @EventDateTime OR @EventDateTime IS NULL)
	AND ([Lat] = @Lat OR @Lat IS NULL)
	AND ([Long] = @SafeNameLong OR @SafeNameLong IS NULL)
	AND ([Speed] = @Speed OR @Speed IS NULL)
	AND ([KeyOn] = @KeyOn OR @KeyOn IS NULL)
	AND ([Value] = @Value OR @Value IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [VehicleAnalogIoDataId]
	, [VehicleIntId]
	, [DriverIntId]
	, [EventDateTime]
	, [Lat]
	, [Long]
	, [Speed]
	, [KeyOn]
	, [Value]
	, [Archived]
    FROM
	[dbo].[VehicleAnalogIoData]
    WHERE 
	 ([VehicleAnalogIoDataId] = @VehicleAnalogIoDataId AND @VehicleAnalogIoDataId is not null)
	OR ([VehicleIntId] = @VehicleIntId AND @VehicleIntId is not null)
	OR ([DriverIntId] = @DriverIntId AND @DriverIntId is not null)
	OR ([EventDateTime] = @EventDateTime AND @EventDateTime is not null)
	OR ([Lat] = @Lat AND @Lat is not null)
	OR ([Long] = @SafeNameLong AND @SafeNameLong is not null)
	OR ([Speed] = @Speed AND @Speed is not null)
	OR ([KeyOn] = @KeyOn AND @KeyOn is not null)
	OR ([Value] = @Value AND @Value is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
