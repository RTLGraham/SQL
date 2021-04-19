SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_TemperatureStatusAccount]
(
	@gids NVARCHAR(MAX),
	@vids NVARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@isAlert01 BIT,
	@isAlert02 BIT,
	@isAlert03 BIT,
	@isAlert04 BIT,
    @isChecked INT
)
AS
BEGIN
	--EXECUTE dbo.[proc_ReportTemperatureStatusAccount] 
	--	   @gids
	--	  ,@vids
	--	  ,@sdate
	--	  ,@edate
	--	  ,@uid;
		  
	EXECUTE dbo.[proc_ReportTemperatureStatusNew] 
	  @gids
	  ,@vids
	  ,@uid
	  ,@isChecked
	  ,@sdate
	  ,@edate
	  ,@isAlert01
	  ,@isAlert02
	  ,@isAlert03
	  ,@isAlert04
		  
END;
GO
