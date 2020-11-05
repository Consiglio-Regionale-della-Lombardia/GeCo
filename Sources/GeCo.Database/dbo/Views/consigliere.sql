
CREATE VIEW [dbo].[consigliere]
AS
SELECT DISTINCT
	 P.id_persona
	,P.nome
	,P.cognome
	,GP.id_gruppo
	,GP.codice_gruppo
	,GP.nome_gruppo
	,GP.attivo
	,L.id_legislatura
	,L.num_legislatura
FROM
	dbo.persona AS P
	INNER JOIN dbo.join_persona_gruppi_politici AS P_GP ON P.id_persona = P_GP.id_persona
	INNER JOIN dbo.gruppi_politici AS GP ON P_GP.id_gruppo = GP.id_gruppo
	INNER JOIN dbo.legislature AS L ON P_GP.id_legislatura = L.id_legislatura
WHERE
	(1 = 1)
	AND (L.id_legislatura = 30)
	AND (GP.attivo = 1)
	AND (GP.deleted = 0)
	AND (P.deleted = 0)
	AND (P_GP.data_fine IS NULL)

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[23] 4[20] 2[33] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "persona"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 209
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "join_persona_gruppi_politici"
            Begin Extent = 
               Top = 6
               Left = 247
               Bottom = 163
               Right = 436
            End
            DisplayFlags = 280
            TopColumn = 7
         End
         Begin Table = "gruppi_politici"
            Begin Extent = 
               Top = 114
               Left = 38
               Bottom = 222
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "legislature"
            Begin Extent = 
               Top = 62
               Left = 446
               Bottom = 170
               Right = 631
            End
            DisplayFlags = 280
            TopColumn = 1
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 3075
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 2745
         Or = 1350
         Or = 1350
 ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'consigliere';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'        Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'consigliere';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'consigliere';

