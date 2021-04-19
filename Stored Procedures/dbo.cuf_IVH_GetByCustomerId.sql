SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[cuf_IVH_GetByCustomerId]
	@cid UNIQUEIDENTIFIER
AS
BEGIN
	--DECLARE @cid UNIQUEIDENTIFIER
	--SET @cid = N'36993114-90C0-4697-87E6-97C827D8765A'
				
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
                WHERE i.Archived = 0 AND (i.IVHId NOT IN 
													(
														SELECT DISTINCT IVHId FROM dbo.Vehicle WHERE Archived = 0
													)
										OR
										i.IVHId IN (
														SELECT DISTINCT v.IVHId
														FROM dbo.Vehicle v
															INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
														WHERE v.Archived = 0 AND cv.CustomerId = @cid
													))
END


GO
