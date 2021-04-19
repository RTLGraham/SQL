SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROC [dbo].[proc_BulkInsertEvent]
AS

INSERT INTO Event SELECT * FROM EventTemp WHERE Archived = 0
INSERT INTO Event SELECT * FROM EventListenerTemp WHERE Archived = 0
INSERT INTO Event SELECT * FROM EventCamTemp WHERE Archived = 0

INSERT INTO EventCopy SELECT * FROM EventTemp WHERE Archived = 0
INSERT INTO EventCopy SELECT * FROM EventListenerTemp WHERE Archived = 0
INSERT INTO EventCopy SELECT * FROM EventCamTemp WHERE Archived = 0

INSERT INTO EventCopyVehicleMode SELECT * FROM dbo.EventTemp WHERE Archived = 0
INSERT INTO EventCopyVehicleMode SELECT * FROM EventListenerTemp WHERE Archived = 0
INSERT INTO EventCopyVehicleMode SELECT * FROM EventCamTemp WHERE Archived = 0

INSERT INTO EventCopyTrip SELECT * FROM EventTemp WHERE Archived = 0 AND CreationCodeId IN (5,61,78)
INSERT INTO EventCopyTrip SELECT * FROM EventListenerTemp WHERE Archived = 0 AND CreationCodeId IN (5,61,78)
INSERT INTO EventCopyTrip SELECT * FROM EventCamTemp WHERE Archived = 0 AND CreationCodeId IN (5,61,78)

INSERT INTO EventCopyABC SELECT * FROM EventTemp WHERE Archived = 0 AND CreationCodeId IN (36,37,38,336,337,338,436,437,438,457,458)
INSERT INTO EventCopyABC SELECT * FROM EventListenerTemp WHERE Archived = 0 AND CreationCodeId IN (36,37,38,336,337,338,436,437,438,457,458)
INSERT INTO EventCopyABC SELECT * FROM EventCamTemp WHERE Archived = 0 AND CreationCodeId IN (36,37,38,336,337,338,436,437,438,457,458)

GO
