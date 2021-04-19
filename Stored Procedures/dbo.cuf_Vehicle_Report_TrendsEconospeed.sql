SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_TrendsEconospeed]
(
	@vids varchar(max) = NULL,
	@gids varchar(max) = NULL,
	@startDate datetime,
	@endDate datetime,
	@userId uniqueidentifier,
	
	@groupBy INT,
	@rptlevel INT = NULL
)
AS

		EXEC dbo.proc_Report_Trend_Econospeed_Vehicle
	  				@vids = @vids,
                    @gids = @gids,
                    @startDate = @startDate,
                    @endDate = @endDate,
                    @userId = @userId,
                    @groupBy = @groupBy;


GO
