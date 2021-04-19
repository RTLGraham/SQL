SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportSpeedingDrivers_RS]
	-- Add the parameters for the stored procedure here
	@did NVARCHAR(MAX) = NULL, 
    @uid UNIQUEIDENTIFIER = NULL,
	@sdate DATETIME = NULL, 
	@edate DATETIME = NULL,
	@highonly BIT = NULL	
AS
BEGIN

--SELECT TOP 10 * FROM dbo.Log ORDER BY LogID DESC
	/* Test data */
	--DECLARE @vid NVARCHAR(max),
	--		@uid UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME
	--/*CH 0025 Rümlang: B04062C4-67FA-41A9-9BFC-4776782653B4*/
	--SET @vid = N'6B66D0A6-3464-4EB1-8030-A490EB93D9AB'
	--SET @uid = N'7DD8D899-060F-43EF-AD45-26C3FFC439BD'
	--SET @sdate = DATEADD(DAY, -31, GETDATE())
	--SET @edate = GETDATE()
	IF datepart(yyyy, @sdate) = '1960'
	BEGIN
		SET @edate = dbo.Calc_Schedule_EndDate(@sdate, @uid)
		SET @sdate = dbo.Calc_Schedule_StartDate(@sdate, @uid)
	END
	
	
	
	--EXECUTE dbo.[clr_GetSpeedingStreetsByDriver]  
	--	@did, 
	--	@sdate, 
	--	@edate,
	--	@uid
	EXECUTE [dbo].[proc_ReportSpeedingDrivers] 
	   @did
	  ,@uid
	  ,@sdate
	  ,@edate
	  ,@highonly
END





GO
