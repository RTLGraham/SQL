SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the Reporting table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Reporting_Delete]
(

	@ReportingId bigint   
)
AS


				    DELETE FROM [dbo].[Reporting] WITH (ROWLOCK) 
				WHERE
					[ReportingId] = @ReportingId
					
			


GO
