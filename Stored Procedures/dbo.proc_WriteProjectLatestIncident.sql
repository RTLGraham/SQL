SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[proc_WriteProjectLatestIncident]
	@CustomerId UNIQUEIDENTIFIER, 
	@ProjectId VARCHAR(20), 
	@IncidentId VARCHAR(20)
AS
	--DECLARE @CustomerId UNIQUEIDENTIFIER, 
	--		@ProjectId VARCHAR(20), 
	--		@IncidentId VARCHAR(20)

	--SELECT  @CustomerId = N'ce941443-ebdd-4550-bbde-8ae5849d1eaa', 
	--		@ProjectId = '006', 
	--		@IncidentId = '329721'
	
	UPDATE dbo.Project
	SET LastIncidentId = @IncidentId
	WHERE Project = @ProjectId AND CustomerId = @CustomerId

GO
