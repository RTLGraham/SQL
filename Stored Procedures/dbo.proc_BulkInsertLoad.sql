SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--It is then copied into the main load table

CREATE PROC [dbo].[proc_BulkInsertLoad]
AS

INSERT INTO [Load] SELECT *	FROM LoadTemp WHERE Archived = 0


GO
