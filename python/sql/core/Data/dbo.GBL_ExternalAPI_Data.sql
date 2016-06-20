SET IDENTITY_INSERT [dbo].[GBL_ExternalAPI] ON
INSERT INTO [dbo].[GBL_ExternalAPI] ([API_ID], [Code], [CIC], [VOL], [SchemaLocation]) VALUES (1, N'clbcexport', 1, 0, 'special/CLBCVendorSchema.xsd')
INSERT INTO [dbo].[GBL_ExternalAPI] ([API_ID], [Code], [CIC], [VOL], [SchemaLocation]) VALUES (2, N'clbcupdate', 1, 0, 'special/CLBCVendorUpdateSchema.xsd')
INSERT INTO [dbo].[GBL_ExternalAPI] ([API_ID], [Code], [CIC], [VOL], [SchemaLocation]) VALUES (3, N'o211export', 1, 0, NULL)
INSERT INTO [dbo].[GBL_ExternalAPI] ([API_ID], [Code], [CIC], [VOL], [SchemaLocation]) VALUES (7, N'211ontario.ca', 1, 0, NULL)
INSERT INTO [dbo].[GBL_ExternalAPI] ([API_ID], [Code], [CIC], [VOL], [SchemaLocation]) VALUES (8, N'realtimestandard', 1, 1, NULL)
SET IDENTITY_INSERT [dbo].[GBL_ExternalAPI] OFF
SET IDENTITY_INSERT [dbo].[GBL_ExternalAPI] ON
INSERT INTO [dbo].[GBL_ExternalAPI] ([API_ID], [Code], [CIC], [VOL], [SchemaLocation]) VALUES (9, N'airsexport', 1, 0, 'import/airs_3_0_modified.xsd')
SET IDENTITY_INSERT [dbo].[GBL_ExternalAPI] OFF
