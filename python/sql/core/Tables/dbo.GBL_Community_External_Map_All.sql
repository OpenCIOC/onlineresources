CREATE TABLE [dbo].[GBL_Community_External_Map_All]
(
[CM_ID] [int] NOT NULL,
[SystemCode] [varchar] (30) COLLATE Latin1_General_100_CI_AI NOT NULL,
[EXT_ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Community_External_Map_All] ADD CONSTRAINT [PK_GBL_Community_External_Map_All] PRIMARY KEY CLUSTERED  ([CM_ID], [SystemCode], [EXT_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Community_External_Map_All] ADD CONSTRAINT [FK_GBL_Community_External_Map_All_GBL_Community_External_Map] FOREIGN KEY ([CM_ID], [SystemCode]) REFERENCES [dbo].[GBL_Community_External_Map] ([CM_ID], [SystemCode]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Community_External_Map_All] ADD CONSTRAINT [FK_GBL_Community_External_Map_All_GBL_Community_External_Community] FOREIGN KEY ([EXT_ID]) REFERENCES [dbo].[GBL_Community_External_Community] ([EXT_ID])
GO
