SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_LoneWorkerMobile]
(
	@uid UNIQUEIDENTIFIER,
      @gids NVARCHAR(MAX),
      @dids NVARCHAR(MAX),
      @sdate DATETIME,
      @edate DATETIME
)
AS
	EXECUTE dbo.proc_LoneWorker_Mobile @uid, @gids, @dids, @sdate, @edate

GO
