SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ======================================================================================
-- Author:		<Jamie Bartleet>
-- Create date: <2017-10-25>
-- Description:	<Update Leopard port details to temporary table then truncate temp table>
-- ======================================================================================
CREATE PROCEDURE [dbo].[proc_LEO_WriteTempPort]
	@IvhId UNIQUEIDENTIFIER,
	@PortName VARCHAR(255),
	@PortDesc VARCHAR(50)

AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @IvhId UNIQUEIDENTIFIER,
	--        @PortName VARCHAR(255),
	--        @PortDesc VARCHAR(255)

	--SET @IvhId    = '7B7A6F42-F7E0-4F3B-ADFA-06C2B1FDEEE4'
	--SET @PortName = 'COM4'
	--SET @PortDesc = 'Internal serial port'


	if (Select Count(*)
		FROM dbo.LEO_Temp_Port p
		INNER JOIN dbo.LEO_Leopard l ON l.LeopardId = p.LeopardId
		WHERE l.IVHId = @IvhId
		  AND p.Name = @PortName) = 0


		INSERT INTO dbo.LEO_Temp_Port 
				( LeopardId ,
				  Name ,
				  [Description] , 
				  LastOperation ,
				  Archived
				) 
		SELECT l.LeopardId, @PortName, @PortDesc, GetDate(), 0
		FROM dbo.LEO_Leopard l 
		WHERE l.IVHId = @IvhId
		;

	ELSE

		UPDATE dbo.LEO_Temp_Port 
		SET [Description] = @PortDesc,
			LastOperation = GetDate(),
			Archived = 0
		FROM dbo.LEO_Leopard l 
		WHERE l.IVHId = @IvhId
		and Name = @PortName
		;

END

GO
