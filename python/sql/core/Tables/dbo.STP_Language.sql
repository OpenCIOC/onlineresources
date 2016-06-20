CREATE TABLE [dbo].[STP_Language]
(
[LangID] [smallint] NOT NULL,
[LanguageName] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LanguageAlias] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Culture] [varchar] (5) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LCID] [int] NOT NULL,
[Active] [bit] NOT NULL,
[ActiveRecord] [bit] NOT NULL CONSTRAINT [DF_STP_Language_RecordActive] DEFAULT ((0)),
[DateFormatCode] [int] NOT NULL CONSTRAINT [DF_STP_Language_DateFormatCode] DEFAULT ((106))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STP_Language] ADD CONSTRAINT [PK_STP_Language] PRIMARY KEY CLUSTERED  ([LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_STP_Language_LangIDIncl] ON [dbo].[STP_Language] ([LangID]) INCLUDE ([DateFormatCode]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[STP_Language] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[STP_Language] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[STP_Language] TO [cioc_vol_search_role]
GO
