SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_Characteristics]
(
	@vid UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME
)
AS

EXECUTE dbo.[proc_ReportCharacteristics] 
   @vid
  ,@uid
  ,@sdate
  ,@edate




GO
