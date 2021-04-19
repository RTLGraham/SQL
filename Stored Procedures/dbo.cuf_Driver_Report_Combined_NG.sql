SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_Report_Combined_NG]
(
	@dids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid uniqueidentifier,
	@rprtcfgid uniqueidentifier
)
AS
BEGIN

--DECLARE	@dids varchar(max),
--		@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER,
--		@rprtcfgid UNIQUEIDENTIFIER
--
--SET	@dids = N'D24C92B3-2486-4C9A-9C34-9DFA9C18B75D'
--SET	@sdate = '2012-10-01 00:00'
--SET	@edate = '2012-11-04 23:59'
--SET	@uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET	@rprtcfgid = N'583B4D46-F49F-4C93-B55C-4E0BC1E2A96C'

	EXECUTE dbo.[proc_Report_Combined]
	  @dids
	  ,@sdate
	  ,@edate
	  ,@uid
	  ,@rprtcfgid
	  
	
	SELECT    DriverId ,
			  Number ,
			  NumberAlternate ,
			  NumberAlternate2 ,
			  FirstName ,
			  Surname ,
			  MiddleNames ,
			  LastOperation ,
			  Archived
	FROM dbo.Driver
	WHERE DriverId IN (SELECT VALUE FROM dbo.Split(@dids, ','))
	
END

GO
