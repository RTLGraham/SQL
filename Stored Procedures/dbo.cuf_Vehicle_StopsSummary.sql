SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_StopsSummary]
          @uid      uniqueidentifier,
          @vids     nvarchar(MAX),
          @gids     nvarchar(MAX),
          @sdate    datetime,
          @edate    datetime,
          @InOut	SMALLINT
AS
          EXEC dbo.proc_DashboardReport_StopsSummary @uid, @vids, @gids, @sdate, @edate, @InOut;


GO
