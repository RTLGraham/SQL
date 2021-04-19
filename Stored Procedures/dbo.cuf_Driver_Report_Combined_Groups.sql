SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Driver_Report_Combined_Groups]
(
	@gids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid uniqueidentifier,
	@rprtcfgid uniqueidentifier
)
AS
BEGIN
	--DECLARE	@gids varchar(max),
	--		@sdate datetime,
	--		@edate datetime,
	--		@uid uniqueidentifier,
	--		@rprtcfgid UNIQUEIDENTIFIER

	--SET @gids = N'742352F6-6162-4E3F-BF93-0A90D1954466,1189B49A-D124-4A25-9F8C-3DE9EC2AF15D,1317E9AD-176A-49EA-BC6A-06D8A129EABC'
	--SET @sdate = '2011-07-01 00:00'
	--SET @edate = '2011-08-01 00:00'
	--SET @uid = N'4C0A0D44-0685-4292-9087-F32E03F10134' 
	--SET @rprtcfgid = N'77C80BDB-5827-4C5E-BBF4-06F36ACB47D6' 

	EXECUTE dbo.[proc_Report_CombinedGroups_Drivers]
	  @gids
	  ,@sdate
	  ,@edate
	  ,@uid
	  ,@rprtcfgid

END



GO
