SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_Report_OutOfHours]
	@vids	NVARCHAR(MAX) = NULL,
	@dids	NVARCHAR(MAX) = NULL,
	@sdate	DATETIME,
	@edate	DATETIME,
	@uid	UNIQUEIDENTIFIER
AS
BEGIN

	-- Determine whether to run the report by vehicle or by driver for performance purposes
	IF @dids != '' AND @dids IS NOT NULL
    BEGIN
		EXEC proc_Report_OutOfHours_Driver @vids, @dids, @sdate, @edate, @uid
	END	ELSE
    BEGIN
		EXEC proc_Report_OutOfHours_Vehicle @vids, @dids, @sdate, @edate, @uid
	END	

END	
GO
