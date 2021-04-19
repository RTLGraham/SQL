SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Driver_ReportCombinedSafetyEfficiency]
(
	@did UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@uid UNIQUEIDENTIFIER
)
AS

SELECT 'This procedure is not used' AS Result

SELECT * FROM dbo.Driver WHERE DriverId = @did

GO
