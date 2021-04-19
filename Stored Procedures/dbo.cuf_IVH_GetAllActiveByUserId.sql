SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Dmitrijs Jurins>
-- Create date: <2014-06-13>
-- Description:	<This SP should be used to get all active trackers and match them with vehicles.>
-- Application: <Admin tools, vehicle lists>
-- =============================================
CREATE PROCEDURE [dbo].[cuf_IVH_GetAllActiveByUserId]
	@uid UNIQUEIDENTIFIER
AS
BEGIN
	--DECLARE @uid UNIQUEIDENTIFIER
	--SET @uid = N'07D3E863-2ECC-4CF3-AE3E-39CFB5E6C0EC'
				
	SELECT
		i.IVHId ,
        i.IVHIntId ,
        i.TrackerNumber ,
        i.Manufacturer ,
        i.Model ,
        i.PacketType ,
        i.PhoneNumber ,
        i.SIMCardNumber ,
        i.ServiceProvider ,
        i.SerialNumber ,
        i.FirmwareVersion ,
        i.AntennaType ,
        i.LastOperation ,
        i.Archived ,
        i.IsTag ,
        i.IVHTypeId ,
        i.IsDev
	FROM [dbo].[IVH] i
		INNER JOIN dbo.Vehicle v ON i.IVHId = v.IVHId
		INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
		INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
		INNER JOIN dbo.UserGroup ug ON g.GroupId = ug.GroupId	
    WHERE i.Archived = 0
		AND v.Archived = 0
		AND g.Archived = 0 AND g.IsParameter = 0 AND g.GroupTypeId = 1
		AND ug.UserId = @uid AND ug.Archived = 0
END



GO
