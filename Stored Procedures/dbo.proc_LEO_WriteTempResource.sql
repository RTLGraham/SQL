SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ==========================================================================================
-- Author:		<Jamie Bartleet>
-- Create date: <2017-10-25>
-- Description:	<Update Leopard resource details to temporary table then truncate temp table>
-- ==========================================================================================
CREATE PROCEDURE [dbo].[proc_LEO_WriteTempResource]
	@IvhId UNIQUEIDENTIFIER,
	@ResourceName VARCHAR(255),
	@TotalSpace BIGINT,
	@AvailableSpace BIGINT

AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @IvhId UNIQUEIDENTIFIER,
	--        @ResourceName VARCHAR(255),
	--        @TotalSpace BIGINT,
	--        @AvailableSpace BIGINT

	--SET @IvhId          = '7B7A6F42-F7E0-4F3B-ADFA-06C2B1FDEEE4'
	--SET @ResourceName   = 'SDMMC Card'
	--SET @TotalSpace     = 1449959
	--SET @AvailableSpace = 1388542

	if (Select Count(*)
		FROM dbo.LEO_Temp_Resource r
		INNER JOIN dbo.LEO_Leopard l ON l.LeopardId = r.LeopardId
		WHERE l.IVHId = @IvhId
		  AND r.Name = @ResourceName) = 0


		INSERT INTO dbo.LEO_Temp_Resource
				( LeopardId ,
				  Name ,
				  Total , 
				  Available ,
				  LastOperation ,
				  Archived
				) 
		SELECT l.LeopardId, @ResourceName, @TotalSpace, @AvailableSpace, GetDate(), 0
		FROM dbo.LEO_Leopard l 
		WHERE l.IVHId = @IvhId
		;

	ELSE

		UPDATE dbo.LEO_Temp_Resource
		SET Total = @TotalSpace,
			Available = @AvailableSpace,
			LastOperation = GetDate(),
			Archived = 0
		FROM dbo.LEO_Leopard l 
		WHERE l.IVHId = @IvhId
		and Name = @ResourceName
		;

END

GO
