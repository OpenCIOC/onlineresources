CREATE TABLE [dbo].[CIC_SecurityLevel_Name]
(
[SL_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[MemberID_Cache] [int] NOT NULL,
[SecurityLevel] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_Name] ADD CONSTRAINT [PK_CIC_SecurityLevel_Name] PRIMARY KEY CLUSTERED  ([SL_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_SecurityLevel_Name] ON [dbo].[CIC_SecurityLevel_Name] ([MemberID_Cache], [LangID], [SecurityLevel]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_Name] ADD CONSTRAINT [FK_CIC_SecurityLevel_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_Name] ADD CONSTRAINT [FK_CIC_SecurityLevel_Name_STP_Member] FOREIGN KEY ([MemberID_Cache]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_Name] ADD CONSTRAINT [FK_CIC_SecurityLevel_Name_CIC_SecurityLevel] FOREIGN KEY ([SL_ID]) REFERENCES [dbo].[CIC_SecurityLevel] ([SL_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
