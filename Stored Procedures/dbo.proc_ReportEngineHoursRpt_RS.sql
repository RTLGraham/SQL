SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportEngineHoursRpt_RS]
    (
      @gids NVARCHAR(MAX),
      @vids NVARCHAR(MAX),
      @sdate DATETIME,
      @edate DATETIME,
      @uid UNIQUEIDENTIFIER
    )
AS 
--DECLARE @gids NVARCHAR(MAX), 
--		@vids NVARCHAR(MAX), 
--		@sdate DATETIME, 
--		@edate DATETIME, 
--		@uid UNIQUEIDENTIFIER
--		
--SET	@gids = N'38C7C8A9-F0C0-4CD6-8112-1D0A5449E106,190EB754-A67B-4ED2-AA95-33D1623FBF35,026BCE9E-2F77-4A36-A211-4F4A0989F972'
--SET @vids = N'6DAA52DD-02A8-4D7C-B9DC-7A98F668BC0D,E8AE6DDC-C9E3-43A6-933C-A5E64D3AC57A,AC65CCCB-D34E-473A-8A93-C6CA7D177A26,067CCC57-9829-4575-9DFF-02A523460835,368735B2-D6F5-4DC7-B151-0F44173B2722'
--SET @sdate = '2012-06-01 00:00'
--SET @edate = '2012-06-01 23:59'
--SET @uid = N'A55F77A0-BE2F-4B6F-B6E5-E84B924947F2'

    DECLARE @results TABLE
        (
          VehicleId UNIQUEIDENTIFIER,
          Registration NVARCHAR(MAX),
          GroupId UNIQUEIDENTIFIER,
          GroupName NVARCHAR(MAX),
          TotalTime INT,
          sdate DATETIME,
          edate DATETIME
        )

    INSERT  INTO @results
            EXEC [dbo].[proc_ReportEngineHoursV2] 
            @gids, @vids, @sdate, @edate, @uid
  
    SELECT  r.GroupId,
            r.GroupName,
            r.Registration AS VehicleRegistration,
            r.TotalTime AS VehicleTotalTime,
            g.TotalTime AS GroupTotalTime,
            t.TotalTime AS TotalTotslTime,
            @sdate AS sdate,
            @edate AS edate
    FROM    @results r
            INNER JOIN @results g ON g.VehicleId IS NULL
                                     AND g.GroupId IS NOT NULL
                                     AND r.GroupId = g.GroupId
            INNER JOIN @results t ON t.VehicleId IS NULL
                                     AND t.GroupId IS NULL
    WHERE   r.VehicleId IS NOT NULL
            AND r.GroupId IS NOT NULL
GO
