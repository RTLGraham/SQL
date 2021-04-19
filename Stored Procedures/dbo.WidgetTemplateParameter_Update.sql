SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the WidgetTemplateParameter table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateParameter_Update]
(

	@WidgetTemplateParameterId uniqueidentifier   ,

	@WidgetTemplateId uniqueidentifier   ,

	@NameId int   ,

	@Value varchar (MAX)  ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[WidgetTemplateParameter]
				SET
					[WidgetTemplateID] = @WidgetTemplateId
					,[NameID] = @NameId
					,[Value] = @Value
					,[Archived] = @Archived
				WHERE
[WidgetTemplateParameterID] = @WidgetTemplateParameterId 
				
			


GO
