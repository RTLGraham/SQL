SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_VideoList_RequestedTop]
(
	@uid UNIQUEIDENTIFIER,
	@vid UNIQUEIDENTIFIER,
	@top INT
)
AS

	EXEC dbo.proc_VideoList_Vehicle_RequestedTop @uid, @vid, @top

GO
