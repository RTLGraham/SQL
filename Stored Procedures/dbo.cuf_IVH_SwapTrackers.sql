SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_IVH_SwapTrackers]
(
	@vid UNIQUEIDENTIFIER,
	@newivhid UNIQUEIDENTIFIER
)
AS
	DECLARE @curdate DATETIME
	SET @curdate = GETDATE()
	
	EXECUTE dbo.proc_AdminSwitchTracker @vid, @newivhid, NULL, @curdate
	

GO
