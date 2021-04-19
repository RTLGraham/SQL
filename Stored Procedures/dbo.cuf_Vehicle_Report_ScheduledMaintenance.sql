SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_ScheduledMaintenance]
          @uid uniqueidentifier,
          @gids nvarchar(MAX),
          @vids nvarchar(MAX)
AS
          EXEC dbo.proc_Report_ScheduledMaintenance @uid, @gids, @vids;
GO
