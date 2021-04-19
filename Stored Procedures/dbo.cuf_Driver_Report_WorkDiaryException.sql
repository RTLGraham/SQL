SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_Report_WorkDiaryException]
(
	@did UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@uid uniqueidentifier
)
AS
BEGIN

	SELECT	1 AS Col1, 
			2 AS Col2, 
			3 AS Col3, 
			4 AS Col4, 
			5 AS Col5

END


GO
