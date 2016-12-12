CREATE TABLE [dbo].[CIC_View_Whitelist]
(
[IPAddress] [varchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL,
[ViewType] [int] NOT NULL
) ON [PRIMARY]
ALTER TABLE [dbo].[CIC_View_Whitelist] ADD 
CONSTRAINT [PK_CIC_View_Whitelist] PRIMARY KEY CLUSTERED  ([IPAddress], [ViewType]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_Whitelist] ADD CONSTRAINT [FK_CIC_View_Whitelist_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType])
GO
