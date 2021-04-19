SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_EconospeedFuel]
(
	@uid UNIQUEIDENTIFIER,
	@vids NVARCHAR(MAX),
	@sdate DATETIME,
	@edate DATETIME
)
AS
	--DECLARE @uid UNIQUEIDENTIFIER,
	--		@vids NVARCHAR(MAX),
	--		@sdate DATETIME,
	--		@edate DATETIME

	--SELECT	@vids = N'48423272-E26F-495F-BB86-E1C23F1B6694',
	--		--@vids = '',
	--		--@vids = 'B083E8C5-4440-42CB-A229-1DADD00E9E4D,55F8EC6D-596A-48C0-AEEF-1EF9D0F16C9C,DDBD7578-5B18-4829-9ED5-1F52F267ED36,E2B7625A-8A7F-4DBC-911B-709116D681B9,81F1D0AF-46EB-4961-85F7-750A00EFB1D2,1F6920AC-D3BD-4898-9ACA-77120A35BC8F,49E22B8A-5B34-49AC-A145-B62971250908,550D4235-E27F-4ED3-B136-B9FEB4094CE0,DC3F5B04-C0D5-4A6A-992A-C1E6576617EE,524A8F33-DE82-4643-85E9-E3C31C60D2C5,253FBDAD-970A-43D8-953C-FAE8945259E6,057C075E-DE68-40CF-A417-F64389B2C9D1,D1127F64-FC91-4150-91AE-0001C22CF3E9,330E12A6-81D9-4EA7-A747-00CDF8846964,9011444F-C41A-4E6D-92B3-015D4D63131F,94220533-D9A3-4CD8-B3A7-0288FBC87335,EE59037B-0E18-4D47-9A9F-02BF4AA92770,A8A242D3-0C23-4413-8876-03E02A525ACF,0ECA1624-AF08-481D-9A70-053F3A0267B6,F2D09472-B1E6-4A42-8FD6-0628B8B47797,0DD75684-FE83-4449-B19A-06409E294CCE,0FB5C2D9-C179-451D-951B-06B7E1BBE8F0,C5C3DBEA-B6F5-4A09-B492-0AC3208C59DF,483B38C7-1DE5-4487-B2D2-0C013E9E74E4,44AA029C-B0A6-45A6-B0AC-0C925DBB045C,925D0CB0-B10F-4E11-AD72-0CA6E3D22DF4,6CADB656-926D-4C74-83A6-0E31851DD0CA,61DB40BD-620F-4E30-B394-102DF2DBD20D,BE8153DC-77F3-471C-9D41-10E28BF02EED,C427E3C3-50AB-4E5A-B4DD-14E1D0B51E0C,FFE835CD-1960-48F9-8391-168795E1A6A8,5FE0F68D-F052-4457-9F1B-16A53AB20DFA,4C16B7B4-B892-432F-8FAA-17B1BB1D2449,C2E5A2F3-18C3-4F66-AFCA-181C9A543DD9,51FF86E7-8DD8-4670-B583-1A458EB74D71,6D77973A-712C-464A-8A4F-1AB618DB2E05,F78B28D2-879B-46AB-B49B-1AEF5E8A335E,65F15296-908C-404F-A2E2-1B2EC6A58620,DB2ABEAC-7A2C-40E4-926A-1BEA9ED2B4AA,949ED8D1-4800-4EEE-8303-20A39A9E4EAC,A05710BC-22B7-4BAF-B4B7-2384376EAD45,401C7902-D0E8-4EF6-972A-2415B12B9C88,2C884FD5-A5C2-431C-B194-262F9ADE6C05,71AE7453-276E-4322-A554-273D0BFE063E,A4E2D8A1-B044-46AB-8B2B-28660D48E6AC,48A12792-D393-4EC4-AC62-28BA0CBC4215,7A509ABF-A6F9-48A3-963A-29ED0A16288D,9D1076E1-1839-4FE9-A4E0-2AC05EF1B9E6,B8710A47-92E9-4F50-B049-2B8AADECA22B,FF55DDD6-9F96-4AD7-8565-2DB4BF733DF5,7358080F-A0A0-454B-94AC-2F1468350A54,E10BE29E-F466-465C-95BB-30E61440E264,4D5DCE14-0E72-4B45-A99E-33B480449619,772B2942-F8E0-4CE4-B94E-3490D47CB4E8,21E7DEC1-7BD8-49B0-A4B3-3619DD10A620,EA747B6A-9820-4B77-8578-3626A25912AB,D0AE2FBA-3EDB-4791-A4F8-3B2725E5A444,7FBC9675-7F2A-4ECE-A2B2-3BB0A8CC024A,0872A4FF-B296-4916-ADB0-3CA41298F393,24C2FB97-91F7-45C4-8A0B-411EA9FB8764,3B32CB0F-1B8A-46CF-B93D-41D05A846DBB,B91B0212-C94B-4B4F-BB94-41EDFA4D8058,392C4ED9-7B71-43E8-93C0-46A0F5F949A2,A49C8D79-E1BF-488D-A40A-4770E627C0DD,5D971B5C-C090-433D-9FCC-47CBBBA15981,C4B4B915-23B9-4003-A6B4-48505428F64D,1A544094-E656-4A64-9B5B-4994C4D1F9B2,54EB2F39-B846-418C-BFA4-4EC5037484B2,8CAF8F09-9ECE-48A8-BE77-4FE2C8348CDB,9FA98002-E2C0-43EA-829B-5085CFAC40BE,11EFA73F-3DC0-46A6-949A-514DEF92A803,BC886CDD-3CC1-43E5-94E4-523B0CA360B1,CFE90E51-8BCC-47AA-A11B-534D879459C5,49FF455B-1B94-4275-AD22-55B7487C9BB0,B0EAF2E7-28E2-471E-9CEE-58EF5BC76322,42361DA8-F50A-43EE-A13E-5A63BD4BBF9B,2D7015D2-9328-4299-AB27-5A7D3981F7A1,2B9CD169-6FC6-4EA4-BC96-5B5651E29F75,004051BB-27EE-4194-9D83-5BB052B0BD1A,37DB6567-A9F6-4286-A21E-5D19FD152274,AAE7388D-1974-48F1-B944-5EF7586EC25A,72EE3202-5106-4076-9170-615EB6052EC7,D2037E6F-BB22-4B3F-AB60-620F7AA730E9,6C8B43BF-EF0A-40E9-AC08-6399DBA9C836,1519CADB-4011-465D-B8B1-6A26AD6CE395,CF534DF2-C522-40FF-873E-6CF381FBE20D,9AEA3175-DC0A-47A9-9C5E-6D559450E1C0,821FAB59-9E59-4E8D-93D5-6F5FB71B4221,9D2CDBAA-B91C-4C3D-A8DE-72C9552A93E9,BAB37BFE-A2DF-4C94-9453-74E6FB7A1F28,09D6A256-C7CD-4A95-85AC-771FC07727B7,3DFCB088-399F-41F2-84CD-77D811B0FF43,F9A80406-8297-4054-98B2-7CD7D50C4A64,0DD5C5AC-2AD2-4543-844F-7E8B0ED953A0,F342CAFA-7BEB-4735-ABE3-81C01A8F9830,B7C644BD-C2E5-48EF-B121-831B7EAA9FDE,7F6B33A1-CEB5-4B15-AEAB-832CE89C2B61,743F3A60-4AC2-438F-B582-84B399E0E969,A08D832D-F8CA-4775-A67C-87B2AE9D3DE6,5E87957D-A0AB-4D2B-9995-887F21DB0F58,528BFDF1-B6D9-4063-BA6B-8CB46A41618D,9E8356DA-B84F-4163-B928-8D152C392F49,FB65926B-7CF0-49E6-84BB-8DEF63F0F896,5918B489-9061-4606-B8D8-8ED750191DBE,9D94A59B-F3E7-4D18-BACD-9044EAA4A721,DC60B3D2-0153-4ABB-B72E-904B1344DDCB,B50D0812-E546-46AC-B090-908691E0F147,D71499C9-73DE-4B45-A983-93383897B96E,5A562AB2-DD38-4FF3-A9AB-9456854DAFED,14B5FC95-22F1-46BF-B842-95EA4B81A4CA,E6EF85C6-C7B3-45BD-976C-95F245B6B38A,EE61A366-A937-41EC-AE08-95F955396F19,AF6BEB8C-0B4D-41F6-B2B8-996CC77AE1A8,33858634-6705-452C-A660-9B3F7AE64503,F55A0796-691C-4EDF-B958-A2756A3D123A,EA36784B-D951-4396-B886-A365741A4E4A,6A2B88FD-CD3A-4497-B638-A3A9F4B4BAF0,91CDE175-0CCD-4235-B2CE-AEBC004F2B54,341F6CBF-8243-4C69-B0E7-AEF1146F393B,E67A9AEE-DA03-4DCB-948F-B02A5DFE5BB5,D9122DE4-80CB-4D81-830C-B03F791581C9,3AC5BE5C-B9D0-4F61-9E0A-B130E9039B07,3209886D-A53F-42BD-9620-B2CC9FC1E620,28DCB45F-7597-449D-8C33-B5625D13B54B,A60E0587-933E-46EB-856D-BA212EEC572C,F52595C5-0A9D-48FF-9DD9-BDF4B072FCE6,BC5A812F-8302-4478-B5EA-BF19D4923BC0,A98DB624-93B2-468D-A06F-C0493F030649,2CCCE4C6-F4D3-4F5B-AF69-C4069E8DB9FA,28BBF724-7829-463D-8DB4-C4B388698BFC,28F99F05-E71B-4940-8908-C4F57A4E48FD,791B273D-AC55-4927-ADBC-C5D207A815E5,F6CFAD55-FFDD-464C-B0A8-C68480590DAA,D6C38C18-E729-4829-BF68-C73E6DD50A68,70D523DC-0E80-43B0-A6E1-CA0F945CA18E,4E005FDF-828B-4233-9845-CC05DE8E2861,82970F2C-E9A4-4713-B745-CD356F25744E,849E40A6-016F-4E18-9C86-CE8E621F3683,67C980C2-DBD5-47A4-A332-CEC4EDE04387,58326F0B-5705-4707-A700-CF0BFBEB9614,40F4A365-4163-45B7-BBEB-CFE28581AC6F,9CE44D76-C3C5-4699-833B-D2FB1B2AA71C,E3EF7BD6-2F74-41A1-9815-D60F58E68997,C9C0188A-A205-49C0-800A-D6A4934601F2,CDE8F0F0-862C-4A05-849B-D91740DC78A0,DBB599B0-A7E7-4E82-921D-D9B7F1E0A479,960B7A1D-84C8-45A1-96FD-DB56C90C134F,C7871250-A970-46E9-AE3B-DC688C96B5CE,68F2D758-BE8E-406C-9C2A-DF34D71AB3AA,B8D4B9A8-BBF2-41EA-8D13-DF6671A4F863,A1541DEE-5256-48F8-A16D-E1022D13B975,4B62E856-539D-4DAA-A27B-E21594889862,F4428E0E-1429-4433-9B08-E27A96DAA0E1,5CD4F6B4-1858-4F19-B116-E34CBDC9DBF2,06BED44C-5573-435C-B431-E41625D4E82C,F12BCB3A-3CC7-47F0-BB8F-E42BD5E733A3,A00F8229-A71E-46CB-BC6B-E94E041FB4D2,73F76859-89EB-49AE-86C8-EA85D6DF7526,183D7841-782F-4380-A51D-EB5990FBD8CC,D645A0A6-0E64-4639-9C76-F0DEC7426495,4B2E7214-AA0F-4347-AB69-F24C50EDC699,A850B36F-1E57-4FB3-942D-F2993DB63891,E52C3652-7EB8-4A28-8727-F3C2F2F7B68B,82090805-FD38-4782-B389-FB906DCF195B,1811A72A-0251-4095-80F9-FBE362C77033,EF3D01B1-D72E-480A-927C-FD988844423A,2F79FD70-2EA1-4939-ADD4-FEC11C7A31F7,868A4709-3964-425B-9499-FEDADB2D51F1,50745AF4-2483-4D1A-8E65-2382DA0420C6,5E031DC2-1893-45EC-93E7-39DD71BA754A,59D2AC3D-BF2D-47C4-BEB1-48F33AD1C01B,7D8DAE6F-4AD0-4FD0-80F7-53D747A8FDD8,EFE40F26-31C8-403F-A983-CB1DE48451C6,92878055-A546-4C7B-9637-D2AEC5E9748B,355CDFA7-0FB5-45B0-ADFC-D74D5B0501C2,0B70A2E3-8BAA-40EC-B95D-EB6A2107CD35,EC200BC8-7415-4AEE-B44D-15892E89857A,C518CE60-079F-4329-8B5F-1D63A117787F,45E2DF29-ABA4-4FB5-8741-1EAE9997D991,A48BBF7D-0545-4FB8-9D02-32FF575D6142,FE6EAD68-2FA9-4A77-8790-3523D3732FDF,F1A37FC8-80BE-46C4-92E9-35C6B9AF11B6,8FA0793F-6D7E-4490-944C-496FCB57B17A,74CAE6AD-4229-413A-8D19-4FA5D137CEB4,B9093124-9B10-4439-969C-517EF65D0B6D,1CB67DC0-CC58-4E87-A0BB-51BFFA1114FF,6C205837-B615-4393-8536-51DA9B4DAB8A,EA720B68-9C06-4AFA-9E0E-56DA03B51CC4,FCFB8E94-AF4D-4904-BBED-5A2BC02D0CDF,F81FC881-E0E6-42EF-A7D8-5A2BCAADEBA9,C8C0623D-1B6E-4CA4-8D87-5A2F3B83FA8A,F03F1CA3-9F86-4BBF-AF59-70CB43AE31CE,45FD37AE-CCBD-4F6D-9EAD-98057A99373D,CEB45FA3-0B9D-42FD-BD28-9C13C29E180A,4CE5C63C-82E5-4D90-8453-A2986AE60CCF,90B65DEB-51B0-4DBB-ADF3-A6BE54C011EA,8431AAA4-8E3F-4AED-B2AE-AFEA9D0A2528,24D91113-AC47-4932-A230-BA096C04F9EC,A66B80F9-16EA-4990-B1C4-BF7E298A636B,CE7CE2A1-EF08-48DE-B5C7-C3F81251E74E,4E7B1E2A-FF94-4714-B09C-C49A53CE01E5,927288BE-4CD8-4020-9C64-CF224B90FB5A,85F5BE92-198C-47E7-8A82-D1642DAAED50,5FC29CD9-FA8F-4625-8255-E7756BF2E902,5B053545-5BDA-4B39-A549-F16B5F5B9761,CBDCBD77-E6E4-49A8-8D88-16F9CCA11808,DD91236D-3686-4BF9-8942-93569E31C0B5,65022530-CB3C-4541-BD1A-972400447CC3,50F7DFDF-6495-45A2-B33C-ACBDF84E9D8C,803ABBBE-8C71-485B-B46C-C9529A9B5B95,9A213798-7D87-43A1-9E78-F7FA95A186EA,26EE58ED-9531-4F27-AB1B-0FC96A1D4B11,A28B856A-706B-4EDB-B0FB-1080FC6AA8E8,4C9276FA-6F74-421D-885E-9D9863941608,725D8F19-9EFF-4C11-A0A5-A875B756420B,6C55333F-AF38-4AAF-807E-B6E922C86977,1C22731A-D2E5-48F4-8B11-C4984292DD19,6CB6CC44-0B0F-4456-8AA5-0B8BA3AF6F0D,D05A4FAD-0F14-44A2-BF9E-262284CA8146,0E036B26-9C4A-4255-BCB4-2C5AA77ED763,7D908BF3-0949-469D-A81B-3959D493846B,E95FB78D-C488-40A7-B083-41AF5D6F1936,30A63017-4F28-4ED1-9DF3-68DB95CC984B,0639AA8A-5480-4464-A821-774C803C5896,16DFAC51-5407-479E-B787-90CC7376A3B2,8EA35287-3D1F-49F7-882D-9D1C30EEE615,26AB46A1-1843-473C-BB7F-A1502F8A4C73,5D65D98F-153A-4629-97A4-CB83785A3CA8,3E8B06A6-7B72-4EA0-9C4E-ED97EDD255C2,8B006632-3185-4698-B12D-B89E9433F816,B05740BD-E788-4817-9886-184395A4559D,E64D70BB-F88D-47F1-8C02-3D2386AF165D,02EA1946-AF26-4DFA-9E01-5D1D3B926456,0DBD3676-FD76-4A76-B6FD-06E01DE7AC69,AD570259-11E2-475E-AE1B-2D5A705D59F0,A07431C1-53D3-4E45-A1B9-9EFDC88D1B3E,942B2995-44FC-4CBC-AA48-AB721EC86DD0,1A24A56E-5DDE-49DB-AD1B-EE96AEBFBD93,43399EED-37E2-4D27-A593-022A94FEF93E,667C3691-DE66-4300-BE3D-06F82685DD46,0E44457A-DE44-441F-A0A1-24A0855CC9E9,0F23193F-3CD6-4BB9-AC00-266697D98F5F,4B0F50CC-48B7-4D8B-825F-3111B3D48C95,C808278A-FF04-40BD-B29B-359D15012BF1,D0CBB0FF-9963-4FA8-9141-3C49635E1CEF,6BA916DA-D944-4753-A9CA-4959A9FFE47D,F020B3A6-AE4D-4DEE-9E73-529134D3201B,DD2FB213-CE02-4D34-B6DC-5EB614DA67BA,1177A36B-A7FE-4D11-9CB9-69289FE4C523,2740E9A8-7F4E-448D-BBE3-69628D7E1F6F,55574B50-9CEA-459B-B5CA-6C3D82B2F201,1398EE7D-A81D-4546-B1FC-6EC575A51B54,FE091EBB-6420-4F04-8125-9E06E54A79B8,AC3F72CB-76E2-4058-B303-A0A974D3121D,164EFD29-13FA-450C-9C33-A27724B14BE4,981DD1DE-5F7D-4B3F-A9FD-A3DDE8A19327,1BE4B806-6B17-4CB9-B48C-A6AC9F87928F,B1CCA0EA-437B-4D77-9ACB-D01B7DD0C3A8,2715EF06-F6C8-4A5A-908F-E877DC3DC7CE,82A9A062-570C-43B3-B49A-F78F14CE1C60,EAA71366-47C8-4957-BFDA-F99796D5B037,19673154-6105-4BBC-9F6A-00ACA5E2D17C,1A758509-F414-4D38-8D9F-0CAD790913D4,807B8CB2-234E-4DE8-96EC-11E5D8ADA98D,2C175007-003B-4FF1-92D8-29710C966986,AB9740B1-C198-4DBF-BA8A-2B86FB2E7FAD,F991F6FD-0937-49DD-B374-359863184CF6,AD0F0EF4-8C8C-490C-820E-3915E21627FB,B2D6F140-FBC7-4D00-AAED-3C463888309E,8D910AC0-58AC-4196-8C60-3CD12B8389F9,C7F0FA50-0096-4B0E-AC81-45416C3D568E,CEFAC3F3-BD36-4DD5-B932-4F2342AD3E7C,59BE3496-D6A7-4F20-B69E-508F7A6FEEB7,7DAC5ECC-80D1-4B38-A95A-577DFDF1B20F,F701C02F-134D-4F0C-9E1F-5B37EB71CF9D,75DD39CD-77E3-43EB-BFB4-5E97A7B3F30D,8528D78C-ABC9-46D3-9051-60C1C5C66E04,0C7B94E8-CA7C-43FC-97E3-7A58DEFA1E0E,650BDDC6-6897-4909-9E38-83BC790636DA,BB0CD07B-AC67-4F8C-BC24-8679B463C9BD,CF887449-052D-44FE-900B-C2215E008EB0,F26D4207-CF1B-434D-93CE-DDA2D8C12BBC,9C9F0850-0842-4D0E-A11C-EAAC259B22F2,A285BC27-92B9-41F7-8476-EBAB2C0BA2DC,6774EB81-D99B-489E-BFF6-EC2CE7DA8431,ACABBD95-9086-4FF2-9EBC-EF7F5377A44D,4F79600C-9623-402F-958C-FAA740BBDA74,09CD16E5-4A87-47DC-B5DB-3773D0EE30A9,080DF3DC-031C-4A6D-A93F-4AD278A56B47,836C93A6-1F54-4282-AC33-4E32D3BF9B1D,9F91EE7E-4D17-4D25-984E-6A5B6BEDDE7B,B58447E5-3A8D-45BF-AF07-8B79A6ADC0BA,F9400D56-3E7B-4D08-AF26-B3F69F9E4B3B,CFB5EF05-3F39-45B8-93A8-B54C3D8E7631,CC9A2231-FBBF-4DF3-A173-E89CE90B9233,9513F7CF-9A0A-4234-919C-0BDD02A8224F,CE5BB5C4-7E5C-49F6-9B16-136B30693913,A3569D73-D620-4227-8275-2272FDA98CEB,6AD215D6-3CCA-4262-A784-43FA77EB2A53,88BD1C1E-C6E7-4AC2-9184-4D010B2141FC,920CF850-DA84-40D4-AD40-7CCAAAA18469,F9E5771F-F451-4B3D-87AD-831F87AD3A7B,DCBF1FC7-88F1-4D97-A884-ABC159898E73,01D67F90-CA27-41B4-A658-BB49085E15B7,60B13DC0-DA41-42BF-9B3B-BF0C21A1291A,3CC34D2D-69E0-4764-8275-DCAB4E65F643,D194147C-08D3-43D4-B345-DE00F778C69C,4562C87B-D59F-4566-AB00-DE355B6683F4,759230F5-2B71-4205-A93B-DE76A31E69A2,317CF14F-3D36-4D9D-9934-E808AFE56095,F90C6FD4-B64C-42CE-82AE-044B8793912D,6BC34689-8E4C-4B64-907B-53EBA6617C4F,3E86697A-FE44-4D37-BFC0-7E2BA09E5216,2C1E44B0-FD4B-4572-839B-98340128FB01,D54ECBF7-20F4-4030-BC15-98D73D942ADE,CBB5EF54-7DAD-49F9-B0C0-03E82726DCF1,E1BDBD57-1171-4AC6-BDE0-11ABCC190093,281D20A3-0DB1-48A7-842F-2B3AED61C7FB,A0ADCA70-CBA7-41C4-BF09-4B29100782B4,E02DFB0E-D531-4A87-8A84-703B54699826,4AB1E788-05F1-4E07-BA35-85C8B89F1349,D539C72F-9EAD-42A8-9C8E-9E0B617B8EDD,CFEE095C-D390-4751-A77F-B5C357E0D01E,8FB20211-9DBF-4C98-A0F2-B6B940F42A8D,E84EC95B-43C6-4EFD-AD50-B6E265F0C2F7,A7E8C384-1238-4A65-BFB8-C7CA7D6A1300,F3817550-6EDF-4693-AE9B-CD18F3AF92CE,DB818AE6-6CEA-4A7D-881A-D7AE71578360,C70B877F-96FE-4900-BAEA-DD668D92DDB7,07D11805-7EE3-44D9-81EF-F3225B933C9A,77415E65-6F67-4DF3-B1EC-22E7FCBF5600,B26076D7-FB83-426C-9780-768EA03D8776,25C80C9F-EFCD-48C0-8F27-BEBA9E4B73C3,0A11EC53-1AEF-448D-BB55-BF46FCE03121,B3D895DD-88BD-4768-8A11-CAC58BCF826C,63298163-CAB6-4557-A1EC-CF2C61D12609,DC722CCB-873F-49CA-B2BB-D278D8989672,3C84970A-23EE-417E-A69D-EE4ECF01D987,DBE02339-6C96-4089-ABCD-05223CFF6247,CEA7E397-C31E-40AC-9046-134086960ED4,0C6ED456-AE97-4BB8-B375-16B99EFAB3B1,2BAD3010-FD29-4CD7-AE6B-1CD88EAE4D5E,A1A3C8D2-1C84-49F2-A322-1DD5659530C2,B1CBE715-59D6-441F-A9F9-45EFAC0C1710,7B3A472B-FC95-420F-88FC-4746302B6629,4E213CFB-AE9B-4E63-9F01-768B5662765B,87D720C3-886D-4D61-9E0F-E9500FD642DD,71BB8697-390C-4B43-9863-0D8CE9CD4BD5,608F5BB1-030F-42CF-92BF-23A4607BED14,AA4A8C01-0415-4A98-B417-41E9D3E495F8,17CB011C-664E-448D-A9AB-433CA3B62F21,26C85A57-D470-4DAC-A979-5B42F90276BF,FD4A8557-87D4-4779-AD52-725C1507390D,2F42560D-73BF-4696-BA09-76402082ACF4,0C8B2572-D519-4BD7-BC7F-7FFDCF7C56FE,489F3DE9-DC75-43A3-A6E8-9474D7F40620,77409C55-B980-4C87-8C72-96D82739E8DA,023F5E72-BCBD-4F8E-9E6C-BB225100C54B,066EC131-9FAE-4207-AE88-FB860E066255,276BA61F-4A45-4439-A152-03845AD8CD66,9069B963-FB9A-4118-A0EA-0AE4F1C4CC0F,67899A97-6597-4CC1-92DA-2F0D4A7E1CD6,084C56DA-EEC3-4CE4-97CD-43F30328CC81,28DD9D7B-0832-4FA7-A38D-678925858B97,48D79633-C3CF-4711-8FEC-767455439A47,4B361DC7-1CEF-4A0C-99E3-813C25D58D18,B920F8DE-B052-426B-883B-866BF2EA3C4E,0200960C-E5B7-4BC3-85B0-92E9AECAFD04,7AB19211-BF6D-4BEC-941E-95494EE07EBD,836C97CA-2546-4AD0-9C85-9A2605293C34,C45674F3-ED22-4B64-8D8C-9B8ADAE4585F,E80C718B-9393-4367-B2DF-B1D97D5CBB17,CEB7F6BE-4CDE-43A3-BEF6-D7855FD86283,459CE252-5165-4E50-AEC3-DCBD2748CF31,086A848C-A41B-4B32-AE95-DD3BB0687689,09D72AFB-9CC1-4124-8DCD-DE3C06B2F785,ED6D2CAA-2002-41AD-B1A1-EDB88F345719,0664B36F-3170-4267-AD6F-EF1A12FC306B,FC6A7D32-4257-49A0-A329-EFC4BD9397CE,AE26AA57-CF7B-4445-B287-032F6D88DBA3,8BE98E1F-5B4E-4281-AB11-068C04F60D5F,E43BDAD8-F3C0-4FE0-AC16-080015BB1180,DEDE7CC7-9D6B-4F32-A4B7-1AE4235DB817,E428537E-A1F4-45A3-B59D-303380E563D0,13B75A8E-BDD6-4FD8-A913-3F7BF0DA7C41,7445C867-4635-408C-AD5B-45CB8DB95FDE,F23981CB-B03E-43BB-A8D4-522184260873,D98CC94C-0759-43D6-885F-89A2B78708DD,4EE7403B-375E-491F-A844-8A274AB5BEE9,ACFF688C-93BC-4D8A-91B1-8D767C943F78,2E12F5AD-8E55-4DD3-89B1-8E29F61CBBA0,95037758-306F-4423-8DDB-A05EB02DAF71,C678C765-C4CD-4EAD-9494-ACF099FECE2D,AC62E0D8-E64E-419E-AA50-B25F64A91563,818B2368-C422-4B21-BF6B-B6900305D898,C680A6DD-9543-47B3-A86F-C142D60DECFF,36AC0A47-0EEE-4BDE-ADA5-CE18B6738EB8,A3F48D18-71E3-4944-A3D4-CF4D0064F616,CED8C83E-9F5C-48D6-ABF8-D1E0F319689A,D2A14D20-1429-47B8-8317-D27CE6F3F5EF,27EBF7E8-878A-4BBE-806B-D319CB5EABD2,3AE46F97-307F-4210-AB7A-E2848BDA08E0,F799143E-5639-4B12-92C0-E52633F2396D,6C23A482-D4EF-40A9-9967-E61F70AD1052,023B2481-EA79-4C47-8733-02CD938BDB99,DF843F4C-D083-4B52-B1B6-21D8930EA024,D883AF94-CA3C-4434-A39E-3CC3A75EB151,A1B392B2-87C6-4D55-9626-41B04818332B,11CD8E08-2463-4DF6-8D20-55AAA5ED1B18,3D1C7AE6-E955-4E42-8066-60FF1B559240,5F354A71-0408-4C1C-9800-6E8590954F76,6EA9D0CD-D368-4D46-A39F-82D5BADFEA6E,A1B00EDE-83D1-428C-8C27-8DF6D034C26A,3FCA949F-0A59-41FF-B0F7-8EECF518C4FF,1A038B0D-DA13-464B-B61A-E47BE3C6BB83,F9E25D5E-429F-4FE4-B0C3-EB39A8907C52,3C3E5001-A18D-4A0F-BD2C-EF4A22C65218,2E7899F3-163E-44A8-BCF9-F08F36F07713,98D5A5A1-FD37-4899-B4A3-32AB7067CA35,5D06FCF9-ACD8-4575-8768-3A827D9CF877,BCFB044C-D51A-4E75-90F2-4C832ED73EE5,D362EA2C-DB42-4299-B7AD-079EBC2996D1,4528C65C-781D-4B67-8450-232CE687C5BB,8D6EE790-E810-496B-A919-2A444B400689,022AC8B8-1114-4AF0-BA5D-42E798DDF40D,B267A97D-CF9B-44F2-9B74-4A21F73A916D,88A9513D-2087-4A98-B2D4-65DB079CD71F,A0FAAD9D-B938-447A-A622-746B496897F3,4BC9A2E8-226D-48B3-B1F7-8E674DEA2951,D5BA35EE-531B-4787-B782-90D59223DA3C,3DCB41C3-A3C0-4330-BBE4-91135DFAD982,EED314FA-7A17-467F-9545-A8CEA3E73215,2D7335BF-4C20-42D4-86B7-AD9EE3217539,8F0D2EB4-6524-4DAD-87FA-B09FB70778AC,4FC00347-2D49-4667-9DBC-B59AC71B6897,28A10E54-736D-4774-A230-C3558135DC5B,A3056669-41E7-40DC-A3AD-DDE1D28C6EB7,B875FE5A-AB4B-4320-B412-DE6A8000D9A2,2EC884BF-BFB2-4ED7-BD41-FD14FA2DB930,89A5D1D5-3B44-4206-B19E-11DA709FDD16,1D8E68A8-EB9B-483F-9BC9-3B51482D29D4,D6531484-D090-4C36-8D56-5D8AA4D69807,5670B947-2A08-49E6-B220-6358444A4220,0C144DAE-479C-4A6E-9D52-6459CFA014F0,ADD159F7-7DCD-4187-AAD1-0AFD7185754A,D216C874-741D-482F-B046-2AC0B9FF9F1D,E120CC03-2B18-47BC-B17A-701F803CE3E8,2D896BA3-7FC8-45E0-BACE-A70C7C672A61,73656002-5B10-4B6F-BC60-B461C3DABD2D,D74A64C4-17FC-469E-AE32-E55343377473,95909A2D-DD2C-411F-83D8-F29B3EE308A2,D428A24B-72CE-499B-88A1-F91D3C486C79,D4D2FDED-25F3-4596-89CD-49349E0FA801,135E38A0-BE83-43C5-881D-4BC5E95E0BB8,8A1F4B8A-814A-4E2A-AB81-512BE8FA1B86,C71478B4-2B80-4ABB-B8FF-54BDF37F4CEA,0F5CA82A-0736-499B-A080-69FDB5331232,EAA0D21E-C5EE-488D-8EB7-76719B4FE208,C4DB36EF-CFC8-4DFB-94C0-7DE2B51849EF,7C43B287-C8B0-4EE6-B886-9CB0CE818290,FC584D1C-09BA-4317-ABB9-D6D429BBC870,6948E1B8-B2D6-400C-981C-F12FC0678C2B,F8CFA8E2-A423-4B86-B354-13A8B9F229DB,682575EB-4C5C-4751-99C7-5F4007A7AF46,197A9381-8714-4898-8322-7B1CB922B2CE,5875E0C4-554B-40B9-A5F1-7BA57E326B2F,882A7250-F7BD-48D4-B173-860877337516,1060C3DA-08EA-4CA6-A1E1-88E743E48D00,DB891E38-1B9E-4708-8A33-89382C72DB00,6A99BF41-9E8D-46B4-8BDB-8B69D25A9245,543345BC-9CF8-46F4-BF08-91D358328874,3054B7FB-CCB7-4F74-BE7B-A24888B2E143,13EB1B6A-B787-4421-AABE-ACF0DFCE77DD,E41757B3-E206-4008-AAAA-AF1444E9FCFD,A88D2E33-4B68-4086-9D2C-B9559185618C,86829184-A44C-4F92-BE76-C6B5FEB33B0B,48423272-E26F-495F-BB86-E1C23F1B6694,924567EA-C4B3-4A28-B08E-F1BF95BD979D,46653AA1-537C-43EE-9AE7-23B493F12550,12283E16-3D97-42BA-B130-66E97187429B,E6E7F4BC-E61F-4120-A2D5-8ADC305A3337,6E5E7B04-0DAA-4325-9276-DC14552F120C,149ACC6A-45C1-4D2A-8FFD-F1FDC5C1CF9E',
	--		@uid = N'F119F353-330C-48C9-9A21-5DD95F279749'
	
	
	DECLARE @diststr VARCHAR(20),
			@distmult FLOAT,
			@fuelstr VARCHAR(20),
			@fuelmult FLOAT,
			@liquidstr varchar(20),
			@liquidmult FLOAT,
			@days INT
			
	SET @days = 13

	SELECT  @diststr = [dbo].UserPref(@uid, 203)
	SELECT  @distmult = [dbo].UserPref(@uid, 202)
	SELECT  @fuelstr = [dbo].UserPref(@uid, 205)
	SELECT  @fuelmult = [dbo].UserPref(@uid, 204)
	SELECT  @liquidstr = [dbo].UserPref(@uid, 201)
	SELECT  @liquidmult = [dbo].UserPref(@uid, 200)
				
	IF @vids IS NULL OR @vids = ''
	BEGIN
		SELECT @vids = COALESCE(@vids + ',', '') + CAST(v.VehicleId AS NVARCHAR(MAX))
		FROM dbo.[Group] g
			INNER JOIN dbo.GroupDetail gd ON g.GroupId = gd.GroupId
			INNER JOIN dbo.Vehicle v ON gd.EntityDataId = v.VehicleId
			INNER JOIN dbo.UserGroup ug ON g.GroupId = ug.GroupId
		WHERE g.Archived = 0 AND g.GroupTypeId = 1 AND g.IsParameter = 0
			AND v.Archived = 0
			AND ug.UserId = @uid
			
		SET @vids = SUBSTRING(@vids, 2, LEN(@vids))
	END
	
	DECLARE @results TABLE
	(
		VehicleIntId INT,
		Registration NVARCHAR(MAX),
		ReferenceStartDate DATETIME,
		ReferenceEndDate DATETIME,
		LiveStartDate DATETIME,
		LiveEndDate DATETIME,
		Distance FLOAT,
		Fuel FLOAT,
		FuelEcon FLOAT,
		ReferenceDistance FLOAT NULL,
		ReferenceFuel FLOAT NULL,
		ReferenceFuelEcon FLOAT NULL,
		
		ReferenceFuelEconAverage FLOAT NULL,
		FuelEconAverage FLOAT NULL,
		ReferenceDistanceTotal FLOAT NULL,
		DistanceTotal FLOAT NULL
	)

	INSERT INTO @results
			( VehicleIntId ,
			  ReferenceStartDate ,
			  ReferenceEndDate ,
			  LiveStartDate ,
			  LiveEndDate ,
			  Distance ,
			  Fuel ,
			  FuelEcon
			)
	SELECT 
		v.VehicleIntId,
		
		
		--DATEADD(DAY, (-1) * @days, ref.EndDate) AS StartDate,
		--ref.EndDate,
		DATEADD(DAY, (-1) * @days, DATEADD(DAY, DATEDIFF(DAY, '19000101', ref.EndDate), '19000101')) AS StartDate,
		DATEADD(DAY, 1, DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, '19000101', ref.EndDate), '19000101'))) AS EndDate,
		
		DATEADD(SECOND, 1, ref.EndDate) AS LiveStartDate,
		DATEADD(DAY, @days + 1, ref.EndDate) AS LiveEndDate,
		
		(MAX(ld.TotalDistance) - MIN(ld.TotalDistance)) AS Distance,
		((MAX(ld.MovingFuel) - MIN(ld.MovingFuel)) + (MAX(ld.StatFuel) - MIN(ld.StatFuel))) AS Fuel,
		
		(CASE WHEN @fuelmult = 0.1 THEN
			-- L/100KM
			(((MAX(ld.MovingFuel) - MIN(ld.MovingFuel)) + (MAX(ld.StatFuel) - MIN(ld.StatFuel)))*100)/dbo.ZeroYieldNull((MAX(ld.TotalDistance) - MIN(ld.TotalDistance)))
		ELSE
			--MPG
			((MAX(ld.TotalDistance) - MIN(ld.TotalDistance)) * 1000) / dbo.ZeroYieldNull(((MAX(ld.MovingFuel) - MIN(ld.MovingFuel)) + (MAX(ld.StatFuel) - MIN(ld.StatFuel)))) * @fuelmult END) AS FuelEcon
	FROM dbo.LogData ld
		INNER JOIN dbo.Vehicle v ON ld.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.VehicleReferencePeriod ref ON v.VehicleId = ref.VehicleId
	WHERE 
		v.Archived = 0 AND ref.Archived = 0 AND ld.Archived = 0
		AND ld.LogDateTime BETWEEN DATEADD(SECOND, 1, ref.EndDate) AND DATEADD(DAY, @days + 1, ref.EndDate)
		AND v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
	GROUP BY v.VehicleIntId, ref.StartDate, ref.EndDate
	

	DECLARE @vid INT, 
			@sdateRef DATETIME, 
			@edateRef DATETIME,
			@distance FLOAT,
			@fuel FLOAT,
			@fuelEcon FLOAT
			
	DECLARE data_cur CURSOR FAST_FORWARD FOR
		SELECT VehicleIntId, ReferenceStartDate, ReferenceEndDate FROM @results

	OPEN data_cur
	FETCH NEXT FROM data_cur INTO @vid, @sdateRef, @edateRef
	WHILE @@fetch_status = 0
	BEGIN
		
		--PRINT CAST(@vid AS VARCHAR(MAX))
		--PRINT CAST(@sdateRef AS VARCHAR(MAX))
		--PRINT CAST(@edateRef AS VARCHAR(MAX))
		
		SELECT @distance = NULL, @fuel = NULL, @fuelEcon = NULL
		SELECT 
			@distance = (MAX(ld.TotalDistance) - MIN(ld.TotalDistance)),
			@fuel = ((MAX(ld.MovingFuel) - MIN(ld.MovingFuel)) + (MAX(ld.StatFuel) - MIN(ld.StatFuel))),
			@fuelEcon = (CASE WHEN @fuelmult = 0.1 THEN
							-- L/100KM
							(((MAX(ld.MovingFuel) - MIN(ld.MovingFuel)) + (MAX(ld.StatFuel) - MIN(ld.StatFuel)))*100)/dbo.ZeroYieldNull((MAX(ld.TotalDistance) - MIN(ld.TotalDistance)))
						ELSE
							--MPG
							((MAX(ld.TotalDistance) - MIN(ld.TotalDistance)) * 1000) / dbo.ZeroYieldNull(((MAX(ld.MovingFuel) - MIN(ld.MovingFuel)) + (MAX(ld.StatFuel) - MIN(ld.StatFuel)))) * @fuelmult END)
		FROM dbo.LogData ld
		WHERE LogDateTime BETWEEN @sdateRef AND @edateRef 
			AND VehicleIntId = @vid 
			AND ld.Archived = 0
		
		UPDATE @results
		SET ReferenceDistance = @distance,
			ReferenceFuel = @fuel,
			ReferenceFuelEcon = @fuelEcon
		WHERE VehicleIntId = @vid
				
		FETCH NEXT FROM data_cur INTO @vid, @sdateRef, @edateRef
	END
	CLOSE data_cur
	DEALLOCATE data_cur

	DELETE FROM @results WHERE (Distance <= 161 OR ReferenceDistance <= 161) OR Distance is NULL OR ReferenceDistance IS NULL
	
	DECLARE @refAvg FLOAT,
			@avg FLOAT,
			@refDist FLOAT,
			@dist FLOAT
	
	IF @fuelmult = 0.1
	BEGIN
		SELECT @refAvg = (SUM(ReferenceFuel)*100)/dbo.ZeroYieldNull(SUM(ReferenceDistance)) FROM @results
		SELECT @avg = (SUM(Fuel)*100)/dbo.ZeroYieldNull(SUM(Distance)) FROM @results
	END
	ELSE BEGIN
		SELECT @refAvg = ((SUM(ReferenceDistance) * 1000) / dbo.ZeroYieldNull(SUM(ReferenceFuel))) * @fuelmult FROM @results
		SELECT @avg = ((SUM(Distance) * 1000) / dbo.ZeroYieldNull(SUM(Fuel))) * @fuelmult  FROM @results	
	END

	SELECT @refDist = SUM(ReferenceDistance),
	       @dist = SUM(Distance) FROM @results
	
	UPDATE @results SET ReferenceFuelEconAverage = @refAvg, FuelEconAverage = @avg, ReferenceDistanceTotal = @refDist, DistanceTotal = @dist
	
	SELECT	v.VehicleId,
			v.FleetNumber,
			i.TrackerNumber,
			v.Registration,
			
			SUBSTRING(v.BodyType, CHARINDEX(',', v.BodyType) + 1, LEN(v.BodyType) - CHARINDEX(',', v.BodyType) + 1) AS VehicleType,
			SUBSTRING(v.Identifier, CHARINDEX(',', v.Identifier) + 1, LEN(v.Identifier) - CHARINDEX(',', v.Identifier) + 1) AS EuroSpec,
			
			dbo.TZ_GetTime(ReferenceStartDate, DEFAULT, @uid) AS ReferenceStartDate,
			dbo.TZ_GetTime(ReferenceEndDate, DEFAULT, @uid) AS ReferenceEndDate,
			dbo.TZ_GetTime(LiveStartDate, DEFAULT, @uid) AS LiveStartDate,
			dbo.TZ_GetTime(LiveEndDate, DEFAULT, @uid) AS LiveEndDate,
			
			ReferenceDistance * 1000 * @distmult AS ReferenceDistance,
			ReferenceFuel * @liquidmult AS ReferenceFuel,
			ReferenceFuelEcon,
			
			Distance * 1000 * @distmult AS Distance,
			Fuel * @liquidmult AS Fuel,
			FuelEcon,
			
			(FuelEcon - ReferenceFuelEcon) / dbo.ZeroYieldNull(ReferenceFuelEcon) AS Progress,
			
			ReferenceFuelEconAverage,
			FuelEconAverage,
			
			(FuelEconAverage - ReferenceFuelEconAverage)/ ReferenceFuelEconAverage AS ProgressAverage,

			ReferenceDistanceTotal * 1000 * @distmult AS ReferenceDistanceTotal,
			DistanceTotal * 1000 * @distmult AS DistanceTotal,
			
			@sdate AS StartDate,
			@edate AS EndDate,
			@diststr AS diststr,
			@fuelstr AS fuelstr,
			@liquidstr AS liquidstr
	FROM @results r
		INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
	ORDER BY v.FleetNumber, v.Registration
GO
