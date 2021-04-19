SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the ReportConfiguration table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[ReportConfiguration_Insert]
(

	@ReportConfigurationId uniqueidentifier   ,

	@Name varchar (255)  ,

	@Description varchar (MAX)  ,

	@Rdl varchar (255)  ,

	@CustomerId uniqueidentifier   
)
AS


				
				INSERT INTO [dbo].[ReportConfiguration]
					(
					[ReportConfigurationId]
					,[Name]
					,[Description]
					,[RDL]
					,[CustomerId]
					)
				VALUES
					(
					@ReportConfigurationId
					,@Name
					,@Description
					,@Rdl
					,@CustomerId
					)
				
									
							
			


GO
