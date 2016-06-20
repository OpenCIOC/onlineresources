CREATE TABLE [dbo].[CIC_SecurityLevel_RecordType]
(
[SL_RT_ID] [int] NOT NULL IDENTITY(1, 1),
[SL_ID] [int] NOT NULL,
[RT_ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_RecordType] ADD CONSTRAINT [PK_CIC_SecurityLevel_RecordType] PRIMARY KEY CLUSTERED  ([SL_RT_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_SecurityLevel_RecordType_UniquePair] ON [dbo].[CIC_SecurityLevel_RecordType] ([SL_ID], [RT_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_RecordType] ADD CONSTRAINT [FK_CIC_SecurityLevel_RecordType_CIC_RecordType] FOREIGN KEY ([RT_ID]) REFERENCES [dbo].[CIC_RecordType] ([RT_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_RecordType] ADD CONSTRAINT [FK_CIC_SecurityLevel_RecordType_CIC_SecurityLevel] FOREIGN KEY ([SL_ID]) REFERENCES [dbo].[CIC_SecurityLevel] ([SL_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_SecurityLevel_RecordType] TO [cioc_login_role]
GO
