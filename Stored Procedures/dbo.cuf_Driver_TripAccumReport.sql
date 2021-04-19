SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_Driver_TripAccumReport]
(
	@did UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@route INT,
	@vehicleType INT
)
AS
	--DECLARE @did UNIQUEIDENTIFIER,
	--		@uid UNIQUEIDENTIFIER,
	--		@rprtcfgid UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME,
	--		@route INT,
	--		@vehicleType INT

	EXECUTE dbo.[proc_Report_TripDriver] 
	   @did
	  ,@uid
	  ,@rprtcfgid
	  ,@sdate
	  ,@edate
	  ,@route
	  ,@vehicleType

GO
