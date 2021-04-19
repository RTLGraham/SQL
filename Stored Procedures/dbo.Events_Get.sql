SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets records from the Events view passing page index and page count parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Events_Get]
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
					SET @OrderBy = '[VehicleId]'
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
				SET @SQL = @SQL + ', [VehicleId]'
				SET @SQL = @SQL + ', [IVHId]'
				SET @SQL = @SQL + ', [DriverId]'
				SET @SQL = @SQL + ', [CreationCodeId]'
				SET @SQL = @SQL + ', [Long]'
				SET @SQL = @SQL + ', [Lat]'
				SET @SQL = @SQL + ', [Heading]'
				SET @SQL = @SQL + ', [Speed]'
				SET @SQL = @SQL + ', [TripDistance]'
				SET @SQL = @SQL + ', [EventDateTime]'
				SET @SQL = @SQL + ', [DigitalIO]'
				SET @SQL = @SQL + ', [FlagId]'
				SET @SQL = @SQL + ', [LastOperation]'
				SET @SQL = @SQL + ', [Archived]'
				SET @SQL = @SQL + ', [DepotId]'
				SET @SQL = @SQL + ', [EventId]'
				SET @SQL = @SQL + ', [AttachedVehicleId]'
				SET @SQL = @SQL + ' FROM [dbo].[Events]'
				IF LEN(@WhereClause) > 0
				BEGIN
					SET @SQL = @SQL + ' WHERE ' + @WhereClause
				END
				SET @SQL = @SQL + ' ) SELECT'
				SET @SQL = @SQL + ' [VehicleId],'
				SET @SQL = @SQL + ' [IVHId],'
				SET @SQL = @SQL + ' [DriverId],'
				SET @SQL = @SQL + ' [CreationCodeId],'
				SET @SQL = @SQL + ' [Long],'
				SET @SQL = @SQL + ' [Lat],'
				SET @SQL = @SQL + ' [Heading],'
				SET @SQL = @SQL + ' [Speed],'
				SET @SQL = @SQL + ' [TripDistance],'
				SET @SQL = @SQL + ' [EventDateTime],'
				SET @SQL = @SQL + ' [DigitalIO],'
				SET @SQL = @SQL + ' [FlagId],'
				SET @SQL = @SQL + ' [LastOperation],'
				SET @SQL = @SQL + ' [Archived],'
				SET @SQL = @SQL + ' [DepotId],'
				SET @SQL = @SQL + ' [EventId],'
				SET @SQL = @SQL + ' [AttachedVehicleId]'
				SET @SQL = @SQL + ' FROM PageIndex'
				SET @SQL = @SQL + ' WHERE RowIndex > ' + CONVERT(nvarchar, @PageLowerBound)
				IF @PageSize > 0
				BEGIN
					SET @SQL = @SQL + ' AND RowIndex <= ' + CONVERT(nvarchar, @PageUpperBound)
				END
				IF LEN(@OrderBy) > 0
				BEGIN
					SET @SQL = @SQL + ' ORDER BY ' + @OrderBy
				END
				EXEC sp_executesql @SQL

				-- get row count
				SET @SQL = 'SELECT COUNT(*) AS TotalRowCount'
				SET @SQL = @SQL + ' FROM [dbo].[Events]'
				IF LEN(@WhereClause) > 0
				BEGIN
					SET @SQL = @SQL + ' WHERE ' + @WhereClause
                        SET @SQL = @SQL + ' AND Archived = 0 '
				END
				EXEC sp_executesql @SQL
				
				END
			


GO
