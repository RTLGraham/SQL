SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_VehicleCommand_GetCommandForIVH]
(
	@ivhid UNIQUEIDENTIFIER
)
AS
BEGIN
	EXECUTE dbo.[proc_GetCommandForIVH] @ivhid = @ivhid -- uniqueidentifier	
END


GO
