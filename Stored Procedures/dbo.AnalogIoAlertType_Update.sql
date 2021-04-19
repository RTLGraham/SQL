SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the AnalogIoAlertType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[AnalogIoAlertType_Update]
(

	@AnalogIoAlertTypeId int   ,

	@OriginalAnalogIoAlertTypeId int   ,

	@Name varchar (50)  ,

	@Description varchar (MAX)  ,

	@LastModified datetime   ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[AnalogIoAlertType]
				SET
					[AnalogIoAlertTypeId] = @AnalogIoAlertTypeId
					,[Name] = @Name
					,[Description] = @Description
					,[LastModified] = @LastModified
					,[Archived] = @Archived
				WHERE
[AnalogIoAlertTypeId] = @OriginalAnalogIoAlertTypeId 
				
			


GO
