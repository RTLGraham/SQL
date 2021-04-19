SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_FuelDashboard]
	(
		@gids VARCHAR(MAX),
		@sdate DATETIME,
		@edate DATETIME,
		@uid UNIQUEIDENTIFIER,
        @fuelunitcode CHAR = 'L'
	)
AS
BEGIN
	EXECUTE dbo.[proc_ReportFuelDashboard] @gids,@sdate,@edate,@uid,@fuelunitcode;
END;


GO
