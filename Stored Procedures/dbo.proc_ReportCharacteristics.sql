SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportCharacteristics]
    (
		@vid UNIQUEIDENTIFIER,
		@uid UNIQUEIDENTIFIER,
		@sdate DATETIME,
		@edate DATETIME
    )
AS 

--DECLARE @vid UNIQUEIDENTIFIER,
--		@uid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME

--SET @vid = N'AD65989F-13E3-44DF-9D76-2E2E18AFCC63'
--SET @uid = N'AC5FC459-FAF5-48D7-BBBE-88CC5EE824E1'
--SET @sdate = '2016-06-13 00:00'
--SET @edate = '2016-06-20 23:59'

DECLARE @lvid UNIQUEIDENTIFIER,
		@luid UNIQUEIDENTIFIER,
		@lsdate DATETIME,
		@ledate DATETIME

SET @lvid = @vid
SET @luid = @uid
SET @lsdate = @sdate
SET @ledate = @edate

SET @lsdate = dbo.TZ_ToUtc(@lsdate, DEFAULT, @luid)
SET @ledate = dbo.TZ_ToUtc(@ledate, DEFAULT, @luid)

DECLARE @diststr VARCHAR(20),
		@distmult FLOAT,
		@fuelstr VARCHAR(20),
		@fuelmult FLOAT,
		@co2str VARCHAR(20),
		@co2mult FLOAT,
		@liquidstr VARCHAR(20)

SELECT @liquidstr =[dbo].UserPref(@luid, 201)
SELECT @diststr = [dbo].UserPref(@luid, 203)
SELECT @distmult = [dbo].UserPref(@luid, 202)
SELECT @fuelstr = [dbo].UserPref(@luid, 205)
SELECT @fuelmult = [dbo].UserPref(@luid, 204)

DECLARE @results TABLE
(
	[VehicleId] [uniqueidentifier] NOT NULL,
	[Registration] [varchar](20) NULL,
	[GroupId] [bigint] NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[RPM0Time] [int] NULL,
	[RPM0Distance] [float] NULL,
	[RPM0Fuel] [float] NULL,
	[RPM100Time] [int] NULL,
	[RPM100Distance] [float] NULL,
	[RPM100Fuel] [float] NULL,
	[RowIndex] [int] NULL,
	[ColumnIndex] [int] NULL,
	[SweetSpotLow] [int] NULL,
	[SweetSpotMid1] [int] NULL,
	[SweetSpotMid2] [int] NULL,
	[SweetSpotHigh] [int] NULL,
	[OverRev] [int] NULL,
	[HighOverRev] [int] NULL,
	[TotalFuel] [float] NULL,
	[TotalDistance] [float] NULL,
	[TotalTime] [int] NULL,
	[FuelEcon] [float] NULL,
	[FuelString] [varchar](20) NULL,
	[DistanceString] [varchar](20) NULL,
	[LiquidString] [varchar](20) NULL,
	[CreationDateTime] [datetime] NULL,
	[ClosureDateTime] [datetime] NULL,
	ReportDistance FLOAT NULL,
	[TotalDistancePerc] FLOAT NULL
)


INSERT INTO @results
        ( VehicleId ,
          Registration ,
          GroupId ,
          StartDate ,
          EndDate ,
          RPM0Time ,
          RPM0Distance ,
          RPM0Fuel ,
          RPM100Time ,
          RPM100Distance ,
          RPM100Fuel ,
          RowIndex ,
          ColumnIndex ,
          SweetSpotLow ,
          SweetSpotMid1 ,
          SweetSpotMid2 ,
          SweetSpotHigh ,
          OverRev ,
          HighOverRev ,
          TotalFuel ,
          TotalDistance ,
          TotalTime ,
          FuelEcon ,
          FuelString ,
          DistanceString ,
          LiquidString ,
          CreationDateTime ,
          ClosureDateTime)
SELECT	v.VehicleId,
		v.Registration,
		tot.GroupId,
		dbo.TZ_GetTime(tot.MinDate, DEFAULT, @luid) AS StartDate,
		dbo.TZ_GetTime(tot.MaxDate, DEFAULT, @luid) AS EndDate,
		tot.RPM0Time,
		tot.RPM0Distance,
		tot.RPM0Fuel,
		tot.RPM100Time,
		tot.RPM100Distance,
		tot.RPM100Fuel,
		d.RowIndex, 
		d.ColIndex AS ColumnIndex,
		h.SweetSpotLow,
		h.SweetSpotLow + ((h.SweetSpotHigh - h.SweetSpotLow) / 3) AS SweetSpotMid1,
		h.SweetSpotHigh - ((h.SweetSpotHigh - h.SweetSpotLow) / 3) AS SweetSpotMid2,
		h.SweetSpotHigh,
		h.OverRev,
		h.OverRev + 100 AS HighOverRev,
		SUM(d.Fuel) AS TotalFuel,
		SUM(d.Distance) AS TotalDistance,
		SUM(d.TimeVal) AS TotalTime,
		CASE WHEN @fuelmult = 0.1 THEN
			(CASE WHEN SUM(d.Fuel)=0 THEN NULL ELSE SUM(d.Fuel) * 100 END / CASE WHEN SUM(d.Distance) = 0 THEN NULL ELSE SUM(d.Distance) END) 
		ELSE
			(SUM(d.Distance) * 1000 / (CASE WHEN SUM(d.Fuel)=0 THEN NULL ELSE SUM(d.Fuel) END) * @fuelmult) END AS FuelEcon,
		@fuelstr AS FuelString,
		@diststr AS DistanceString,
		@liquidstr AS LiquidString,
		dbo.TZ_GetTime(@lsdate, DEFAULT, @luid) AS 'CreationDateTime',
		dbo.TZ_GetTime(@ledate, DEFAULT, @luid) AS 'ClosureDateTime'
FROM dbo.Dgen g
INNER JOIN dbo.Vehicle v ON g.VehicleIntId = v.VehicleIntId
INNER JOIN dbo.DGenCharHeader h ON g.DgenId = h.DgenId
INNER JOIN dbo.DGenCharData d ON h.DgenId = d.DGenId
INNER JOIN (
				SELECT	VehicleIntId, 
						SweetSpotLow,
						SweetSpotHigh,
						OverRev,
						ROW_NUMBER() OVER(PARTITION BY VehicleIntId ORDER BY MIN(dg0.DGenDateTime) DESC) AS GroupId,
						MIN(dg0.DGenDateTime) AS MinDate,
						MAX(dg0.DGenDateTime) AS Maxdate,
						SUM(RPM0Time) AS RPM0Time,
						SUM(RPM0Distance) AS RPM0Distance,
						SUM(RPM0Fuel) AS RPM0Fuel,
						SUM(RPM100Time) AS RPM100Time,
						SUM(RPM100Distance) AS RPM100Distance,
						SUM(RPM100Fuel) AS RPM100Fuel
				FROM dbo.Dgen dg0
				INNER JOIN dbo.DGenCharHeader ext ON dg0.DgenId = ext.DgenId
				WHERE ext.OpenDateTime BETWEEN @lsdate AND @ledate
					AND ext.CloseDateTime BETWEEN @lsdate AND @ledate
				GROUP BY VehicleIntId, SweetSpotLow, SweetSpotHigh, OverRev
			) tot ON tot.VehicleIntId = g.VehicleIntId AND tot.SweetSpotLow = h.SweetSpotLow AND tot.SweetSpotHigh = h.SweetSpotHigh AND tot.OverRev = h.OverRev
WHERE v.VehicleId = @lvid
  AND g.DgenDateTime BETWEEN @lsdate AND @ledate
  AND h.OpenDateTime BETWEEN @lsdate AND @ledate
  AND h.CloseDateTime BETWEEN @lsdate AND @ledate
GROUP BY v.VehicleId, v.Registration, tot.GroupId, tot.Mindate, tot.Maxdate, tot.RPM0Time, tot.RPM0Distance, tot.RPM0Fuel, tot.RPM100Time, tot.RPM100Distance, tot.RPM100Fuel, d.RowIndex, d.ColIndex, h.SweetSpotLow, h.SweetSpotHigh, h.OverRev 


DECLARE @rd FLOAT
SELECT @rd = SUM(TotalDistance) FROM @results
UPDATE @results SET ReportDistance = @rd, TotalDistancePerc = TotalDistance / dbo.ZeroYieldNull(@rd)

SELECT VehicleId ,
       Registration ,
       GroupId ,
       StartDate ,
       EndDate ,
       RPM0Time ,
       RPM0Distance ,
       RPM0Fuel ,
       RPM100Time ,
       RPM100Distance ,
       RPM100Fuel ,
       RowIndex ,
       ColumnIndex ,
       SweetSpotLow ,
       SweetSpotMid1 ,
       SweetSpotMid2 ,
       SweetSpotHigh ,
       OverRev ,
       HighOverRev ,
       TotalFuel ,
       TotalDistance ,
       TotalTime ,
       FuelEcon ,
       FuelString ,
       DistanceString ,
       LiquidString ,
       CreationDateTime ,
       ClosureDateTime ,
       ReportDistance,
	   TotalDistancePerc
FROM @results
ORDER BY Registration, RowIndex, ColumnIndex






GO
