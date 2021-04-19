SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the DigitalSensorType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DigitalSensorType_Insert]
(

	@DigitalSensorTypeId smallint   ,

	@Name nvarchar (254)  ,

	@Description nvarchar (MAX)  ,

	@OnDescription nvarchar (MAX)  ,

	@OffDescription nvarchar (MAX)  ,

	@IconLocation nvarchar (MAX)  ,

	@LastOperation smalldatetime   ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[DigitalSensorType]
					(
					[DigitalSensorTypeId]
					,[Name]
					,[Description]
					,[OnDescription]
					,[OffDescription]
					,[IconLocation]
					,[LastOperation]
					,[Archived]
					)
				VALUES
					(
					@DigitalSensorTypeId
					,@Name
					,@Description
					,@OnDescription
					,@OffDescription
					,@IconLocation
					,@LastOperation
					,@Archived
					)
				
									
							
			


GO
