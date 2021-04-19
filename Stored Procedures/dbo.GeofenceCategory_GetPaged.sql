SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets records from the GeofenceCategory table passing page index and page count parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GeofenceCategory_GetPaged]
(

	@WhereClause varchar (2000)  ,

	@OrderBy varchar (2000)  ,

	@PageIndex int   ,

	@PageSize int   
)
AS


				
				BEGIN
				DECLARE @PageLowerBound int
				DECLARE @PageUpperBound int
				
				-- Set the page bounds
				SET @PageLowerBound = @PageSize * @PageIndex
				SET @PageUpperBound = @PageLowerBound + @PageSize

				IF (@OrderBy IS NULL OR LEN(@OrderBy) < 1)
				BEGIN
					-- default order by to first column
					SET @OrderBy = '[GeofenceCategoryId]'
				END

				-- SQL Server 2005 Paging
				DECLARE @SQL AS nvarchar(MAX)
				SET @SQL = 'WITH PageIndex AS ('
				SET @SQL = @SQL + ' SELECT'
				IF @PageSize > 0
				BEGIN
					SET @SQL = @SQL + ' TOP ' + CONVERT(nvarchar, @PageUpperBound)
				END
				SET @SQL = @SQL + ' ROW_NUMBER() OVER (ORDER BY ' + @OrderBy + ') as RowIndex'
				SET @SQL = @SQL + ', [GeofenceCategoryId]'
				SET @SQL = @SQL + ', [Name]'
				SET @SQL = @SQL + ', [Description]'
				SET @SQL = @SQL + ', [Colour]'
				SET @SQL = @SQL + ', [LastModified]'
				SET @SQL = @SQL + ', [Archived]'
				SET @SQL = @SQL + ' FROM [dbo].[GeofenceCategory]'
				IF LEN(@WhereClause) > 0
				BEGIN
					SET @SQL = @SQL + ' WHERE ' + @WhereClause
                        SET @SQL = @SQL + ' AND Archived = 0 '

				END
				SET @SQL = @SQL + ' ) SELECT'
				SET @SQL = @SQL + ' [GeofenceCategoryId],'
				SET @SQL = @SQL + ' [Name],'
				SET @SQL = @SQL + ' [Description],'
				SET @SQL = @SQL + ' [Colour],'
				SET @SQL = @SQL + ' [LastModified],'
				SET @SQL = @SQL + ' [Archived]'
				SET @SQL = @SQL + ' FROM PageIndex'
				SET @SQL = @SQL + ' WHERE RowIndex > ' + CONVERT(nvarchar, @PageLowerBound)
				IF @PageSize > 0
				BEGIN
					SET @SQL = @SQL + ' AND RowIndex <= ' + CONVERT(nvarchar, @PageUpperBound)
				END
				SET @SQL = @SQL + ' ORDER BY ' + @OrderBy
				EXEC sp_executesql @SQL
				
				-- get row count
				SET @SQL = 'SELECT COUNT(*) AS TotalRowCount'
				SET @SQL = @SQL + ' FROM [dbo].[GeofenceCategory]'
				IF LEN(@WhereClause) > 0
				BEGIN
					SET @SQL = @SQL + ' WHERE ' + @WhereClause
				END
				EXEC sp_executesql @SQL
			
				END
			


GO
