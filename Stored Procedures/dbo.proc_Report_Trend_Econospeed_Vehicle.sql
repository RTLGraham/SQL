SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_Report_Trend_Econospeed_Vehicle]
(
	@vids VARCHAR(MAX) = NULL,
	@gids VARCHAR(MAX) = NULL,
	@startDate DATETIME,
	@endDate DATETIME,
	@userId UNIQUEIDENTIFIER,
	@groupBy INT
)
AS

	SELECT 1 AS Result


GO
