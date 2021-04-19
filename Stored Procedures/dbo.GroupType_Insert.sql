SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the GroupType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GroupType_Insert]
(

	@GroupTypeId int   ,

	@GroupTypeName nvarchar (255)  ,

	@GroupTypeDescription nvarchar (MAX)  
)
AS


				
				INSERT INTO [dbo].[GroupType]
					(
					[GroupTypeId]
					,[GroupTypeName]
					,[GroupTypeDescription]
					)
				VALUES
					(
					@GroupTypeId
					,@GroupTypeName
					,@GroupTypeDescription
					)
				
									
							
			


GO
