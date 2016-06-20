CREATE TABLE [dbo].[CIC_Offline_Machines]
(
[MachineID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[MachineName] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL,
[PublicKey] [varchar] (1000) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Offline_Machines] ADD CONSTRAINT [PK_CIC_Offline_Machines] PRIMARY KEY CLUSTERED  ([MachineID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_Offline_Machines] ON [dbo].[CIC_Offline_Machines] ([MemberID], [MachineName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Offline_Machines] ADD CONSTRAINT [FK_CIC_Offline_Machines_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
