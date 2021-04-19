SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_VehicleModeCreationCode_GetModeByCreationCode]
(
	@ccid SMALLINT
)
AS
BEGIN
	SELECT VehicleModeId
	FROM dbo.VehicleModeCreationCode
	WHERE CreationCodeId = @ccid
END


GO
