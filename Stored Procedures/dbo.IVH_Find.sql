SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the IVH table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[IVH_Find]
(

	@SearchUsingOR bit   = null ,

	@IvhId uniqueidentifier   = null ,

	@IvhIntId int   = null ,

	@TrackerNumber varchar (50)  = null ,

	@Manufacturer varchar (50)  = null ,

	@Model varchar (50)  = null ,

	@PacketType varchar (50)  = null ,

	@PhoneNumber varchar (50)  = null ,

	@SimCardNumber varchar (50)  = null ,

	@ServiceProvider varchar (50)  = null ,

	@SerialNumber varchar (50)  = null ,

	@FirmwareVersion varchar (50)  = null ,

	@AntennaType varchar (50)  = null ,

	@LastOperation smalldatetime   = null ,

	@Archived bit   = null ,

	@IsTag bit   = null ,
	
	@IVHTypeId INT = null
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [IVHId]
	, [IVHIntId]
	, [TrackerNumber]
	, [Manufacturer]
	, [Model]
	, [PacketType]
	, [PhoneNumber]
	, [SIMCardNumber]
	, [ServiceProvider]
	, [SerialNumber]
	, [FirmwareVersion]
	, [AntennaType]
	, [LastOperation]
	, [Archived]
	, [IsTag]
	, [IVHTypeId]
    FROM
	[dbo].[IVH]
    WHERE 
	 ([IVHId] = @IvhId OR @IvhId IS NULL)
	AND ([IVHIntId] = @IvhIntId OR @IvhIntId IS NULL)
	AND ([TrackerNumber] = @TrackerNumber OR @TrackerNumber IS NULL)
	AND ([Manufacturer] = @Manufacturer OR @Manufacturer IS NULL)
	AND ([Model] = @Model OR @Model IS NULL)
	AND ([PacketType] = @PacketType OR @PacketType IS NULL)
	AND ([PhoneNumber] = @PhoneNumber OR @PhoneNumber IS NULL)
	AND ([SIMCardNumber] = @SimCardNumber OR @SimCardNumber IS NULL)
	AND ([ServiceProvider] = @ServiceProvider OR @ServiceProvider IS NULL)
	AND ([SerialNumber] = @SerialNumber OR @SerialNumber IS NULL)
	AND ([FirmwareVersion] = @FirmwareVersion OR @FirmwareVersion IS NULL)
	AND ([AntennaType] = @AntennaType OR @AntennaType IS NULL)
	AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([IsTag] = @IsTag OR @IsTag IS NULL)
	AND ([IVHTypeId] = @IVHTypeId OR @IVHTypeId IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [IVHId]
	, [IVHIntId]
	, [TrackerNumber]
	, [Manufacturer]
	, [Model]
	, [PacketType]
	, [PhoneNumber]
	, [SIMCardNumber]
	, [ServiceProvider]
	, [SerialNumber]
	, [FirmwareVersion]
	, [AntennaType]
	, [LastOperation]
	, [Archived]
	, [IsTag]
	, [IVHTypeId]
    FROM
	[dbo].[IVH]
    WHERE 
	 ([IVHId] = @IvhId AND @IvhId is not null)
	OR ([IVHIntId] = @IvhIntId AND @IvhIntId is not null)
	OR ([TrackerNumber] = @TrackerNumber AND @TrackerNumber is not null)
	OR ([Manufacturer] = @Manufacturer AND @Manufacturer is not null)
	OR ([Model] = @Model AND @Model is not null)
	OR ([PacketType] = @PacketType AND @PacketType is not null)
	OR ([PhoneNumber] = @PhoneNumber AND @PhoneNumber is not null)
	OR ([SIMCardNumber] = @SimCardNumber AND @SimCardNumber is not null)
	OR ([ServiceProvider] = @ServiceProvider AND @ServiceProvider is not null)
	OR ([SerialNumber] = @SerialNumber AND @SerialNumber is not null)
	OR ([FirmwareVersion] = @FirmwareVersion AND @FirmwareVersion is not null)
	OR ([AntennaType] = @AntennaType AND @AntennaType is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([IsTag] = @IsTag AND @IsTag is not null)
	OR ([IVHTypeId] = @IVHTypeId OR @IVHTypeId IS NULL)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				



GO
