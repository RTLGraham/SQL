SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the AnalogIoAlertType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[AnalogIoAlertType_Insert]
(

	@AnalogIoAlertTypeId int   ,

	@Name varchar (50)  ,

	@Description varchar (MAX)  ,

	@LastModified datetime   ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[AnalogIoAlertType]
					(
					[AnalogIoAlertTypeId]
					,[Name]
					,[Description]
					,[LastModified]
					,[Archived]
					)
				VALUES
					(
					@AnalogIoAlertTypeId
					,@Name
					,@Description
					,@LastModified
					,@Archived
					)
				
									
							
			


GO
