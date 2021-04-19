SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_VehicleCameraOffReport_RS]
          @uid UNIQUEIDENTIFIER,
          @vids NVARCHAR(MAX),
		  @sdate DATETIME,
		  @edate DATETIME 
AS
	SET NOCOUNT ON;

	EXECUTE dbo.[cuf_Vehicle_CameraOffReport] 
	   @uid
	  ,@vids
	  ,@sdate
	  ,@edate

GO
