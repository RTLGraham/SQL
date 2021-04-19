SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_BulkInsertAccum]
AS

--ALTER TABLE Accum NOCHECK CONSTRAINT ALL
INSERT INTO Accum SELECT * FROM AccumTemp WHERE Archived = 0
--ALTER TABLE Accum CHECK CONSTRAINT ALL

INSERT INTO AccumCopy SELECT * FROM AccumTemp WHERE Archived = 0

GO