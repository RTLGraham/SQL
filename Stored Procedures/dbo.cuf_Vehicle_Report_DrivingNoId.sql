SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_DrivingNoId]
(
	@gids VARCHAR(MAX),
	@vids VARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN

	EXECUTE dbo.[proc_Report_DrivingNoId] 
	   @gids
	  ,@vids
	  ,@sdate
	  ,@edate
	  ,@uid
END


GO
