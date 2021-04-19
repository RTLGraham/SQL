SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_CAM_IncidentTag_Add]
(
	@incidentId BIGINT,
	@tagId INT
)
AS
	SET NOCOUNT ON;

	INSERT INTO dbo.CAM_IncidentTag
	        ( IncidentId ,
	          TagId ,
	          LastModified ,
	          Archived
	        )
	VALUES  ( @incidentId , -- IncidentId - bigint
	          @tagId , -- TagId - int
	          GETDATE() , -- LastModified - datetime
	          0  -- Archived - bit
	        )


GO
