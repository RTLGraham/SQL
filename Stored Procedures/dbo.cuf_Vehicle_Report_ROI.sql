SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_ROI]
(
	@uid UNIQUEIDENTIFIER,
	@vids NVARCHAR(MAX),
	@sdate DATETIME,
	@edate DATETIME,
	@targetoverrevpc FLOAT,
	@targetidlepc FLOAT,
	@actualoverrevpc FLOAT,
	@actualidlepc FLOAT,
	@fuelcost FLOAT
)
AS

	EXECUTE dbo.[proc_Report_ROI_RDL] 
	   @uid
	  ,@vids
	  ,@sdate
	  ,@edate
	  ,@targetoverrevpc
	  ,@targetidlepc
	  ,@actualoverrevpc
	  ,@actualidlepc
	  ,@fuelcost


GO
