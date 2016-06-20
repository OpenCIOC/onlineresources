CREATE TABLE [dbo].[CIC_RecordType]
(
[RT_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_CIC_RecordType_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_CIC_RecordType_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[RecordType] [char] (1) COLLATE Latin1_General_100_CI_AI NOT NULL,
[ProgramOrBranch] [bit] NOT NULL CONSTRAINT [DF_CIC_RecordType_ProgramOrBranch] DEFAULT ((0)),
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_CIC_RecordType_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_RecordType] ADD CONSTRAINT [PK_CIC_RecordType] PRIMARY KEY CLUSTERED  ([RT_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_RecordType] ON [dbo].[CIC_RecordType] ([RecordType]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_RecordType] ADD CONSTRAINT [FK_CIC_RecordType_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CIC_RecordType] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_RecordType] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_RecordType] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_RecordType] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_RecordType] TO [cioc_login_role]
GO
