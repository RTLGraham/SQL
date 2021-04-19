SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--It is then copied into the main load table

CREATE PROC [dbo].[proc_BulkInsertDGen]
AS

INSERT INTO [DGen] SELECT *	FROM DGenTemp WHERE Archived = 0



GO
