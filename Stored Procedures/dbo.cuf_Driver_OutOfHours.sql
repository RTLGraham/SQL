SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Driver_OutOfHours]
	@uid      uniqueidentifier,
          @dids     nvarchar(MAX),
          @sdate    datetime,
          @edate    datetime
AS
	SET NOCOUNT ON;

          EXEC dbo.proc_Report_OutOfHours null, @dids, @sdate, @edate, @uid;
GO
