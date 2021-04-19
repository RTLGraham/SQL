SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_EconospeedFuel]
(
	@uid UNIQUEIDENTIFIER,
	@vids VARCHAR(MAX),
	@sdate datetime,
	@edate datetime
)
AS
BEGIN
	EXECUTE dbo.[proc_Report_EconospeedFuel] 
		   @uid
		  ,@vids
		  ,@sdate
		  ,@edate
END





GO
