SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_DriverMobilePlatformUsage_RS]
          @uid UNIQUEIDENTIFIER,
          @year INT
AS
	SET NOCOUNT ON;

	EXECUTE dbo.[cuf_Driver_MobilePlatformUsage] 
	   @uid
	  ,@year


GO
