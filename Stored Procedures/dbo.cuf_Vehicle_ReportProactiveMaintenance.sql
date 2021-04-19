SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Vehicle_ReportProactiveMaintenance]
(
	@uid UNIQUEIDENTIFIER,
	@vids NVARCHAR(MAX) = NULL,
	@sdate DATETIME = NULL,
	@edate DATETIME = NULL
)
AS

	--DECLARE @uid UNIQUEIDENTIFIER,
	--		@vids NVARCHAR(MAX),
	--		@sdate DATETIME,
	--		@edate DATETIME

	--SET @vids = NULL --N'A2A7640A-7CD1-48D3-8270-80A8F2C9FA63'
	--SET @sdate = NULL
	--SET @edate = NULL
	--SET @uid = N'C13C0754-8B33-49BA-8C93-C5CE1A5F6475'


	EXECUTE dbo.[proc_Report_ProactiveMaintenance] 
	   @uid
	  ,@vids
	  ,@sdate
	  ,@edate


GO
