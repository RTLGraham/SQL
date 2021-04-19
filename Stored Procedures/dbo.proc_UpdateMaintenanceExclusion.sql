SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_UpdateMaintenanceExclusion]
(
	@maintenanceExclusionId INT,
	@excludeUntil DATETIME = NULL,
	@delete BIT = NULL	
)
AS
BEGIN

	--DECLARE	@maintenanceExclusionId INT,
	--		@excludeUntil DATETIME,
	--		@delete BIT

	--SET @maintenanceExclusionId = 22
	--SET @excludeUntil = NULL--'2017-01-01'
	--SET @delete = 1

	UPDATE dbo.MaintenanceExclusion
	SET Archived = CASE WHEN @delete = 1 THEN 1 ELSE Archived END,
--		ExcludeUntil = CASE WHEN @excludeUntil IS NOT NULL THEN @excludeUntil ELSE ExcludeUntil END
		ExcludeUntil = CASE WHEN @excludeUntil IS NOT NULL THEN @excludeUntil 
							ELSE CASE WHEN @delete = 1 THEN ExcludeUntil ELSE NULL END 
					   END
    WHERE MaintenanceExclusionId = @maintenanceExclusionId

END


GO
