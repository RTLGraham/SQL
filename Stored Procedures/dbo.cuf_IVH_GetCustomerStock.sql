SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[cuf_IVH_GetCustomerStock]
	@cid UNIQUEIDENTIFIER
AS
BEGIN
	--DECLARE @cid UNIQUEIDENTIFIER
	--SET @cid = N'0086FC9D-8D78-47A1-BB27-B835269FC6BF'
				
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
				FROM
					[dbo].[IVH] i
						INNER JOIN dbo.CustomerIVHStock cis ON i.IVHId = cis.IVHId
				WHERE cis.Archived = 0 AND cis.EndDate IS NULL AND i.Archived = 0 AND cis.CustomerId = @cid
					AND i.IVHId NOT IN (SELECT DISTINCT ISNULL(IVHId, '00000000-0000-0000-0000-000000000000') 
										FROM dbo.Vehicle v
											INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
										WHERE v.Archived = 0 AND cv.Archived = 0 AND cv.EndDate IS NOT NULL AND cv.CustomerId = @cid)
END



GO
