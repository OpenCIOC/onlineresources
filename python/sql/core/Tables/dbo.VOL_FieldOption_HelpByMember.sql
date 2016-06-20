CREATE TABLE [dbo].[VOL_FieldOption_HelpByMember]
(
[FieldID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[MemberID] [int] NOT NULL,
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_VOL_FieldOption_HelpByMember_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_VOL_FieldOption_HelpByMember_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[HelpText] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_FieldOption_HelpByMember] ADD CONSTRAINT [PK_VOL_FieldOption_HelpByMember] PRIMARY KEY CLUSTERED  ([FieldID], [LangID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_FieldOption_HelpByMember] ADD CONSTRAINT [FK_VOL_FieldOption_HelpByMember_VOL_FieldOption_Description] FOREIGN KEY ([FieldID], [LangID]) REFERENCES [dbo].[VOL_FieldOption_Description] ([FieldID], [LangID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_FieldOption_HelpByMember] ADD CONSTRAINT [FK_VOL_FieldOption_HelpByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
