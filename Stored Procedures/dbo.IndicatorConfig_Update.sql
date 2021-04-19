SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the IndicatorConfig table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[IndicatorConfig_Update]
(

	@IndicatorConfigId int   ,

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


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[IndicatorConfig]
				SET
					[IndicatorId] = @IndicatorId
					,[ReportConfigurationId] = @ReportConfigurationId
					,[Min] = @Min
					,[Max] = @Max
					,[Weight] = @Weight
					,[GYRGreenMax] = @GyrGreenMax
					,[GYRAmberMax] = @GyrAmberMax
					,[Target] = @Target
					,[Archived] = @Archived
					,[LastModified] = @LastModified
					,[GYRRedMax] = @GyrRedMax
				WHERE
[IndicatorConfigId] = @IndicatorConfigId 
				
			


GO
