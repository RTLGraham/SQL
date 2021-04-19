CREATE TABLE [dbo].[UKMileageRate]
(
[MileageRateId] [int] NOT NULL IDENTITY(1, 1),
[CustomerId] [uniqueidentifier] NULL,
[DriverGroupId] [uniqueidentifier] NULL,
[StartDate] [datetime] NOT NULL,
[EndDate] [datetime] NULL,
[Fueltype] [tinyint] NOT NULL,
[EngineSizeLow] [int] NOT NULL,
[EngineSizeHigh] [int] NOT NULL,
[ClaimRate] [int] NOT NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_UKMileageRate_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_UKMileageRate_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ============================================================================================
-- Author:		Graham Pattison
-- Create date: 09/03/2011
-- Description:	Any EventsData rows with CreationCodeId matching TAN_TriggerType.CreationCodeId
--				will be inserted into TAN_TriggerEvent to be analysed by the TAN process.
-- ============================================================================================
CREATE TRIGGER [dbo].[trig_Insert_UKMileageRate] 
   ON  [dbo].[UKMileageRate]
   AFTER INSERT
AS 
BEGIN
		
--Automatically expire any existing rates that match the new rate by customer, drivergroup, engine size and fuel type		
UPDATE dbo.UKMileageRate
SET EndDate = DATEADD(ss, -1, i.StartDate)
FROM dbo.UKMileageRate ukm
INNER JOIN INSERTED i ON ISNULL(ukm.CustomerId, '69937BC2-55EB-4833-B720-36CB5FB5108E')  = ISNULL(i.CustomerId, '69937BC2-55EB-4833-B720-36CB5FB5108E')
						AND ISNULL(ukm.DriverGroupId, '69937BC2-55EB-4833-B720-36CB5FB5108E') = ISNULL(i.DriverGroupId, '69937BC2-55EB-4833-B720-36CB5FB5108E')
						AND ukm.EngineSizeLow = i.EngineSizeLow
						AND ukm.EngineSizeHigh = i.EngineSizeHigh
						AND ukm.Fueltype = i.Fueltype
						AND ukm.MileageRateId != i.MileagerateId -- Don't expire the newly added rate!
						AND ukm.EndDate IS NULL -- Don't change existing end dates
END












GO
ALTER TABLE [dbo].[UKMileageRate] ADD CONSTRAINT [PK_UKMileageRate] PRIMARY KEY CLUSTERED  ([MileageRateId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
