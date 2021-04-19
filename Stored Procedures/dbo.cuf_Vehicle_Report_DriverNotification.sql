SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_DriverNotification]
(
	@gids VARCHAR(MAX),
	@vids VARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN

	EXECUTE dbo.[proc_Report_DriverNotification] 
	   @gids
	  ,@vids
	  ,@sdate
	  ,@edate
	  ,@uid
END

GO
