SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_Idling]
	@uid      uniqueidentifier,
          @dids     nvarchar(MAX),
          @sdate    datetime,
          @edate    DATETIME,
          @mingap	INT
AS
	SET NOCOUNT ON;

          EXEC dbo.proc_Report_Idling @uid, null, @dids, @sdate, @edate, @mingap;
GO
