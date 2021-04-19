SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[proc_BulkInsertEventVideoAccelMetadata]
AS

INSERT INTO EventVideoAccelMetadata SELECT * FROM EventVideoAccelMetadataTemp WHERE Archived = 0


GO
