SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_WKD_WorkDiary_GetByDriverId]
(
	@did UNIQUEIDENTIFIER
)
AS
	SELECT TOP 1
		WorkDiaryId ,
		DriverIntId ,
		StartDate ,
		Number ,
		EndDate ,
		Archived ,
		LastOperation
	FROM dbo.WKD_WorkDiary
	WHERE DriverIntId = dbo.GetDriverIntFromId(@did)
		AND EndDate IS NULL
		AND Archived = 0
	ORDER BY StartDate DESC
	

GO
