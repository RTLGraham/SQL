SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the WidgetTemplateHistory table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateHistory_Insert]
(

	@WidgetTemplateHistoryId uniqueidentifier    OUTPUT,

	@WidgetTemplateId uniqueidentifier   ,

	@DateClosed datetime   ,

	@UserId uniqueidentifier   ,

	@Archived bit   
)
AS


				
				Declare @IdentityRowGuids table (WidgetTemplateHistoryId uniqueidentifier	)
				INSERT INTO [dbo].[WidgetTemplateHistory]
					(
					[WidgetTemplateID]
					,[DateClosed]
					,[UserID]
					,[Archived]
					)
						OUTPUT INSERTED.WidgetTemplateHistoryID INTO @IdentityRowGuids
					
				VALUES
					(
					@WidgetTemplateId
					,@DateClosed
					,@UserId
					,@Archived
					)
				
				SELECT @WidgetTemplateHistoryId=WidgetTemplateHistoryId	 from @IdentityRowGuids
									
							
			


GO
