SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================
-- Author:		<Jamie Bartleet>
-- Create date: <2017-10-20>
-- Description:	<Update Leopard system information>
-- ================================================
CREATE PROCEDURE [dbo].[proc_LEO_WriteLeopard]
	@TrackerNum VARCHAR(50),
	@SysInfoTimestamp DATETIME,
	@DeviceType VARCHAR(255),
	@IvhId UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @TrackerNum VARCHAR(50), 
	--        @SysInfoTimestamp DATETIME,
	--        @DeviceType VARCHAR(255),
	--		@IvhId UNIQUEIDENTIFIER
	        
	--SET @TrackerNum       = '358427051160920'
	----SET @TrackerNum       = '352024028518375'
	----SET @TrackerNum       = '358427051014440'
	----SET @TrackerNum       = '358427051072067'
	--SET @SysInfoTimestamp = '2017-10-14 03:00'
	--SET @DeviceType       = 'CAMOS'
	
	
	SELECT @ivhId = i.IvhId
	FROM dbo.IVH i
	WHERE i.TrackerNumber = @TrackerNum AND i.Archived = 0

	if (@IvhId IS NOT NULL)
	BEGIN

		IF (
			SELECT COUNT(*)
			FROM dbo.LEO_Leopard l
			INNER JOIN dbo.LEO_DeviceType dt on dt.Name = @DeviceType
			WHERE l.IVHId = @IvhId AND l.Archived = 0
			  AND dt.Archived = 0
		) = 0

			--write a new Leopard Device
			INSERT INTO dbo.LEO_Leopard
					( IVHId ,
					  DeviceTypeId ,
					  SystemInfoDate ,
					  LastOperation ,
					  Archived
					)
			SELECT @IvhId, dt.DeviceTypeId, @SysInfoTimestamp, GETDATE(), 0
			FROM dbo.LEO_DeviceType dt
			WHERE dt.Name = @DeviceType AND dt.Archived = 0;
	
		ELSE

			--update an existing Leopard Device
			UPDATE dbo.LEO_Leopard
			SET IVHId = @IvhId,
				DeviceTypeId = dt.DeviceTypeId,
				SystemInfoDate = @SysInfoTimestamp,
				LastOperation = GETDATE(),
				Archived = 0
			
			FROM dbo.LEO_Leopard l
			CROSS JOIN dbo.LEO_DeviceType dt
			WHERE l.IVHId = @IvhId 
			  AND dt.Name = @DeviceType
			  AND dt.Archived = 0;
	
	END

END

GO
