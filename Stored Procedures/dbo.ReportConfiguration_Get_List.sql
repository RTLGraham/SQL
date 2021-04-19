SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the ReportConfiguration table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[ReportConfiguration_Get_List]

AS


				
				SELECT
					[ReportConfigurationId],
					[Name],
					[Description],
					[RDL],
					[CustomerId]
				FROM
					[dbo].[ReportConfiguration]

				SELECT @@ROWCOUNT
			


GO
