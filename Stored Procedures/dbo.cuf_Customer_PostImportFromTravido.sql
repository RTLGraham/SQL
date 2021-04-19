SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Customer_PostImportFromTravido]
(
	@pid NVARCHAR(20),
	@iid NVARCHAR(20)
)
AS	
	
	UPDATE dbo.Project SET LastIncidentId = @iid WHERE Project = @pid
	UPDATE Gopher.dbo.CAM_Project SET LastNewDataId = @iid, Archived = 0 WHERE ProjectId = @pid


GO
