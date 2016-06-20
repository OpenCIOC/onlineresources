CREATE TABLE [dbo].[GBL_Robot_IPPattern]
(
[IPPattern] [varchar] (16) COLLATE Latin1_General_100_CI_AI NOT NULL,
[RobotID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Robot_IPPattern] ADD CONSTRAINT [PK_GBL_Robot_IPPattern] PRIMARY KEY CLUSTERED  ([IPPattern]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Robot_IPPattern] ADD CONSTRAINT [FK_GBL_Robot_IPPattern_GBL_Robot] FOREIGN KEY ([RobotID]) REFERENCES [dbo].[GBL_Robot] ([RobotID])
GO
