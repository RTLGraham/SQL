SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_GetVehicleOdometerOffset]
	@vid UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER
AS

	--DECLARE @vid UNIQUEIDENTIFIER, 
	--		@uid UNIQUEIDENTIFIER
	--SET @vid = N'BDB82EB2-693B-4911-901D-23A92C2AE40D'
	--SET @uid = N'EBB1BF66-C20B-46B3-906C-18FA4910F8CC'

	DECLARE @distmult FLOAT
	SELECT @distmult = CAST(ISNULL(Value, 1) AS FLOAT)
	FROM dbo.UserPreference
	WHERE NameID = 202
	  AND UserID = @uid

	SELECT ISNULL(CAST(ROUND(voo.OdometerOffset * @distmult * 1000, 0) AS INT), 0) AS OdoOffset
	FROM dbo.Vehicle v
	LEFT JOIN dbo.VehicleOdoOffset voo ON voo.VehicleIntId = v.VehicleIntId
	WHERE v.VehicleId = @vid





GO
