SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the ReportConfiguration table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[ReportConfiguration_Update]
(

	@ReportConfigurationId uniqueidentifier   ,

	@OriginalReportConfigurationId uniqueidentifier   ,

	@Name varchar (255)  ,

	@Description varchar (MAX)  ,

	@Rdl varchar (255)  ,

	@CustomerId uniqueidentifier   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[ReportConfiguration]
				SET
					[ReportConfigurationId] = @ReportConfigurationId
					,[Name] = @Name
					,[Description] = @Description
					,[RDL] = @Rdl
					,[CustomerId] = @CustomerId
				WHERE
[ReportConfigurationId] = @OriginalReportConfigurationId 
				
			


GO
