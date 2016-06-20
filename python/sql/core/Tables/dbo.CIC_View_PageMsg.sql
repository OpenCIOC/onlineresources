CREATE TABLE [dbo].[CIC_View_PageMsg]
(
[ViewType] [int] NOT NULL,
[PageMsgID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_PageMsg] ADD CONSTRAINT [PK_GBL_PageInfo_Msg_View] PRIMARY KEY CLUSTERED  ([ViewType], [PageMsgID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_View_PageInfo_Msg_UniquePair] ON [dbo].[CIC_View_PageMsg] ([ViewType], [PageMsgID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_PageMsg] ADD CONSTRAINT [FK_CIC_View_PageMsg_GBL_PageMsg] FOREIGN KEY ([PageMsgID]) REFERENCES [dbo].[GBL_PageMsg] ([PageMsgID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_View_PageMsg] ADD CONSTRAINT [FK_CIC_View_PageMsg_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType]) ON DELETE CASCADE
GO
