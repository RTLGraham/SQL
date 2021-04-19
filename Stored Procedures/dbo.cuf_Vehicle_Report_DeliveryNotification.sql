SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_DeliveryNotification]
(
	@gids varchar(max),
	@vids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN

	EXECUTE dbo.[proc_ReportDeliveryNotification] 
		   @gids
		   ,@vids
		  ,@sdate
		  ,@edate
		  ,@uid
END


GO
