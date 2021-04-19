SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [dbo].[cu_Geofence_ReportAbsence]
(
		@vids NVARCHAR(MAX),
		@geoid UNIQUEIDENTIFIER,
		@uid UNIQUEIDENTIFIER,
		@sdate DATETIME,
		@edate DATETIME
)
AS
BEGIN
	--DECLARE @vids NVARCHAR(MAX),
	--		@geoid UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME,
	--		@uid UNIQUEIDENTIFIER

	--SET @vids = N'8F2224CE-C44B-44D1-B661-4CFE0337B903'
	--SET @sdate = '2010-10-05 00:07:00'
	--SET @edate = '2010-10-05 23:59:00'
	--SET @uid = N'7baee9c3-1b0e-49fc-a98d-d5a2d6adf8ca'
	--SET @geoid = N''

	EXECUTE [dbo].[proc_ReportGeofenceAbsenceHistory] 
	   @vids
	  ,@geoid
	  ,@sdate
	  ,@edate
	  ,@uid

END

GO
