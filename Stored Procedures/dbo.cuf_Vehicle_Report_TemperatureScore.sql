SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_TemperatureScore]
(
	@gids varchar(max),
	@vids varchar(max),
	@sdate datetime,
	@edate datetime,
	@sensorid SMALLINT,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN

	EXECUTE dbo.[proc_ReportTemperatureScore] 
	   @vids
	  ,@gids
	  ,@sdate
	  ,@edate
	  ,@sensorid
	  ,@uid
	  
END




GO
