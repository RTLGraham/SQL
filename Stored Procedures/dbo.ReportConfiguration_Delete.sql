SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the ReportConfiguration table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[ReportConfiguration_Delete]
(

	@ReportConfigurationId uniqueidentifier   
)
AS


				    DELETE FROM [dbo].[ReportConfiguration] WITH (ROWLOCK) 
				WHERE
					[ReportConfigurationId] = @ReportConfigurationId
					
			


GO
