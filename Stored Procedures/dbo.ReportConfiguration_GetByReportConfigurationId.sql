SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the ReportConfiguration table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[ReportConfiguration_GetByReportConfigurationId]
(

	@ReportConfigurationId uniqueidentifier   
)
AS


				SELECT
					[ReportConfigurationId],
					[Name],
					[Description],
					[RDL],
					[CustomerId]
				FROM
					[dbo].[ReportConfiguration]
				WHERE
					[ReportConfigurationId] = @ReportConfigurationId
				SELECT @@ROWCOUNT
					
			


GO
