CREATE TABLE [dbo].[VOL_View_PageMsg]
(
[ViewType] [int] NOT NULL,
[PageMsgID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_PageMsg] ADD CONSTRAINT [PK_VOL_View_PageInfo_Msg] PRIMARY KEY CLUSTERED  ([ViewType], [PageMsgID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VOL_View_PageInfo_Msg_UniquePair] ON [dbo].[VOL_View_PageMsg] ([ViewType], [PageMsgID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_PageMsg] ADD CONSTRAINT [FK_VOL_View_PageMsg_GBL_PageMsg] FOREIGN KEY ([PageMsgID]) REFERENCES [dbo].[GBL_PageMsg] ([PageMsgID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_View_PageMsg] ADD CONSTRAINT [FK_VOL_View_PageMsg_VOL_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[VOL_View] ([ViewType]) ON DELETE CASCADE
GO
