SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_GetClosestId]
(
	@uid UNIQUEIDENTIFIER,
	@vids NVARCHAR(MAX) = NULL
)
AS

	--DECLARE @uid UNIQUEIDENTIFIER,
	--		@vids NVARCHAR(MAX)

	--SET @uid = N'988d25de-65e9-4fc5-8981-3d2b4ea0fea'
	----SET @vids = N'9694866D-685A-4AAD-A47C-B9FEE23CB50A,74EC9D4D-3E3B-4142-8725-86729F3FDBE8,60F5ABCD-3C07-49A5-9EC4-64AFF8EB8221,12626673-DDF9-4658-9CAC-B361C2CD9D8A,2A7169A2-337E-41B6-B5C2-8F0B9A9EF37E,A09B8049-DFF6-40D8-801A-AF509B8EB1D1,7B0756C9-F3BC-44C1-A9BA-318DF234B16C,21D1F1CC-A7FA-4DE5-96D0-C44907394A9A,FA9C9C1F-6626-4075-BA67-3727374AF025,18797F95-7D78-4C46-A9B3-08DA30B85407,A3CFBE36-D689-4E0B-9DF0-3565C019839A,52F6419F-D780-4774-B93E-BBA7549A6AB8,CC67F8C4-E6EE-4730-AA78-86DF23120154,36226833-29F1-4D98-8BD1-72D08CBF88E9,AED844C2-0F88-48CC-8927-92C1DEBA432C,AD6A29C0-0C79-4712-9090-2E1FE8DC5F21,E53E3988-4776-42DD-826C-39E4FAA0154A,533C57B4-085F-4201-823B-ADD62E43DA74,256C467D-9175-4E4D-866D-C9BD600A750F,06A6D86B-0F3D-4171-943E-22BA1C9C9174,8FEC7837-EF15-4900-98E6-83A565DEA0EA,94CC2BA9-48A3-44F3-B74E-2F281E370292,75799916-F721-405E-BBE2-647B7187642A,27057550-B394-47F1-B2D9-EC4696C67EAF,2F88599E-1CD6-470B-8761-F3840F23BD88,3589D0B8-269C-4933-BE09-33FBA2A04BF0,5596E669-AA42-48CF-86E5-B70B02DA5DEF,8AABB1C7-4200-4289-98B7-DA123349E663,23288C31-E78C-4845-976B-FDBBEBB33D88,5AC39C85-7F89-4B02-909C-1F9069FCBAA4,A6D92344-6DD6-469E-9FC9-BB87021F0EF9,D37D229B-59D8-46BD-BCE7-35F0B394DCAC,C518E682-B62F-447B-B223-DC204ED0B2C3,DBC4AB56-2AB6-4022-B257-7D2765D5FD6E,30854F4B-CBAE-4AA5-A2CF-DD2F27AC7AF7,468820BA-0715-422C-968D-E3276E71C147,F029F419-FB15-4EAB-9A3E-3E3A6378EABB,993EEB7F-E512-4FA5-8962-395A98DEC529,55DCF028-E308-4947-96C7-384A677C0110,7B23FD77-22DB-4331-A7C5-8BA36CAC9028,A4EBDCAD-FB6B-4B88-8C48-6046F22990E6,E2AA5FDB-4C0C-4C2B-82F6-DA34B206C879,C66CD586-B2A7-4C10-AB04-F43796EFF8A5,E61998B5-F5FE-4F41-AE13-3368B73B6DFA,8B1327BB-0926-4767-B240-D01207DE1F5F,E2593240-642C-431B-806D-BC82B2AD846B,9F226377-4CA0-443D-AB8C-125AC0F8A1C4,5E1AD7EA-38FD-48FA-A576-A34841AA0E85,9B124E17-A06B-4537-B34B-9E2D9EB8D128,8A1B16B4-41B4-44E5-B8CE-439EA9E11B04,50D9473D-F1B4-44F6-A865-4606AF659745,ED7107B7-72BC-4621-A58A-6AC214668F23,122018FE-8AC5-43CB-B1B0-E163CA3E023E,71517545-EABE-4939-94E6-89722C1DA3CE,E8FE364C-AF52-4954-8333-13CA86254273,C61F0267-EC4D-42E3-8162-AFEED6A2E151,FD4927AA-B71E-4CC4-93F9-325F28785465,267DECE4-16D2-47B0-A4DB-F5944E8B5CB6,18D277D9-A808-4203-9DC3-7C38BE667196,9008E78C-8D0D-4C27-BE5C-1AA5E4F76588,8B26DFCE-75B5-44AA-8D11-8F8FEB7D3AED,D3C09512-2815-4FE0-BB98-3550FBCE065D,D7510294-CF2B-420E-AC6B-CC3DCC704299,9E9DFA2D-74EA-455A-B085-6DD91E4C8F3E,D851F5CE-18BF-4D5F-9C89-8D1355EF4867,656B6B97-9209-4CD5-87D9-A17405CE49F5,5C308C6D-F7DB-4D4C-81AF-D4C6F37AFA17,9D784848-44B7-420C-B200-1D10411A69F4,C88F2276-3169-4025-BB60-2B4D9534A0FE,39B59B67-831B-4E23-A1C5-A07B10736E91,9C68B78A-FBAE-4CF2-8F3F-12C92BA05765,CCE1C6B2-2AD1-4274-A908-CEAA50631187,D664A237-B70A-42AE-9218-FEA2444E7B02,01F5DA1C-AAB4-42C0-8C24-848E22E89ECE,1ED53E8F-AF55-405E-9586-A0F7244E6F95,49939D7B-5138-4F07-A447-5242724C3124,ACE89D2E-ABAB-4FAE-95A1-ED5A7E477B45,9980D484-1CDA-4F81-A0E6-760389A1AC1C,563E59C4-E6A7-4E17-A655-03AA6BE108DC,14CAD3A5-DB98-4B85-9C35-376813FD7AA9,7901CD71-9674-445B-B82E-AAAE3DE16C50,C8897213-1D47-43A1-8D07-1DA41AC99687,A2D23CD1-6782-409B-AB5D-14EAAE194DFD,6C4B0870-1C92-4668-96FD-167783CDABFE,316492DD-6CC0-41E0-92C0-AF85D5FBF2D6,69079EDE-F7EC-4793-B748-26C3D9153241,ED3FC8AB-F6A9-453A-9B31-1C33BD9B9F33,D724FB59-9261-4E27-86D3-BB7966319D3A,90F32FCD-2995-4282-9D8B-6636579B3785,B02CB28D-05CE-49A4-807A-566DBDCBD1C7,9DD711CD-F2DD-4345-9F8A-E32D807123ED,8AE54D11-D5CE-4915-A2B8-508C7E72E253,19951C09-3019-44DF-82CE-03DA25E3327C,5DB34E58-8735-434D-BE06-C89C4C752503,4130E7E0-EBF0-4BC9-9FBB-E07F3C1FFB9E,E2CBA582-D288-4B41-930D-CE844A4D78CB,7C2213C4-7EA5-4309-8AFD-744313FA96B4,1C4E1D13-1E87-4E14-B85D-4E32098A9ADD,02A1741C-B452-4C16-89C6-6A3B763A6812,F23DEB65-9E0F-43BB-92F1-126D200A0DF2,50C0CC12-0DED-4C24-8760-633D670FAA9E,76E3356A-DD3E-4824-A376-723AD778A4F8,A3196E35-7E77-4F6F-B685-09AA5B8AD6B0,4AE08DF9-56EE-4F65-89A6-5045DCFF333B,A12B02B7-E03C-47A3-8988-094140140FB1,E6B70CE1-D649-4906-ABE0-81445C74C0BB,C6EA27B1-5A78-4E9A-BA2E-E9E0B69AF295,741454E2-5814-4080-AD2D-DF32C4A29584,9BAC6D4A-5928-4F6C-8F9C-84B7D75D31FF,72D9D27C-820E-42F4-A068-254F4280F8BD,CB946372-F970-4045-A5BE-91679F1E3650,6D724710-42E2-4D31-BEBD-665E726209CF,68A1DE48-E0B7-49DE-8068-4311A2A3DE02,F5D51C95-FE3A-4A72-B977-FF8633A1B892,A6E27268-40D4-4D77-9C82-04839C1C4BAD,AFF49913-075C-46F4-998C-3A955D18E287,19C64164-71A0-43CA-8B35-6FF3416D7A33,EEF0FD5A-1A80-4624-826C-CA25601A22E7,14CB4BA4-61F5-481A-9FCE-C6C441D8D511,E74D3D84-545B-4FDE-A190-7F047E32CD05,53620482-70AF-4B4F-9DA5-22B946BDBAA4,496B1D39-38F0-499C-920B-55552690C3F0,39239087-9B35-4F37-AEB8-5D909A85B555,21C9E717-A42B-4729-95A6-4EB417895980,BAA282EE-477D-4BBA-A683-EF0B061C0F9B,45C2F5C9-7C40-4EB3-9DA4-437F75C63580,E3694748-93C0-414B-BE9C-1C46829ECEB7,9C291202-8E90-4FF1-A6B6-DD3BD4023348,4D6425CB-2660-48F2-B647-2B5A78BD46DE,697F7A7A-B28B-438C-9500-85CD820946B9,99F2BB1D-30F1-4587-8969-D4384E47129B,D530F3C1-BF94-439C-8733-C6599FFEC687,B5C192BB-6B46-4FB6-8459-A96F6B54CC72,F1109646-299D-4C61-A52A-5D2CC3CF527E,37659B9B-4950-4E73-8ECC-1F0650E8876E,9E9A5800-5C0A-4FA0-AE0C-CB7DA4EE242D,B5C65B61-4DEE-4B1E-B7D4-385DE1E99662,C72A67C0-3F9D-4574-A6F4-8466FE17900C,AB9A6D29-9583-475C-A6B6-A874DB4D337D,3CFA62B5-1001-4757-A5E5-6518D978E768,45418AD8-9691-4C8B-B059-873BF1113D11,E9C5D37A-AE21-4A69-BD40-4C749D0F96B0,A88AC32C-9CBA-4B04-9F3D-9642A94AFB6D,D1B198BA-D96B-419A-9BCC-D1B5FD421A6D,2B39FD08-56B9-492C-A17F-9A97D77E97D4,B78AE916-371F-4565-B3B1-30E4C6964D3A,F1891B7E-6221-4BA3-924A-8343B1E14257,737E896C-D12D-4A63-84ED-253F52B09EF1,D1646EE5-1919-49B8-B56D-6FD46897C61C,8CD67991-4FF6-491F-A483-B96A6CA48B75,0BA90EF6-6E0F-4E14-A08C-07C6F6CCE63B,6F7DD738-1628-43A5-B7CA-EE5D5829B899,17557C25-EC25-4894-8D47-CD4E0D98076E,B63D2F8C-3E55-4207-A9E1-ABAEA2AC9A13,D35E52B7-F57D-4F3D-B819-ED16BE0E9986,8D56372F-6552-46FC-A350-C0D26FD513AF,60F81B69-6508-490A-90A1-E24874CC8D04,0DCD6B4F-33A1-4DD4-87E1-8AECE657E0B6,BCD021BF-F1EC-4528-A65C-C4A6062300BD,F5EFA0EF-639F-4997-A776-8E644C465B6A,42C32F33-30B1-4432-A9D4-2BE64FA0AE9B,6057D01A-B7B2-4DE8-8C53-F1C7EC63520A,C0B939A2-595F-444B-BA6B-E9814A5714A1,BAB3DD11-612A-4371-8C10-A01F48FA659B,6E8D90B6-4481-43EA-B1AD-C043CD4F3E1D,839F69FD-6843-42CA-9BFA-43E3E098F3BB,6E76BFF5-6C01-40C4-BCDF-D726FBAEF392,462ED6B8-5C4F-4BA8-9BA8-FB5E7F53C52C,AB5CE36B-9DF0-4C0E-B25C-BC5281BA9046,41503659-72C8-41BB-80DE-C89E90E17D5F,35CB3B69-245B-427D-A466-8336E43888A2,0F0D16E1-8A57-4418-8C46-2068CDCDEBE2,41372786-9BF5-4CF0-B6F3-091497B3256E,E9D72090-CA7D-42F9-B756-3D3C66C57C76,92AB7F32-474B-4616-BE3D-487B5DAAA723,7CB11973-CB9D-47CC-8246-CFC1843E3F79,D9E3238C-1432-475C-A946-95AF334249A4,233FB4D0-D8BE-4F20-8A5A-CBAB5339C51C,F4914866-997F-46F3-B358-A81107800CBC,6BC175A4-918E-442D-8A66-6B2B464C255B,B20DEF7D-DDB9-4F3B-AC99-9CF12E600F30,10DA6990-2EE0-47C9-B1C7-804ADDFA14A5,3C421E04-9501-4BC5-A80E-27898F70E59E,615FA161-E8B9-4E70-8DB1-D1C1B5269D03,C169D964-656A-4833-8A8C-FACE34A020E5,5E8454A0-B37A-44F6-A1F9-6A1596EB514E,4AED0975-18D9-4B6B-BBEA-C75A2AB7BCB9,9E21389B-8FDF-4EA6-91F8-83B637005793,62F5FAD5-29E3-49D9-BEBB-64345EE4BA60,B5E16260-AAC1-47BE-AC1F-ADC0738876F7,922189DD-8A95-4141-B596-220C625B6196,CC2D082E-AC60-454A-A32C-99867A2442B7,BDD72D38-C869-4145-805C-6F4FCB06D7A0,795371B4-D6D9-4CDA-B6E8-ABF2234A88F7,87AF1FB8-2AE3-4B66-88A2-4DBC2D580841,760C4C77-E3DB-41FC-891C-8608819834B0,5A9FEBB5-57AD-42AA-80BD-7C2A6DCBAC84,E88A3B01-8B1E-4512-847F-7AEFC5D79156,37B1ECA8-2324-44F5-8438-4FCBA6D55CB7,3FEE79C4-9D4C-4CA3-9098-C8DFC1C00FAF,03359E06-1155-4307-BF74-7E5AC0C5474B,2F034253-EA18-42F9-B40E-25C332BC072B,93B4E1D9-CF5F-4D26-95A7-64CDDA601EFD,CCA5564D-4341-41A5-A047-F34F29E4DC7F,DD585B12-3564-4871-B2D6-2C2B542C0A9C,85D155D0-BF0B-4C4B-9468-FBBF2DE68F98,916961F5-48C3-4122-86BE-FCAC391A0026,F4965BAF-8135-4688-8107-6DF8AF6F085D,2CFB0B79-D493-4B9B-A814-7B6643844D5E,A7689AA1-B7E2-49E2-8898-577F91355B18,03439ADB-31B9-478E-B708-D8F74A46D460,10569D84-1DB4-4631-92D6-66E91EF53406,86F0445F-F273-42F4-925C-28D426D2136C,4D1AFFC1-DB6C-4599-8BF9-87AA96BA99A7,048E6561-8124-460E-85D6-2126FABA313F,8933D432-B1A6-40AC-ABAA-A0234D80AEE0,E83E81D2-08B0-4BF8-A737-F0E0754C0894,38F9E768-F675-4601-AD00-2C25F132EA5B,D4D009C7-D377-4FEE-B775-CC3642549880,4DA1D105-6797-4DEB-B4AB-E52B713C5CE4,259B97E2-77D0-4C0C-A203-C5E4E725022A,D953F390-41E8-4759-B0C4-56A30DA133AC,70AD50B1-3607-4C9F-9406-6B35B5C2AB05,6C8308A6-8EC0-4BAF-BD47-E11D085C122A,EFBCE3CA-C214-4D31-A68C-06246045190B,E216932A-ED59-4582-B8CA-58D294FACBED,69AE5971-44BA-40F1-86D3-8523F0831115,00FE82FD-3FA7-41CC-A06E-D085CADEC1DF,8C3373DB-7E80-4E28-BD14-4AEB4A2FAD98,EAA6183A-912E-43CC-9F77-9DC4389739B0,6EEE48F9-2886-464B-8C76-2CF1A6B54362,0DA13209-3619-4AEC-80CC-43507C958D47,66A9BAFD-1F97-4455-90D1-B45014F835FE,647D44DB-C6E9-43AD-B82A-E26EC50FEA36,10B8E7FE-2AED-42BC-AA23-F43B1E37B805,D276A66A-0385-459F-A7FA-B9E82056E607,0E1BAE1C-8809-423E-815E-C7C0872338C9,A7F80DB0-5D2D-4961-93B0-9331351AD513,5E66C339-BBD4-4E14-B2B8-3611C73B2A96,C795AF98-0A19-4C88-A1E4-B54DDC03C8F1,15906D9F-A237-4324-AF96-3BCB4A694DBC,D14DAEE8-2E83-4DAB-B113-294BC90D8714,8E8F4039-DDD1-49C8-A6C9-9DEE995237AA,B5742CA7-735E-463A-86EB-E11BFF29C35A,CE63FB49-6E13-44DC-94C4-593A23CA6ED1,0353C3B9-8A74-4A4D-8798-D904256F5C3E,4BD3FFD6-C6CA-43C8-ADEA-F88EF5E98731,EA2030F2-C0C4-4371-9689-FBA55818542A,7EAA3BDA-01AC-4A28-8B8C-566935071AE0,C6174328-D1E5-49AB-8680-38AF34B82D83,48E885D0-7425-4AE0-BF77-576737190668,064DD22B-4DBF-426E-99B1-393E0394DAD4,59E5D953-2E00-4A28-9788-2B5AEAB2C319,51077888-7535-4BAD-ABAB-42D21ABA6A61,41D8AC2F-23C0-4BCB-94C5-04C489585A02,099CF2DD-BF7B-4CB6-B4DC-A3E34B063C88,248483F9-6CB2-4F39-9669-BF701188025E,ECDE36EA-E9AC-4AED-B03C-06F08459D6AC,A273B63E-DF99-4AB9-A6FD-F5790D2DEDC2,2F86C4DB-0224-4432-9A5F-F6B1AEFBC884,576DE6F0-DA10-4D1D-BDDB-B82A252125B7,5087E83F-4A0E-41C1-9646-D2B4045F6348,8958AFEF-8ECC-4FFD-8963-3BA36DD76B73,196401D0-22A0-47EF-BA3A-AE49715732BA,42DA53CF-BC37-4A23-A285-C3D9DFE70B53,68AEDDDA-35DB-4814-932D-E6B8B0931695,5D7A6E45-FD11-4A78-9017-CF62B742F4FF,3C75CACD-9CB9-4B8B-9A57-B4BFD7F7980E,1B5C286E-ED4F-4B95-919A-E01BF208AFF6,BBBDAA51-4479-4510-BAAB-3377A5615559,63B9449F-16F2-4CAA-B3FB-E76634C5CFC3,A9C67198-D21E-4066-90E8-349569F183AA,7F298105-7429-4877-BB46-D644ABCB4426,3F4F1CE5-F6C7-4586-945A-5908247C8922,765FF12A-C029-4731-AC2F-7A5FA79C50DF,733A6452-0029-4AE5-96BE-4813747AB9E3,DAC4EB75-B6BA-48B5-891F-A3C007AC2A2A,7D0DFC43-F727-4B56-BB76-11D069C31633,89066D06-F6E9-4559-B049-40D5A4E2B256,A7AC96DA-1020-44A7-B6CE-6000AB054BC0,CA4E3C42-8B03-4D21-BF76-A0615DDC2442,A30F80F7-2F5D-4497-BDD6-438F8EE60AAB,E3316B75-B387-4426-B7D9-7D3FF685D625,F262F961-EA82-44A2-999E-8F7C1DEB26FB,A1FF1421-E7DE-4EE2-874F-3B88C3218428,8F301D44-339E-4F17-A536-F27752F61E96,3A7B68E1-37F5-4F85-A23A-66056518810E,DBFE0ED1-0290-424A-8CD8-D6938E64E6A3,70AEB396-5607-4EE1-8697-A2516E1A1B4A,CEF2C6E1-F004-46D6-B341-1996B6C6B59F,0BC66D52-3D0D-4D1E-B3FD-89838FBE4D49,F1E48A0A-11F5-4038-927E-2EB460C53ABD,363E6D84-06E6-42CC-82D9-879E9429AFDE,00D44FE8-0448-4CCC-949A-1A535003D14B,C7E99B52-A7D7-4998-A1E8-21F1AE388140,6252A020-779D-49F3-BCC6-8373C30453BA,E6AB4DAF-F538-43BB-825D-14FC7E752E59,14647A8C-1474-4E50-A4A2-DEE7CB1CFFA2,2D28901E-1D3A-419B-A587-4D015C6DC608,D5BA1540-7712-4AFA-A40D-97923BE93590,97A55394-166A-4712-9C39-45535B48E495,703A0588-DBF1-406F-8B95-65E81B8751BC,E75EEFB6-8A39-431B-9483-D5881BE49952,9096FC87-7F2D-4129-B260-0860E5EEADF9,C0C98548-F0C3-4AC4-ACBE-4D056B76537C,BB1F2D33-A844-44B5-BC26-ECD0609FBC47,96BB4F69-E20A-4984-B34A-2980DE3500B4,F0B0472D-D4C8-40B2-9CCE-CB453E099A20,E4644FB2-8AA8-41AC-91DE-AADCC9EE4E95,9634D39E-6313-499B-879B-BF0F89029B99,210A1A33-8C37-421F-9C6D-7FBA7A6E521F,84B66FC1-EC2A-4E66-8801-32661CBE5C99,FCF16CAD-8434-42DD-9F4E-93EF8F5C6A36,144A19D6-06D3-476E-90D3-6C03FFD4BB09,3419086E-7F03-4D3E-B149-FB1013C1DAD8,4731F0AA-67B0-4F78-B9A3-910DB9CE60B7,02B2DE8F-6C23-4FE1-8142-E718EAD24648,BA4A3971-EEC4-4131-86BE-EAFF157DF022,B857E832-76D9-4DC8-8F13-B422D8776122,2F8157D4-A099-4D81-B299-16F23CE5600D,47DB3486-2BBB-4079-BC86-92ECAA0FD1CA,82C84ED0-8039-4CA2-B4F8-67F873C9552E,FEEB627C-8609-48E3-82C2-6DAFCFCDC4AE,B8B5ADF5-0866-4E15-A433-EB86A5F5A02B,5DB5FAC8-CEDE-4E1A-A37E-510A38F50EEE,D5E20DCB-5E1A-4E24-8A10-FA06E42480F2,A0E44B94-803B-4D4F-9CAF-7712F8C51D3E,4F20D974-8D49-4C25-88EE-90F22FC117FC,C9FB3112-3B68-4A9C-9489-B17EBEBB2EAB,5A9CC28E-CD6B-45BB-AD9F-DF12FAA7251D,ADE34975-9DC7-46ED-8EDF-1C5EA01AD989,38263054-EF93-4EB8-9436-FAD5933E5A2C,C02988B7-6C58-44F9-9A15-BB33AEFB83AB,12248FDA-2C7F-48CF-83CB-E93F0DB724FE,AC4D1861-CE25-49ED-B26E-04AE408175E6,F931448B-C404-43B5-A7D3-5CE975D5D090,8184D645-575E-4FDD-A7F7-8D9C54252FE4,D25FE0DF-702A-472E-8A6A-500564BA2C2C,57DA4D98-D1CC-41FC-9D7A-C8E822D5CCCC,1E90BA46-D41E-44CD-8413-71F7A613EBEC,63BDDC23-5887-47A9-B5AD-EC1DC7170D89,DEDB50F3-F6B4-4D57-ACBD-5A888144EBCD,D0EA7BAE-266A-4982-9621-C3F10BBA7F62,7B078E2C-5582-4BBF-B1D1-A09EE05FD854,AC84EFF5-10AC-400B-AB32-A72B9E69B039,0070BD94-CA16-4EA6-8B93-8267F9CB8D7B,CA37D667-25A5-495A-B9F3-AED1F4CD03B1,C5C19608-D735-405A-8FC2-0362EC0C12F3,7B0FD837-2455-499D-B239-14758EC7D910,23CF959B-694A-486F-BCE9-A979FA4DACC1,7571FF06-65FD-473C-923C-D97EA33DC2B2,6AFB5C0B-CACF-4A08-9ED2-E8855B91382E,0D40D427-7762-4C94-A05D-57402B0A2DDF,0E05CEC7-548C-41AE-85DD-6A24ECD58C10,6F5EA062-452E-4C9D-9D79-1F5D428EB8E3,3EEE4AA1-B215-4769-9DB5-9A34EC28D9AA,47FAC9CC-902F-4792-80DE-7664BF130F71,A2C8AEC2-90BF-4D7B-BAB9-AB7B7DAD8688,BD616650-E689-4F34-9699-96633C89ACE6,CD6A2DB3-6CE5-47B5-8590-57BF2B49F849,3F4BDE44-F54F-489E-8282-9BC25562AC44,7E035581-C477-4FCF-B085-51BD5DB79BE8,2F25412D-AFEF-4909-8521-4A0FC583A1A7,7BD4BD26-35C2-45DA-BAED-F35FF327441B,627810B0-D7DA-481D-B457-1C45910FDDFD,DDD8D290-FE91-4166-8567-38BA07D78D6D,C5A4C425-42E0-44DD-A9DF-4F580CFE5927,51E4B30A-FF50-477C-ADCD-7BDD83F6116D,1A88300E-36D7-4E04-8A59-438936FD442B,CFCECB4C-269F-4050-AF5B-1E794329A401,B3473DDA-E9F3-4FD3-AB95-C37CE3F5B3C7,116A1065-C0AD-466C-ABC2-8A954F4EC389,F7EA378B-B5FF-4D8E-B997-6BFC521BE86B,746E5A79-F58E-4E33-962A-A778FB85DD68,6A206EBC-AE3D-420A-A839-DF61A01CAB14,4001ED79-FD26-4E38-825A-3A67EE2CF461,9C6EE04F-51EA-47C2-A7FC-D8F634141581,816C0387-AE07-418D-89E0-F6DF0422F4CE,44FCA973-EA01-4DED-A3FA-33DB1883B614,883F3E4E-0D84-4051-9A4E-DB4D35924876,23544FCB-8743-4BAA-83B5-4ACFAD85C3AB,C598BABC-E893-4204-BB97-A28B4E269597,24C48F9C-B4DE-475F-8C86-02FEE18CFB2F,67695212-6B12-4A01-B2D8-681BECBE8CF0,DC466A50-81E6-4C6E-8DF1-25AFD667BED2,F819FE87-1807-40E1-A078-0B6EF68F02A1,4BBF9F52-9772-4ABD-A84C-AB39498F9577,936544FF-3F5D-4E47-A144-C31658C7DA3A,16FB2B67-E232-4951-B5E3-B718B07182FB,8545E4BE-04E4-4EE7-BF48-76F036F946A6,3834732D-4288-4D39-BF9A-1D8A5E6FB1FC,8B856FBF-1220-42F2-A88F-6E08BC1C5486,1A402BB5-E059-49E7-A460-9E488CE509EE,E9158B81-AF37-4925-9A7D-13844FA05540,D6F29081-FEB5-419C-B8E6-A4B1F9DA3BDD,9B3F6E3E-1F81-4C3F-BF84-38CDA18C0866,A38746D9-4DFF-4FD5-B6C3-2C4B15A09956,3C4513C1-254E-442D-85D5-5FC1A0EFC4B6,8E3E0319-D1E0-464E-8E5D-6187D27B3C66,CADC2E25-3D66-47CA-8FC1-5A6D09000BDD,E5E4BAE0-D468-426F-BA44-EA540CF7C51B,FEB10F21-4240-4204-B86F-68542A95AE3B,668C616B-295A-43ED-9A95-9ABEA1992549,D8137066-5924-4245-B34F-529FE9C0169B,541B1C43-2070-43BE-9826-B79EE7DDF153,4B43A776-2612-4228-B50F-E925EC172A68,9C7C6CEE-6255-4B09-982A-C92DE0057B44,A6B1F69C-87D7-4444-81AD-E0EA50760BF4,6D1C5A7C-78A9-4A03-9B1B-D579D19A219E,5F66E35D-9FDA-4D1B-AC74-2863FCE3B7B3,5475ECAB-EC43-4E74-8EE3-5DEEBE1A74A8,0BC13952-F7B0-4A6F-9D60-CB6A456CEB48,B478C2A1-715A-4CA6-8228-882EBC33AE33,25D890E3-D649-427B-BA20-B0C50753F5C7,DF98349E-94D4-445C-B6F1-213E2096EAFE'
	--SET @vids = NULL
	----SET @vids = N'9694866D-685A-4AAD-A47C-B9FEE23CB50A'

	IF @vids IS NULL
	BEGIN
		SELECT @vids = COALESCE(@vids + ',', '') + CAST(VehicleId AS NVARCHAR(MAX))
		FROM 
		(
			SELECT DISTINCT v.VehicleId
			FROM dbo.Vehicle v
				INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
				INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
				INNER JOIN dbo.UserGroup ug ON ug.GroupId = g.GroupId
			WHERE g.IsParameter = 0 AND g.GroupTypeId = 1 AND g.Archived = 0
				AND v.Archived = 0
				AND ug.Archived = 0 AND ug.UserId = @uid
		) t
	END

	DECLARE @vIntIds NVARCHAR(MAX)

	SELECT @vIntIds = COALESCE(@vIntIds + ',', '') + CAST(VehicleIntId AS NVARCHAR(MAX))
	FROM 
	(
		SELECT DISTINCT v.VehicleIntId
		FROM dbo.Vehicle v
		WHERE v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
	) t
	
	DECLARE @result BIGINT
	SELECT TOP 1 @result = e.EventId
	FROM dbo.Event e WITH (NOLOCK)
	WHERE e.VehicleIntId IN (SELECT Value FROM dbo.Split(@vIntIds, ','))
		AND e.EventDateTime BETWEEN DATEADD(MONTH, -1, GETDATE()) AND GETDATE()
	ORDER BY e.EventId DESC
    

	SELECT @result AS LastId


GO
