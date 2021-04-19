SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the GroupTypeTables table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GroupTypeTables_Insert]
(

	@GroupTypeId int   ,

	@EntityTableName nvarchar (255)  ,

	@EntityTablePrimaryKey nvarchar (255)  ,

	@EntityProc nvarchar (255)  
)
AS


				
				INSERT INTO [dbo].[GroupTypeTables]
					(
					[GroupTypeId]
					,[EntityTableName]
					,[EntityTablePrimaryKey]
					,[EntityProc]
					)
				VALUES
					(
					@GroupTypeId
					,@EntityTableName
					,@EntityTablePrimaryKey
					,@EntityProc
					)
				
									
							
			


GO
