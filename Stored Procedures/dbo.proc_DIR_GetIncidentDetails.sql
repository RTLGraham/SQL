SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[proc_DIR_GetIncidentDetails]
(
	@IncidentId INT
)
AS
BEGIN

--DECLARE @IncidentId INT
--SET @IncidentId = 8

SELECT i.IncidentFieldID,i.Name,i.FieldType,id.Contents
FROM dbo.DIR_IncidentField i
INNER JOIN dbo.DIR_IncidentDetail id ON id.IncidentFieldID = i.IncidentFieldID
WHERE id.IncidentID = @IncidentId

End
GO
