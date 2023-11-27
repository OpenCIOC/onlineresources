<%
' =========================================================================================
'  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
'
'  Licensed under the Apache License, Version 2.0 (the "License");
'  you may not use this file except in compliance with the License.
'  You may obtain a copy of the License at
'
'      http://www.apache.org/licenses/LICENSE-2.0
'
'  Unless required by applicable law or agreed to in writing, software
'  distributed under the License is distributed on an "AS IS" BASIS,
'  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
'  See the License for the specific language governing permissions and
'  limitations under the License.
' =========================================================================================
%>

<%
Dim TXT_ANYONE, _
	TXT_ARE_YOU_SURE_DELETE_STATS, _
	TXT_AUTO_REPORTS, _
	TXT_CREATE_STATS_REPORT, _
	TXT_DELETE_STATS, _
	TXT_DELETE_STATS_TITLE, _
	TXT_DELETE_UP_TO, _
	TXT_EXAMPLE, _
	TXT_INST_DELETE_STATS, _
	TXT_IP_BEGINS_WITH, _
	TXT_LOCAL_RECORDS, _
	TXT_LOGGED_IN_USERS, _
	TXT_MAIN_STATS_PAGE, _
	TXT_NO_DATE_CHOSEN, _
	TXT_NUMBER_STATS_DELETE, _
	TXT_OTHER_RECORDS, _
	TXT_PUBLIC, _
	TXT_PUBLIC_USERS, _
	TXT_RANK, _
	TXT_RECORD_VIEWS_BY, _
	TXT_RECORD_VIEWS_IN, _
	TXT_RECORDS_OWNED_BY, _
	TXT_STATS_RESULTS, _
	TXT_STATS_WERE_DELETED, _
	TXT_TOO_MANY_RECORDS, _
	TXT_TOP_50_RECORDS, _
	TXT_TOTAL_RECORD_USE, _
	TXT_TOTAL_RECORDS, _
	TXT_USE_BY_AGENCY, _
	TXT_USERS_WITH_TYPE

Sub setTxtStats()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ANYONE = "Anyone"
			TXT_ARE_YOU_SURE_DELETE_STATS = "Are you sure you want to delete all statistics prior to "
			TXT_AUTO_REPORTS = "Quick Reports"
			TXT_CREATE_STATS_REPORT = "Create Stats Report"
			TXT_DELETE_STATS = "Delete Old Statistics"
			TXT_DELETE_STATS_TITLE = "Delete Old Statistics"
			TXT_DELETE_UP_TO = "Delete Up to and Including"
			TXT_EXAMPLE = "Example" & TXT_COLON
			TXT_INST_DELETE_STATS = "So...you want to delete old statistics? " & _
				"Periodically clearing out your statistics makes the record counts more meaningful and reduces the size of your daily download..." & _
				"but <span class=""Alert"">ensure that you have an archived copy first!</span> " & _
				"You can grab the statistics table out of your daily download. " & _
				"Give your archive database a unique file name, and confirm that it has the correct records before you delete your statistics. " & _
				"It's a good idea to keep a copy of the actual records along with the statistics, so you that you have an accurate snapshot of that period of time. " & _
				"This is especially important if you permanently delete records. " & _
				"It is a requirement of your CIOC membership that you leave at least 6 months of statistics in your database; keeping one full fiscal year of statistics is recommended." & _
				"You may want to time your archiving to your year end etc."
			TXT_IP_BEGINS_WITH = "User's IP address begins with" & TXT_COLON
			TXT_LOCAL_RECORDS = "Local Records"
			TXT_LOGGED_IN_USERS = "Logged In Users Only"
			TXT_MAIN_STATS_PAGE = "Main Stats Page"
			TXT_NO_DATE_CHOSEN = "You have not chosen a date."
			TXT_NUMBER_STATS_DELETE = "# Stats to Delete"
			TXT_OTHER_RECORDS = "Other Records"
			TXT_PUBLIC = "Public"
			TXT_PUBLIC_USERS = "Public Users Only"
			TXT_RANK = "Rank"
			TXT_RECORD_VIEWS_BY = "Record views by"
			TXT_RECORD_VIEWS_IN = "Record views in"
			TXT_RECORDS_OWNED_BY = "Records owned by"
			TXT_STATS_RESULTS = "Statistics Search Results"
			TXT_STATS_WERE_DELETED = "The selected statistics were deleted."
			TXT_TOO_MANY_RECORDS = "You have selected too many records for this report. Please select fewer records and try again."
			TXT_TOP_50_RECORDS = "Top 50 Records"
			TXT_TOTAL_RECORD_USE = "Total Record Use"
			TXT_TOTAL_RECORDS = "Total Records"
			TXT_USE_BY_AGENCY = "Use by Agency"
			TXT_USERS_WITH_TYPE = "Users with the User Type"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ANYONE = "N'importe quel"
			TXT_ARE_YOU_SURE_DELETE_STATS = "Êtes-vous certain de vouloir supprimer toutes les statistiques antérieures au "
			TXT_AUTO_REPORTS = "Rapports rapides"
			TXT_CREATE_STATS_REPORT = "Créer un rapport de statistiques"
			TXT_DELETE_STATS = "Supprimer les statistiques anciennes"
			TXT_DELETE_STATS_TITLE = "Supprimer les statistiques anciennes"
			TXT_DELETE_UP_TO = "Supprimer jusqu'à et y compris"
			TXT_EXAMPLE = "Exemple" & TXT_COLON
			TXT_INST_DELETE_STATS = "Ainsi, vous voulez supprimer des statistiques anciennes ? " & _
				"La suppression périodique des statistiques permet d'avoir un dénombrement des dossiers plus significatif et de réduire la taille du téléchargement quotidien..." & _
				"mais <span class=""Alert"">avant tout, assurez-vous d'avoir sauvegardé une copie d'archive !</span> " & _
				"Vous pouvez extraire le tableau de statistiques de votre téléchargement quotidien. " & _
				"Attribuez à votre base de données d'archives un nom de fichier unique et vérifiez qu'elle contient les bons dossiers avant de procéder à la suppression des statistiques. " & _
				"Il est préférable de conserver une copie des dossiers avec les statistiques ; vous aurez ainsi un compte-rendu précis de cette période. " & _
				"Cela est d'autant plus important si vous supprimez les dossiers de manière définitive. " & _
				"C'est une exigence de votre adhésion au CIOC que vous gardez dans votre base de données statistiques pour les six derniers mois; Il est recommandé de conserver les statistiques d'un exercice complet. " & _
				"Vous pouvez procéder à l'archivage à chaque fin d'année, etc."
			TXT_IP_BEGINS_WITH = "L'adresse IP de l'utilisateur commence par" & TXT_COLON
			TXT_LOCAL_RECORDS = "Dossiers locaux"
			TXT_LOGGED_IN_USERS = "Utilisateurs connectés uniquement"
			TXT_MAIN_STATS_PAGE = "Page d'accueil des statistiques"
			TXT_NO_DATE_CHOSEN = "Vous devez choisir une date."
			TXT_NUMBER_STATS_DELETE = "Nombre de statistiques à supprimer"
			TXT_OTHER_RECORDS = "Autres dossiers"
			TXT_PUBLIC = "Public"
			TXT_PUBLIC_USERS = "Public uniquement"
			TXT_RANK = "Classement"
			TXT_RECORD_VIEWS_BY = "Dossier consulté par"
			TXT_RECORD_VIEWS_IN = "Dossier consulté en"
			TXT_RECORDS_OWNED_BY = "Dossiers appartenant à"
			TXT_STATS_RESULTS = "Résultats de la recherche sur les statistiques"
			TXT_STATS_WERE_DELETED = "Les statistiques sélectionnées ont été supprimées."
			TXT_TOO_MANY_RECORDS = "Vous avez sélectionné trop de dossiers pour ce rapport. Veuillez sélectionner moins de dossiers et essayer de nouveau."
			TXT_TOP_50_RECORDS = "50 premiers dossiers"
			TXT_TOTAL_RECORD_USE = "Total des consultations"
			TXT_TOTAL_RECORDS = "Total des dossiers"
			TXT_USE_BY_AGENCY = "Consultations par l'agence"
			TXT_USERS_WITH_TYPE = "Utilisateurs avec type d'utilisateur"
	End Select
End Sub

Call setTxtStats()
%>
