SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the IVH table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[IVH_GetByIvhId]
(

	@IvhId uniqueidentifier   
)
AS


				SELECT
					IVHId ,
                    IVHIntId ,
                    TrackerNumber ,
                    Manufacturer ,
                    Model ,
                    PacketType ,
                    PhoneNumber ,
                    SIMCardNumber ,
                    ServiceProvider ,
                    SerialNumber ,
                    FirmwareVersion ,
                    AntennaType ,
                    LastOperation ,
                    Archived ,
                    IsTag ,
                    IVHTypeId ,
                    IsDev
				FROM
					[dbo].[IVH]
				WHERE
					[IVHId] = @IvhId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
	

GO
