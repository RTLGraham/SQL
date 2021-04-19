SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[proc_TAN_SendHTMLEmail] (@aRecipient [nvarchar] (4000), @aSubject [nvarchar] (4000), @aBodyText [nvarchar] (max))
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [RTL.Two.TriggerAnalyseNotify].[RTL.Two.TriggerAnalyseNotify.StoredProcedures].[proc_TAN_SendHTMLEmail]
GO
