SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_TripAccumReport]
(
	@vid UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@route INT,
	@vehicleType INT
)
AS
	--DECLARE @vid UNIQUEIDENTIFIER,
	--	@uid UNIQUEIDENTIFIER,
	--	@rprtcfgid UNIQUEIDENTIFIER,
	--	@sdate DATETIME,
	--	@edate DATETIME,
	--	@route INT,
	--	@vehicleType INT

	EXECUTE dbo.[proc_Report_TripVehicle] 
	   @vid
	  ,@uid
	  ,@rprtcfgid
	  ,@sdate
	  ,@edate
	  ,@route
	  ,@vehicleType

GO
