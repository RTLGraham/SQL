SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_BulkInsertPassComf]
AS

INSERT INTO PassComf SELECT * FROM PassComfTemp	WHERE Archived = 0



GO
