SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_Idling]
	@uid      uniqueidentifier,
          @vids     nvarchar(MAX),
          @sdate    datetime,
          @edate    DATETIME,
          @mingap	INT
AS
	SET NOCOUNT ON;

          EXEC dbo.proc_Report_Idling @uid, @vids, null, @sdate, @edate, @mingap;

GO
