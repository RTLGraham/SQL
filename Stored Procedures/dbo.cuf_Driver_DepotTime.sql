SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_DepotTime]
	@uid      UNIQUEIDENTIFIER,
    @gids     NVARCHAR(MAX),
    @dids     NVARCHAR(MAX),
    @sdate    DATETIME,
    @edate    DATETIME,
	@vch	  BIT = NULL,
	@other	  BIT = NULL,
	@exclude  BIT = NULL
AS
	SET NOCOUNT ON;

          EXEC dbo.proc_Report_DepotTime @uid, @gids, @dids, @sdate, @edate, @vch, @other, @exclude;

GO
