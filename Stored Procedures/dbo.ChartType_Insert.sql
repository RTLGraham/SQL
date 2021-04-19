SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the ChartType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[ChartType_Insert]
(

	@ChartTypeId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@LastModified datetime   ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[ChartType]
					(
					[ChartTypeId]
					,[Name]
					,[Description]
					,[LastModified]
					,[Archived]
					)
				VALUES
					(
					@ChartTypeId
					,@Name
					,@Description
					,@LastModified
					,@Archived
					)
				
									
							
			


GO
