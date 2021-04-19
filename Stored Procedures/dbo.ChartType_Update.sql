SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the ChartType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[ChartType_Update]
(

	@ChartTypeId int   ,

	@OriginalChartTypeId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@LastModified datetime   ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[ChartType]
				SET
					[ChartTypeId] = @ChartTypeId
					,[Name] = @Name
					,[Description] = @Description
					,[LastModified] = @LastModified
					,[Archived] = @Archived
				WHERE
[ChartTypeId] = @OriginalChartTypeId 
				
			


GO
