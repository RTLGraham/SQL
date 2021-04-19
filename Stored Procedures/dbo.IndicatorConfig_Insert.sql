SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the IndicatorConfig table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[IndicatorConfig_Insert]
(

	@IndicatorConfigId int    OUTPUT,

	@IndicatorId int   ,

	@ReportConfigurationId uniqueidentifier   ,

	@Min float   ,

	@Max float   ,

	@Weight float   ,

	@GyrGreenMax float   ,

	@GyrAmberMax float   ,

	@Target float   ,

	@Archived bit   ,

	@LastModified datetime   ,

	@GyrRedMax float   
)
AS


				
				INSERT INTO [dbo].[IndicatorConfig]
					(
					[IndicatorId]
					,[ReportConfigurationId]
					,[Min]
					,[Max]
					,[Weight]
					,[GYRGreenMax]
					,[GYRAmberMax]
					,[Target]
					,[Archived]
					,[LastModified]
					,[GYRRedMax]
					)
				VALUES
					(
					@IndicatorId
					,@ReportConfigurationId
					,@Min
					,@Max
					,@Weight
					,@GyrGreenMax
					,@GyrAmberMax
					,@Target
					,@Archived
					,@LastModified
					,@GyrRedMax
					)
				
				-- Get the identity value
				SET @IndicatorConfigId = SCOPE_IDENTITY()
									
							
			


GO
