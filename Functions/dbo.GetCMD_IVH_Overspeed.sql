SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Dmitrijs Jurins>
-- Create date: <2018-03-25>
-- Description:	<Gets the ENGA IVH overspeed value>
-- =============================================
CREATE FUNCTION [dbo].[GetCMD_IVH_Overspeed]
(
	@vid UNIQUEIDENTIFIER,
	@date DATETIME,
	@default FLOAT = NULL
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @result FLOAT
	
	SELECT TOP 1 @result = CAST(ISNULL(h.KeyValue, 0) AS FLOAT)
	FROM dbo.Vehicle v
		INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
		INNER JOIN dbo.CFG_History h ON h.IVHIntId = i.IVHIntId
		INNER JOIN dbo.CFG_Key k ON k.KeyId = h.KeyId
		INNER JOIN dbo.CFG_KeyCommand kc ON kc.KeyId = k.KeyId
		INNER JOIN dbo.CFG_Command cmd ON cmd.CommandId = kc.CommandId
	WHERE v.VehicleId = @vid
		AND h.LastOperation <= @date
		AND cmd.CommandRoot = 'RTLS' AND kc.IndexPos = 0
		--AND cmd.CommandRoot = 'ENGA' AND kc.IndexPos = 68
	ORDER BY h.LastOperation DESC
    
	
	RETURN ISNULL(@result, @default)
END


GO
