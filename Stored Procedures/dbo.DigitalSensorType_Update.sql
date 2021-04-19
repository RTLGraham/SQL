SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the DigitalSensorType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DigitalSensorType_Update]
(

	@DigitalSensorTypeId smallint   ,

	@OriginalDigitalSensorTypeId smallint   ,

	@Name nvarchar (254)  ,

	@Description nvarchar (MAX)  ,

	@OnDescription nvarchar (MAX)  ,

	@OffDescription nvarchar (MAX)  ,

	@IconLocation nvarchar (MAX)  ,

	@LastOperation smalldatetime   ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[DigitalSensorType]
				SET
					[DigitalSensorTypeId] = @DigitalSensorTypeId
					,[Name] = @Name
					,[Description] = @Description
					,[OnDescription] = @OnDescription
					,[OffDescription] = @OffDescription
					,[IconLocation] = @IconLocation
					,[LastOperation] = @LastOperation
					,[Archived] = @Archived
				WHERE
[DigitalSensorTypeId] = @OriginalDigitalSensorTypeId 
				
			


GO
