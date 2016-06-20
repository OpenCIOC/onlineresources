/*
Run this script on:

10.10.41.11.Test1_2012_11    -  This database will be modified

to synchronize it with:

FIZBAN\SQL2014.cioc_2011_01_13

You are recommended to back up your database before running this script

Script created by SQL Data Compare version 11.2.1 from Red Gate Software Ltd at 09/11/2015 12:25:10 AM

*/
		
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS, NOCOUNT ON
GO
SET DATEFORMAT YMD
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
DECLARE @TemplateMap table (new int, name nvarchar(100))

PRINT(N'Add rows to [dbo].[GBL_Template_Layout]')
INSERT INTO [dbo].[GBL_Template_Layout] ([CREATED_DATE], [CREATED_BY], [MODIFIED_DATE], [MODIFIED_BY], [SystemLayout], [LayoutType], [DefaultSearchLayout], [LayoutCSS], [LayoutCSSURL], [LayoutCSSVersionDate], [AlmostStandardsMode], [FullSSLCompatible], [UseFontAwesome], [UseFullCIOCBootstrap]) OUTPUT inserted.LayoutID, 'largefooter' INTO @TemplateMap VALUES ('2015-10-26 15:54:00.000', 'KL', '2015-10-30 00:15:00.000', 'KL', 1, 'footer', 0, NULL, 'footer_large.scss', '2015-10-27 13:11:44.157', 0, 1, 0, 1)
INSERT INTO [dbo].[GBL_Template_Layout] ([CREATED_DATE], [CREATED_BY], [MODIFIED_DATE], [MODIFIED_BY], [SystemLayout], [LayoutType], [DefaultSearchLayout], [LayoutCSS], [LayoutCSSURL], [LayoutCSSVersionDate], [AlmostStandardsMode], [FullSSLCompatible], [UseFontAwesome], [UseFullCIOCBootstrap]) OUTPUT inserted.LayoutID, 'crumbheader' INTO @TemplateMap VALUES ('2015-10-26 16:35:00.000', 'KL', '2015-10-30 10:26:00.000', 'KL', 1, 'header', 0, NULL, 'header_dualbcrumb.scss', '2015-10-30 10:26:08.010', 0, 1, 0, 1)
INSERT INTO [dbo].[GBL_Template_Layout] ([CREATED_DATE], [CREATED_BY], [MODIFIED_DATE], [MODIFIED_BY], [SystemLayout], [LayoutType], [DefaultSearchLayout], [LayoutCSS], [LayoutCSSURL], [LayoutCSSVersionDate], [AlmostStandardsMode], [FullSSLCompatible], [UseFontAwesome], [UseFullCIOCBootstrap]) OUTPUT inserted.LayoutID, '6panel' INTO @TemplateMap VALUES ('2015-10-29 16:19:00.000', 'KL', '2015-11-08 17:34:00.000', 'KL', 1, 'volsearch', 0, NULL, 'volsearch_multipanel.scss', '2015-10-30 10:30:24.833', 0, 1, 0, 1)
INSERT INTO [dbo].[GBL_Template_Layout] ([CREATED_DATE], [CREATED_BY], [MODIFIED_DATE], [MODIFIED_BY], [SystemLayout], [LayoutType], [DefaultSearchLayout], [LayoutCSS], [LayoutCSSURL], [LayoutCSSVersionDate], [AlmostStandardsMode], [FullSSLCompatible], [UseFontAwesome], [UseFullCIOCBootstrap]) OUTPUT inserted.LayoutID, 'largefooteralt' INTO @TemplateMap VALUES ('2015-10-26 15:54:00.000', 'KL', '2015-10-30 00:15:00.000', 'KL', 1, 'footer', 0, NULL, 'footer_large.scss', '2015-10-27 13:11:44.157', 0, 1, 0, 1)
INSERT INTO [dbo].[GBL_Template_Layout] ([CREATED_DATE], [CREATED_BY], [MODIFIED_DATE], [MODIFIED_BY], [SystemLayout], [LayoutType], [DefaultSearchLayout], [LayoutCSS], [LayoutCSSURL], [LayoutCSSVersionDate], [AlmostStandardsMode], [FullSSLCompatible], [UseFontAwesome], [UseFullCIOCBootstrap]) OUTPUT inserted.LayoutID, '2panel' INTO @TemplateMap VALUES ('2015-10-29 16:19:00.000', 'KL', '2015-11-08 17:34:00.000', 'KL', 1, 'volsearch', 0, NULL, 'volsearch_dualpanel.scss', '2015-10-30 10:30:24.833', 0, 1, 0, 1)
PRINT(N'Operation applied')

PRINT(N'Add rows to [dbo].[GBL_Template_Layout_Description]')
INSERT INTO [dbo].[GBL_Template_Layout_Description] ([LayoutID], [LangID], [CREATED_DATE], [CREATED_BY], [MODIFIED_DATE], [MODIFIED_BY], [LayoutName], [LayoutHTML], [LayoutHTMLURL]) VALUES ((SELECT new FROM @TemplateMap WHERE name='largefooter'), 0, NULL, NULL, NULL, NULL, N'Large Footer - Bootstrap', NULL, 'footer_large.en_CA.html')
INSERT INTO [dbo].[GBL_Template_Layout_Description] ([LayoutID], [LangID], [CREATED_DATE], [CREATED_BY], [MODIFIED_DATE], [MODIFIED_BY], [LayoutName], [LayoutHTML], [LayoutHTMLURL]) VALUES ((SELECT new FROM @TemplateMap WHERE name='crumbheader'), 0, NULL, NULL, NULL, NULL, N'Breadcrumb Dual Header - Bootstrap', NULL, 'header_dualbcrumb.en_CA.html')
INSERT INTO [dbo].[GBL_Template_Layout_Description] ([LayoutID], [LangID], [CREATED_DATE], [CREATED_BY], [MODIFIED_DATE], [MODIFIED_BY], [LayoutName], [LayoutHTML], [LayoutHTMLURL]) VALUES ((SELECT new FROM @TemplateMap WHERE name='6panel'), 0, NULL, NULL, NULL, NULL, N'Volunteer 6-Panel Search - Bootstrap', NULL, 'volsearch_multipanel.en_CA.html')
INSERT INTO [dbo].[GBL_Template_Layout_Description] ([LayoutID], [LangID], [CREATED_DATE], [CREATED_BY], [MODIFIED_DATE], [MODIFIED_BY], [LayoutName], [LayoutHTML], [LayoutHTMLURL]) VALUES ((SELECT new FROM @TemplateMap WHERE name='largefooteralt'), 0, NULL, NULL, NULL, NULL, N'Large Footer Alternate - Bootstrap', NULL, 'footer_large_alternate.en_CA.html')
INSERT INTO [dbo].[GBL_Template_Layout_Description] ([LayoutID], [LangID], [CREATED_DATE], [CREATED_BY], [MODIFIED_DATE], [MODIFIED_BY], [LayoutName], [LayoutHTML], [LayoutHTMLURL]) VALUES ((SELECT new FROM @TemplateMap WHERE name='2panel'), 0, NULL, NULL, NULL, NULL, N'Volunteer 2-Panel Search - Bootstrap', NULL, 'volsearch_dualpanel.en_CA.html')
PRINT(N'Operation applied')

COMMIT TRANSACTION
GO
