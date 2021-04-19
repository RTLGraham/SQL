SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_OutOfHours]
	@uid      uniqueidentifier,
          @vids     nvarchar(MAX),
          @sdate    datetime,
          @edate    datetime
AS
	SET NOCOUNT ON;

          EXEC dbo.proc_Report_OutOfHours @vids, null, @sdate, @edate, @uid;
GO
