SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_STP_Language_Check] AS
BEGIN

SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Dec-2011
	Action: NO ACTION REQUIRED
*/

IF NOT EXISTS(SELECT * FROM STP_Language) BEGIN
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (0, N'English', N'English', N'en-CA', 4105, 1, 1, 106)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (1, N'Deutsch', N'German', N'de', 1031, 0, 0, 104)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (2, N'Français', N'French', N'fr-CA', 3084, 0, 0, 106)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (3, N'日本語', N'Japanese', N'ja', 1041, 0, 0, 111)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (5, N'Español', N'Spanish', N'es-MX', 2058, 0, 0, 103)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (6, N'Italiano', N'Italian', N'it', 1040, 0, 0, 106)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (7, N'Nederlands', N'Dutch', N'nl', 1043, 0, 0, 106)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (8, N'Norsk', N'Norwegian', N'no', 1044, 0, 0, 106)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (9, N'Português', N'Portuguese', N'pt', 2070, 0, 0, 105)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (11, N'Svenska', N'Swedish', N'sv', 1053, 0, 0, 106)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (12, N'čeština', N'Czech', N'cs', 1029, 0, 0, 104)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (13, N'magyar', N'Hungarian', N'hu', 1038, 0, 0, 107)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (14, N'polski', N'Polish', N'pl', 1045, 0, 0, 106)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (15, N'română', N'Romanian', N'ro', 1048, 0, 0, 106)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (16, N'hrvatski', N'Croatian', N'hr', 1050, 0, 0, 106)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (17, N'slovenčina', N'Slovak', N'sk', 1051, 0, 0, 104)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (18, N'slovenski', N'Slovenian', N'sl', 1060, 0, 0, 106)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (19, N'ελληνικά', N'Greek', N'el', 1032, 0, 0, 103)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (20, N'български', N'Bulgarian', N'bg', 1026, 0, 0, 106)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (21, N'русский', N'Russian', N'ru', 1049, 0, 0, 106)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (22, N'Türkçe', N'Turkish', N'tr', 1055, 0, 0, 106)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (25, N'latviešu', N'Latvian', N'lv', 1062, 0, 0, 106)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (26, N'lietuvių', N'Lithuanian', N'lt', 1063, 0, 0, 106)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (28, N'繁體中文', N'Traditional Chinese', N'zh-TW', 1028, 0, 0, 111)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (29, N'한국어', N'Korean', N'ko', 1042, 0, 0, 111)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (30, N'简体中文', N'Simplified Chinese', N'zh-CN', 2052, 0, 0, 111)
	INSERT [STP_Language] ([LangID], [LanguageName], [LanguageAlias], [Culture], [LCID], [Active], [ActiveRecord], [DateFormatCode]) VALUES (32, N'ไทย', N'Thai', N'th', 1054, 0, 0, 106)
END

SET NOCOUNT OFF

END

GO
