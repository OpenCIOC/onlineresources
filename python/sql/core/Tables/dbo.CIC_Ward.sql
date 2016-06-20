CREATE TABLE [dbo].[CIC_Ward]
(
[WD_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[WardNumber] [smallint] NOT NULL,
[Municipality] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Ward] ADD CONSTRAINT [PK_CIC_Ward] PRIMARY KEY CLUSTERED  ([WD_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_Ward_UniquePair] ON [dbo].[CIC_Ward] ([WardNumber], [Municipality]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Ward] ADD CONSTRAINT [FK_CIC_Ward_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[CIC_Ward] ADD CONSTRAINT [FK_CIC_Ward_GBL_Community] FOREIGN KEY ([Municipality]) REFERENCES [dbo].[GBL_Community] ([CM_ID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_Ward] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_Ward] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Ward] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Ward] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_Ward] TO [cioc_login_role]
GO
