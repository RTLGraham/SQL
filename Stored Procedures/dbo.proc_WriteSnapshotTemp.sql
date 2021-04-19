SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_WriteSnapshotTemp]
	@ssid bigint OUTPUT, @erpm int, @rs float, @el float, @t float, @fr float,
	@status varchar(10), @tsba int, @tf float, @td float,
	@sbstatus char(1), @ebstatus char(1), @clstatus char(1), @pstatus char(1), @crstatus char(1), @rstatus char(1),
	@vm varchar(50), @gstatus varchar(50), @cigstatus varchar(50), @ssstatus varchar(50),
	@osstatus varchar(50), @orpmstatus varchar(50), @dlstatus varchar(50), @ksstatus varchar(50),
	@gr float, @tgr float, @gdr float, @tspo int, @srs varchar(10), @et smallint,
	@teh float, @tvd float, @tgpsd float, @tvf float, @is varchar(10), @eid bigint,
	@reserved int = NULL, @cintid int = 0, @eventdt datetime = null, @ccid smallint = 0, @vid UNIQUEIDENTIFIER = null
AS

DECLARE @vintid INT
SET @vintid = dbo.GetVehicleIntFromId(@vid)
-- declare variables to store, and look up values from, ID tables for status/status activation codes
DECLARE @servicebrakestatus tinyint
DECLARE @enginebrakestatus tinyint
DECLARE @clutchstatus tinyint
DECLARE @ptostatus tinyint
DECLARE @cruisestatus tinyint
DECLARE @rsgstatus tinyint
DECLARE @keyswitchstatus tinyint

SELECT @servicebrakestatus = StatusActivationId FROM StatusActivation WHERE Code = @sbstatus
SELECT @enginebrakestatus = StatusActivationId FROM StatusActivation WHERE Code = @ebstatus
SELECT @clutchstatus = StatusActivationId FROM StatusActivation WHERE Code = @clstatus
SELECT @ptostatus = StatusActivationId FROM StatusActivation WHERE Code = @pstatus
SELECT @cruisestatus = StatusActivationId FROM StatusActivation WHERE Code = @crstatus
SELECT @rsgstatus = StatusActivationId FROM StatusActivation WHERE Code = @rstatus
SELECT @keyswitchstatus = StatusActivationId FROM StatusActivation WHERE Code = @ksstatus

DECLARE @vehiclemode smallint
DECLARE @gearstatus smallint
DECLARE @coastingingearstatus smallint
DECLARE @sweetspotstatus smallint
DECLARE @overspeedstatus smallint
DECLARE @overrpmstatus smallint
DECLARE @datalinkstatus smallint

SELECT @vehiclemode = StatusId FROM Status WHERE StatusString = @vm
SELECT @gearstatus = StatusId FROM Status WHERE StatusString = @gstatus
SELECT @coastingingearstatus = StatusId FROM Status WHERE StatusString = @cigstatus
SELECT @sweetspotstatus = StatusId FROM Status WHERE StatusString = @ssstatus
SELECT @overspeedstatus = StatusId FROM Status WHERE StatusString = @osstatus
SELECT @overrpmstatus = StatusId FROM Status WHERE StatusString = @orpmstatus
SELECT @datalinkstatus = StatusId FROM Status WHERE StatusString = @dlstatus

INSERT INTO SnapshotTemp	(EngineRPM, RoadSpeed, EngineLoad, Throttle, FuelRate,
			Status, TotalServiceBrakeActuations, TotalFuel, TotalDistance,
			ServiceBrakeStatus, EngineBrakeStatus, ClutchStatus, PTOStatus, CruiseStatus, RSGStatus,
			VehicleMode, GearStatus, CoastingInGearStatus, SweetSpotStatus,
			OverSpeedStatus, OverRPMStatus, DataLinkStatus, KeySwitchStatus,
			GearRatio, TopGearRatio, GearDownRatio, TimeSincePowerOn, SnapshotRecordStatus, EngineTemp,
			TotalEngineHours, TotalVehicleDistance, TotalGPSDistance, TotalVehicleFuel, InputsStatus, EventId,
			Reserved, CustomerIntId, EventDateTime, CreationCodeId, VehicleIntId)
	VALUES		(@erpm, @rs, @el, @t, @fr,
			@status, @tsba, @tf, @td,
			@servicebrakestatus, @enginebrakestatus, @clutchstatus, @ptostatus, @cruisestatus, @rsgstatus,
			@vehiclemode, @gearstatus, @coastingingearstatus, @sweetspotstatus,
			@overspeedstatus, @overrpmstatus, @datalinkstatus, @keyswitchstatus,
			@gr, @tgr, @gdr, @tspo, @srs, @et,
			@teh, @tvd, @tgpsd, @tvf, @is, @eid, 
			@reserved, @cintid, @eventdt, @ccid, @vintid)

--SELECT @ssid AS SnapshotId
SET @ssid = SCOPE_IDENTITY()
SELECT @ssid AS SnapshotId

GO
