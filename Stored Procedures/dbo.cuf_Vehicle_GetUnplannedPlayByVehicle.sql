SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_GetUnplannedPlayByVehicle]
(
	@vid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@uid UNIQUEIDENTIFIER
)
AS
	EXECUTE [dbo].[proc_GetUnplannedPlayByVehicle] 
	   @vid
	  ,@sdate
	  ,@edate
	  ,@uid


GO
