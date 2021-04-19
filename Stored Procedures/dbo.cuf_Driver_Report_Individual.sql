SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_Report_Individual]
(
	@did uniqueidentifier,
	@sdate datetime,
	@edate datetime
)
AS

	--DECLARE	@did uniqueidentifier,
	--		@sdate datetime,
	--		@edate datetime
	
	--SET	@did = N'65157504-BE98-45E5-8079-8CD2200F0503'
	--SET	@sdate = '2015-08-01 00:00'
	--SET	@edate = '2015-10-04 23:59'

		IF OBJECT_ID('dbo.DriverMobileActivity') IS NOT NULL 
	BEGIN 
		INSERT INTO dbo.DriverMobileActivity(DriverId,StoredProcedure,StartDate,EndDate,GuidParam,IntParam,StringParam)
		VALUES (@did, OBJECT_NAME(@@PROCID), @sdate, @edate, NULL, NULL, NULL)
	END

	DECLARE @uid UNIQUEIDENTIFIER,
			@rprtcfgid UNIQUEIDENTIFIER

	SELECT TOP 1 @uid = u.UserID
	FROM dbo.[User] u
	INNER JOIN dbo.Customer c ON c.CustomerId = u.CustomerID
	INNER JOIN dbo.CustomerDriver cd ON cd.CustomerId = c.CustomerId
	WHERE cd.DriverId = @did
	  AND cd.Archived = 0
	  AND u.Archived = 0
	  AND cd.EndDate IS NULL	

	/* 1. Dataset & Driver*/

	SELECT @rprtcfgid = cp.Value
	FROM dbo.CustomerPreference cp
	INNER JOIN dbo.Customer c ON c.CustomerId = cp.CustomerID
	INNER JOIN dbo.CustomerDriver cd ON cd.CustomerId = c.CustomerId
	WHERE cd.DriverId = @did
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL
	  AND cp.NameID = 3002 -- Driver Individual Report Config

	EXECUTE [dbo].[cuf_Driver_Report_Coaching] 
		@did
		,@sdate
		,@edate
		,@uid
		,@rprtcfgid
		,1
		,1
		,0
	  
	/* 2. Config */

	EXECUTE [dbo].[cuf_IndicatorConfig_GetByReportConfig]  @rprtcfgid


GO
