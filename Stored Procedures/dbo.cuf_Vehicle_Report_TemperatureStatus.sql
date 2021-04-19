SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_TemperatureStatus]
(
	@vids VARCHAR(MAX),
	@uid UNIQUEIDENTIFIER,
	@isAlert BIT,
	@isChecked BIT,
	@date DATETIME = NULL
)
AS
BEGIN
	EXECUTE dbo.[proc_ReportTemperatureStatus] 
		   @vids
		  ,@uid
		  ,@isAlert
		  ,@isChecked
		  ,@date
END


GO
