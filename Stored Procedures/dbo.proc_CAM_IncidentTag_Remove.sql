SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_CAM_IncidentTag_Remove]
(
	@incidentId BIGINT,
	@tagId INT
)
AS

	
	--DECLARE

	--@incidentId BIGINT,
	--@tagId INT

	--set @incidentId = 18198
	--set @tagId = 5
	SET NOCOUNT ON;

	UPDATE dbo.CAM_IncidentTag
	SET Archived = 1,
		LastModified = GETDATE()
	WHERE IncidentId = @incidentId
		AND TagId = @tagId


GO
