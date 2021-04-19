SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the GroupTypeTables table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GroupTypeTables_Update]
(

	@GroupTypeId int   ,

	@OriginalGroupTypeId int   ,

	@EntityTableName nvarchar (255)  ,

	@EntityTablePrimaryKey nvarchar (255)  ,

	@EntityProc nvarchar (255)  
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[GroupTypeTables]
				SET
					[GroupTypeId] = @GroupTypeId
					,[EntityTableName] = @EntityTableName
					,[EntityTablePrimaryKey] = @EntityTablePrimaryKey
					,[EntityProc] = @EntityProc
				WHERE
[GroupTypeId] = @OriginalGroupTypeId 
				
			


GO
