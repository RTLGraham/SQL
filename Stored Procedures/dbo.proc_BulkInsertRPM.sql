SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_BulkInsertRPM]
AS

INSERT INTO RPM SELECT * FROM RPMTemp WHERE Archived = 0



GO