SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets records from the Reporting table passing page index and page count parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Reporting_GetPaged]
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
					SET @OrderBy = '[ReportingId]'
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
				SET @SQL = @SQL + ', [ReportingId]'
				SET @SQL = @SQL + ', [VehicleIntId]'
				SET @SQL = @SQL + ', [DriverIntId]'
				SET @SQL = @SQL + ', [InSweetSpotDistance]'
				SET @SQL = @SQL + ', [FueledOverRPMDistance]'
				SET @SQL = @SQL + ', [TopGearDistance]'
				SET @SQL = @SQL + ', [CruiseControlDistance]'
				SET @SQL = @SQL + ', [CoastInGearDistance]'
				SET @SQL = @SQL + ', [IdleTime]'
				SET @SQL = @SQL + ', [TotalTime]'
				SET @SQL = @SQL + ', [EngineBrakeDistance]'
				SET @SQL = @SQL + ', [ServiceBrakeDistance]'
				SET @SQL = @SQL + ', [EngineBrakeOverRPMDistance]'
				SET @SQL = @SQL + ', [ROPCount]'
				SET @SQL = @SQL + ', [OverSpeedDistance]'
				SET @SQL = @SQL + ', [CoastOutOfGearDistance]'
				SET @SQL = @SQL + ', [PanicStopCount]'
				SET @SQL = @SQL + ', [TotalFuel]'
				SET @SQL = @SQL + ', [TimeNoID]'
				SET @SQL = @SQL + ', [TimeID]'
				SET @SQL = @SQL + ', [DrivingDistance]'
				SET @SQL = @SQL + ', [PTOMovingDistance]'
				SET @SQL = @SQL + ', [Date]'
				SET @SQL = @SQL + ', [Rows]'
				SET @SQL = @SQL + ', [DrivingFuel]'
				SET @SQL = @SQL + ', [PTOMovingTime]'
				SET @SQL = @SQL + ', [PTOMovingFuel]'
				SET @SQL = @SQL + ', [PTONonMovingTime]'
				SET @SQL = @SQL + ', [PTONonMovingFuel]'
				SET @SQL = @SQL + ', [DigitalInput2Count]'
				SET @SQL = @SQL + ', [RouteID]'
				SET @SQL = @SQL + ', [PassengerComfort]'
				SET @SQL = @SQL + ' FROM [dbo].[Reporting]'
				IF LEN(@WhereClause) > 0
				BEGIN
					SET @SQL = @SQL + ' WHERE ' + @WhereClause

				END
				SET @SQL = @SQL + ' ) SELECT'
				SET @SQL = @SQL + ' [ReportingId],'
				SET @SQL = @SQL + ' [VehicleIntId],'
				SET @SQL = @SQL + ' [DriverIntId],'
				SET @SQL = @SQL + ' [InSweetSpotDistance],'
				SET @SQL = @SQL + ' [FueledOverRPMDistance],'
				SET @SQL = @SQL + ' [TopGearDistance],'
				SET @SQL = @SQL + ' [CruiseControlDistance],'
				SET @SQL = @SQL + ' [CoastInGearDistance],'
				SET @SQL = @SQL + ' [IdleTime],'
				SET @SQL = @SQL + ' [TotalTime],'
				SET @SQL = @SQL + ' [EngineBrakeDistance],'
				SET @SQL = @SQL + ' [ServiceBrakeDistance],'
				SET @SQL = @SQL + ' [EngineBrakeOverRPMDistance],'
				SET @SQL = @SQL + ' [ROPCount],'
				SET @SQL = @SQL + ' [OverSpeedDistance],'
				SET @SQL = @SQL + ' [CoastOutOfGearDistance],'
				SET @SQL = @SQL + ' [PanicStopCount],'
				SET @SQL = @SQL + ' [TotalFuel],'
				SET @SQL = @SQL + ' [TimeNoID],'
				SET @SQL = @SQL + ' [TimeID],'
				SET @SQL = @SQL + ' [DrivingDistance],'
				SET @SQL = @SQL + ' [PTOMovingDistance],'
				SET @SQL = @SQL + ' [Date],'
				SET @SQL = @SQL + ' [Rows],'
				SET @SQL = @SQL + ' [DrivingFuel],'
				SET @SQL = @SQL + ' [PTOMovingTime],'
				SET @SQL = @SQL + ' [PTOMovingFuel],'
				SET @SQL = @SQL + ' [PTONonMovingTime],'
				SET @SQL = @SQL + ' [PTONonMovingFuel],'
				SET @SQL = @SQL + ' [DigitalInput2Count],'
				SET @SQL = @SQL + ' [RouteID],'
				SET @SQL = @SQL + ' [PassengerComfort]'
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
				SET @SQL = @SQL + ' FROM [dbo].[Reporting]'
				IF LEN(@WhereClause) > 0
				BEGIN
					SET @SQL = @SQL + ' WHERE ' + @WhereClause
				END
				EXEC sp_executesql @SQL
			
				END
			


GO
