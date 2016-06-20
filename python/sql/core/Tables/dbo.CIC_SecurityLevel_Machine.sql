CREATE TABLE [dbo].[CIC_SecurityLevel_Machine]
(
[MachineID] [int] NOT NULL,
[SL_ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_Machine] ADD CONSTRAINT [PK_CIC_SecurityLevel_Machine] PRIMARY KEY CLUSTERED  ([MachineID], [SL_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_Machine] ADD CONSTRAINT [FK_CIC_SecurityLevel_Machine_CIC_Offline_Machines] FOREIGN KEY ([MachineID]) REFERENCES [dbo].[CIC_Offline_Machines] ([MachineID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_Machine] ADD CONSTRAINT [FK_CIC_SecurityLevel_Machine_CIC_SecurityLevel] FOREIGN KEY ([SL_ID]) REFERENCES [dbo].[CIC_SecurityLevel] ([SL_ID]) ON DELETE CASCADE
GO
