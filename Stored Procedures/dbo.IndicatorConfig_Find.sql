SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the IndicatorConfig table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[IndicatorConfig_Find]
(

	@SearchUsingOR bit   = null ,

	@IndicatorConfigId int   = null ,

	@IndicatorId int   = null ,

	@ReportConfigurationId uniqueidentifier   = null ,

	@Min float   = null ,

	@Max float   = null ,

	@Weight float   = null ,

	@GyrGreenMax float   = null ,

	@GyrAmberMax float   = null ,

	@Target float   = null ,

	@Archived bit   = null ,

	@LastModified datetime   = null ,

	@GyrRedMax float   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [IndicatorConfigId]
	, [IndicatorId]
	, [ReportConfigurationId]
	, [Min]
	, [Max]
	, [Weight]
	, [GYRGreenMax]
	, [GYRAmberMax]
	, [Target]
	, [Archived]
	, [LastModified]
	, [GYRRedMax]
    FROM
	[dbo].[IndicatorConfig]
    WHERE 
	 ([IndicatorConfigId] = @IndicatorConfigId OR @IndicatorConfigId IS NULL)
	AND ([IndicatorId] = @IndicatorId OR @IndicatorId IS NULL)
	AND ([ReportConfigurationId] = @ReportConfigurationId OR @ReportConfigurationId IS NULL)
	AND ([Min] = @Min OR @Min IS NULL)
	AND ([Max] = @Max OR @Max IS NULL)
	AND ([Weight] = @Weight OR @Weight IS NULL)
	AND ([GYRGreenMax] = @GyrGreenMax OR @GyrGreenMax IS NULL)
	AND ([GYRAmberMax] = @GyrAmberMax OR @GyrAmberMax IS NULL)
	AND ([Target] = @Target OR @Target IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([LastModified] = @LastModified OR @LastModified IS NULL)
	AND ([GYRRedMax] = @GyrRedMax OR @GyrRedMax IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [IndicatorConfigId]
	, [IndicatorId]
	, [ReportConfigurationId]
	, [Min]
	, [Max]
	, [Weight]
	, [GYRGreenMax]
	, [GYRAmberMax]
	, [Target]
	, [Archived]
	, [LastModified]
	, [GYRRedMax]
    FROM
	[dbo].[IndicatorConfig]
    WHERE 
	 ([IndicatorConfigId] = @IndicatorConfigId AND @IndicatorConfigId is not null)
	OR ([IndicatorId] = @IndicatorId AND @IndicatorId is not null)
	OR ([ReportConfigurationId] = @ReportConfigurationId AND @ReportConfigurationId is not null)
	OR ([Min] = @Min AND @Min is not null)
	OR ([Max] = @Max AND @Max is not null)
	OR ([Weight] = @Weight AND @Weight is not null)
	OR ([GYRGreenMax] = @GyrGreenMax AND @GyrGreenMax is not null)
	OR ([GYRAmberMax] = @GyrAmberMax AND @GyrAmberMax is not null)
	OR ([Target] = @Target AND @Target is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([LastModified] = @LastModified AND @LastModified is not null)
	OR ([GYRRedMax] = @GyrRedMax AND @GyrRedMax is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
