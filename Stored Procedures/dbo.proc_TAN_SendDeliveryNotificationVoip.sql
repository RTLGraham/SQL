SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[proc_TAN_SendDeliveryNotificationVoip] (@aDestinationPhoneNumber [nvarchar] (4000), @aAudioFile [nvarchar] (4000), @callId [bigint], @customerId [uniqueidentifier])
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [RTL.Two.TriggerAnalyseNotify].[RTL.Two.TriggerAnalyseNotify.StoredProcedures].[proc_TAN_SendDeliveryNotificationVoip]
GO
