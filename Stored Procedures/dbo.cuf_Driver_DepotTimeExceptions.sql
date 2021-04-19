SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Driver_DepotTimeExceptions]
	@uid      UNIQUEIDENTIFIER,
    @gids     NVARCHAR(MAX),
    @dids     NVARCHAR(MAX),
    @sdate    DATETIME,
    @edate    DATETIME
AS
	SET NOCOUNT ON;

          EXEC dbo.proc_Report_DepotTimeExceptions @uid, @gids, @dids, @sdate, @edate;


GO
