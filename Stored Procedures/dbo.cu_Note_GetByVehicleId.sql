SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_Note_GetByVehicleId]
(
	@vehid uniqueidentifier
)
AS
SELECT
	NoteId,
	NoteEntityId,
	NoteTypeId,
	Note,
	NoteDate,
	LastModified,
	Archived,
	1
FROM
	[dbo].[Note]
WHERE
	NoteEntityId = @vehid
	AND Archived != 1

GO
