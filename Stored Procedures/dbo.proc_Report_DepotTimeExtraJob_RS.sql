SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_DepotTimeExtraJob_RS]
(
	@uid      UNIQUEIDENTIFIER,
    @gids     NVARCHAR(MAX),
    @dids     NVARCHAR(MAX),
    @sdate    DATETIME,
    @edate    DATETIME,
	@types     NVARCHAR(MAX)
	)
AS
BEGIN
	EXECUTE dbo.[proc_KronosAbsense_GetByDriverAndDate] 
		@dids,
		@gids,
		@sdate,
		@types,
		@uid,
		@edate
END

GO
