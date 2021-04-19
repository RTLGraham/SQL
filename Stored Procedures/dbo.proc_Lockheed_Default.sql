SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Lockheed_Default]
AS
BEGIN
	EXEC Test_Database.dbo.proc_LocheedStatic_Default
	EXEC Test_Database.dbo.proc_LocheedLive_Default
END

GO
