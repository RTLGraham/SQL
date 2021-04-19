SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the ReportConfiguration table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[ReportConfiguration_Find]
(

	@SearchUsingOR bit   = null ,

	@ReportConfigurationId uniqueidentifier   = null ,

	@Name varchar (255)  = null ,

	@Description varchar (MAX)  = null ,

	@Rdl varchar (255)  = null ,

	@CustomerId uniqueidentifier   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [ReportConfigurationId]
	, [Name]
	, [Description]
	, [RDL]
	, [CustomerId]
    FROM
	[dbo].[ReportConfiguration]
    WHERE 
	 ([ReportConfigurationId] = @ReportConfigurationId OR @ReportConfigurationId IS NULL)
	AND ([Name] = @Name OR @Name IS NULL)
	AND ([Description] = @Description OR @Description IS NULL)
	AND ([RDL] = @Rdl OR @Rdl IS NULL)
	AND ([CustomerId] = @CustomerId OR @CustomerId IS NULL)
						
  END
  ELSE
  BEGIN
    SELECT
	  [ReportConfigurationId]
	, [Name]
	, [Description]
	, [RDL]
	, [CustomerId]
    FROM
	[dbo].[ReportConfiguration]
    WHERE 
	 ([ReportConfigurationId] = @ReportConfigurationId AND @ReportConfigurationId is not null)
	OR ([Name] = @Name AND @Name is not null)
	OR ([Description] = @Description AND @Description is not null)
	OR ([RDL] = @Rdl AND @Rdl is not null)
	OR ([CustomerId] = @CustomerId AND @CustomerId is not null)
	SELECT @@ROWCOUNT			
  END
				


GO
