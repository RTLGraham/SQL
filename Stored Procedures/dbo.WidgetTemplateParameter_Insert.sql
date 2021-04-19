SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the WidgetTemplateParameter table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateParameter_Insert]
(

	@WidgetTemplateParameterId uniqueidentifier    OUTPUT,

	@WidgetTemplateId uniqueidentifier   ,

	@NameId int   ,

	@Value varchar (MAX)  ,

	@Archived bit   
)
AS


				
				Declare @IdentityRowGuids table (WidgetTemplateParameterId uniqueidentifier	)
				INSERT INTO [dbo].[WidgetTemplateParameter]
					(
					[WidgetTemplateID]
					,[NameID]
					,[Value]
					,[Archived]
					)
						OUTPUT INSERTED.WidgetTemplateParameterID INTO @IdentityRowGuids
					
				VALUES
					(
					@WidgetTemplateId
					,@NameId
					,@Value
					,@Archived
					)
				
				SELECT @WidgetTemplateParameterId=WidgetTemplateParameterId	 from @IdentityRowGuids
									
							
			


GO
