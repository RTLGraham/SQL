SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_CFG_Template_GetList]

AS
BEGIN

SELECT t.TemplateId, t.Name AS TemplateName, t.Description AS TemplateDescription, 
	   k.KeyId, k.Name AS KeyName, k.Description AS KeyDescription, kc.IndexPos AS KeyIndex,
	   tk.KeyValue AS TemplateKeyValue, 
	   cat.CategoryId, cat.Name AS CategoryName, cat.Description AS CategoryDescription,
	   it.ReadCommandPrefix + com.CommandRoot + it.ReadCommandSuffix AS ReadCommandString,
	   it.WriteCommandPrefix + com.CommandRoot + it.WriteCommandSuffix AS WriteCommandString,
	   com.Description AS CommandDescription, it.IVHTypeId, it.Name AS IVHTypeName, it.Description AS IVHTypeDescription,
	   k.MinValue, k.MaxValue, k.MinDate, k.MaxDate 
FROM dbo.CFG_Template t
INNER JOIN dbo.CFG_TemplateKey tk ON t.TemplateId = tk.TemplateId
INNER JOIN dbo.CFG_Key k ON tk.KeyId = k.KeyId
INNER JOIN dbo.CFG_KeyCommand kc ON k.KeyId = kc.KeyId
INNER JOIN dbo.CFG_Command com ON kc.CommandId = com.CommandId
INNER JOIN dbo.CFG_Category cat ON com.CategoryId = cat.CategoryId
INNER JOIN dbo.IVHType it ON com.IVHTypeId = it.IVHTypeId
WHERE it.Archived = 0
  AND com.Archived = 0
  AND cat.Archived = 0
  AND k.Archived = 0
  AND t.Archived = 0

ORDER BY t.Name, tk.KeyId

END


GO
