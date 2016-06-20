CREATE TABLE [dbo].[GBL_Robot]
(
[RobotID] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[DisplayName] [varchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[DisplayOrder] [int] NOT NULL CONSTRAINT [DF_GBL_Robot_Name_DisplayOrder] DEFAULT ((99))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Robot] ADD CONSTRAINT [PK_GBL_Robot] PRIMARY KEY CLUSTERED  ([RobotID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_Robot] ON [dbo].[GBL_Robot] ([Name]) ON [PRIMARY]
GO
