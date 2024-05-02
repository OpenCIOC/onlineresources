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
Dim	TXT_ACCEPT_AND_CLOSE, _
	TXT_AGE_GROUP, _
	TXT_AGE_GROUP_ADULTS, _
	TXT_AGE_GROUP_CHILDREN, _
	TXT_AGE_GROUP_OLDER_ADULTS, _
	TXT_AGE_GROUP_YOUNG_ADULTS, _
	TXT_AGE_GROUP_YOUTH, _
	TXT_AGE_GROUPS, _
	TXT_AGREED_TO_BE_CONTACTED, _
	TXT_AGREED_TO_PRIVACY_POLICY, _
	TXT_APPLICATION_COUNT, _
	TXT_APPLICATION_DATE, _
	TXT_APPLICATIONS, _
	TXT_APPLICATIONS_OVER_TIME, _
	TXT_ARE_YOU_SURE_DEACTIVATE_ACCOUNT, _
	TXT_AREA_OF_INTEREST, _
	TXT_AREA_OF_INTEREST_ERROR, _
	TXT_BLOCK, _
	TXT_BLOCKED, _
	TXT_BY, _
	TXT_COMMUNITY_ERROR, _
	TXT_CONFIRM_APPLICATION_HIDE, _
	TXT_CONFIRM_DEACTIVATE_ACCOUNT, _
	TXT_CONFIRM_EMAIL_ADDRESS, _
	TXT_CONTACT_INFO, _
	TXT_COUNT, _
	TXT_CREATE_NEW_VOL_PROFILE, _
	TXT_CREATE_PROFILE, _
	TXT_CREATE_PROFILE_BENEFITS_1, _
	TXT_CREATE_PROFILE_BENEFITS_2, _
	TXT_CREATE_PROFILE_BENEFITS_3, _
	TXT_CREATE_PROFILE_BENEFITS_4, _
	TXT_CREATE_VOL_PROFILE, _
	TXT_CREATED_DATE, _
	TXT_CRITERIA_DEMOGRAPHICS, _
	TXT_CURRENT_PASSWORD_REQUIRED, _
	TXT_DATE_OF_BIRTH, _
	TXT_DATE_OF_BIRTH_ERROR, _
	TXT_DATES_AND_TIMES, _
	TXT_DEACTIVATE, _
	TXT_DEACTIVATE_ACCOUNT, _
	TXT_DEACTIVATE_PROMPT, _
	TXT_DID_NOT_SELECT_ANY, _
	TXT_DO_YOU_HAVE_A_PROFILE_ALREADY, _
	TXT_EDIT_OUTCOME, _
	TXT_EMAIL_ADDRESS, _
	TXT_EMAIL_MY_NEW_PW, _
	TXT_EMAIL_NOTIFICATIONS, _
	TXT_EMAIL_REQUIRED, _
	TXT_EMAIL_SENT, _
	TXT_EMAIL_SUBJECT, _
	TXT_EMAIL_REACTIVATE_SUBJECT, _
	TXT_ERROR_EDITING_OUTCOME, _
	TXT_ERROR_UPDATING_PROFILE, _
	TXT_FIND_INTERESTS, _
	TXT_FINISH_CREATING_ACCOUNT, _
	TXT_FINISH_REACTIVATING_ACCOUNT, _
	TXT_FIRST_NAME_REQUIRED, _
	TXT_FORGOT_PASSWORD, _
	TXT_HI, _
	TXT_I_AGREE_TO_PRIVACY_POLICY_1, _
	TXT_I_AGREE_TO_PRIVACY_POLICY_2, _
	TXT_INST_COMMUNITIES, _
	TXT_INST_CONFIRM_APPLICATION_HIDE, _
	TXT_INST_DATE_OF_BIRTH, _
	TXT_INST_DATES_AND_TIMES_PROFILE, _
	TXT_INST_PROFILE_SEARCH, _
	TXT_INST_PROFILE_VIEWS, _
	TXT_INST_RESET_PW, _
	TXT_INST_UNSUBSCRIBE, _
	TXT_INST_UNSUBSCRIBE_STAFF, _
	TXT_INTEREST, _
	TXT_INVALID_CT_VALUE, _
	TXT_INVALID_PID_VALUE, _
	TXT_LAST_NAME_REQUIRED, _
	TXT_LINK_EXPIRE_NOTICE, _
	TXT_LIST_APPLICATIONS, _
	TXT_LOGIN_CONFLICT, _
	TXT_LOGIN_NOW, _
	TXT_LOGOUT_BEFORE_CREATE, _
	TXT_MAY_REVIEW_MY_SEARCHING_PROFILE, _
	TXT_MY_APPLICATIONS, _
	TXT_MY_PERSONAL_INFO, _
	TXT_MY_SEARCH_PROFILE, _
	TXT_NEW_VP, _
	TXT_NO_COMMUNITIES_HAVE_BEEN_SELECTED, _
	TXT_NO_INTERESTS_HAVE_BEEN_SELECTED, _
	TXT_NO_VOL_PROFILE_EMAIL, _
	TXT_NO_VOL_PROFILES, _
	TXT_NONE_SPECIFIED, _
	TXT_NOTIFY_ME_NEW, _
	TXT_NOTIFY_ME_UPDATED, _
	TXT_OF_UC, _
	TXT_OF_YOUR_CIOC_LOGIN, _
	TXT_OUTCOME, _
	TXT_PASSWORD_NOT_SECURE_VP, _
	TXT_PASSWORD_REQUIRED_VP, _
	TXT_PASSWORDS_MUST_MATCH_VP, _
	TXT_PERSONAL_INFO, _
	TXT_PLEASE_FOLLOW_LINK, _
	TXT_PREFERRED_LANGUAGE, _
	TXT_PRIVACY_POLICY, _
	TXT_PROFILE_COUNT, _
	TXT_PROFILE_COUNT_ACTIVE, _
	TXT_PROFILE_COUNT_AGREE_CONTACT, _
	TXT_PROFILE_COUNT_AGREE_PRIVACY, _
	TXT_PROFILE_COUNT_RECEIVE_NEW, _
	TXT_PROFILE_COUNT_RECEIVE_UPDATED, _
	TXT_PROFILE_COUNT_TOTAL, _
	TXT_PROFILE_COUNT_VERIFIED, _
	TXT_PROFILE_COUNTS, _
	TXT_PROFILE_SEARCH, _
	TXT_PROFILE_VIEWS, _
	TXT_PROFILE_WAS, _
	TXT_PROFILES_OVER_TIME, _
	TXT_REACTIVATE_ACCOUNT, _
	TXT_RECEIVES_NEW_NOTIFICATIONS, _
	TXT_RECEIVES_UPDATED_NOTIFICATIONS, _
	TXT_REMEMBER_WORKS_WITH_ALL_SITES, _
	TXT_REMOVE_ALL, _
	TXT_RETURN_TO_PROFILE_PAGE, _
	TXT_SEARCH_NOW, _
	TXT_SEARCH_PROFILE, _
	TXT_SELECTED_INTERESTS, _
	TXT_SET_DATE_RANGE, _
	TXT_SINCE, _
	TXT_START_A_NEW, _
	TXT_SUBSCRIPTIONS, _
	TXT_SUBSCRIPTIONS_NEW, _
	TXT_SUBSCRIPTIONS_NEW_AND_UPDATED, _
	TXT_SUBSCRIPTIONS_NONE, _
	TXT_SUCCESS_CREATE, _
	TXT_SUCCESS_CRITERIA, _
	TXT_SUCCESS_DEACTIVATE, _
	TXT_SUCCESS_REACTIVATE, _
	TXT_SUCCESS_UPDATE, _
	TXT_SUCCESSFUL, _
	TXT_THE_PROFILE_ID, _
	TXT_THE_VOLUNTEER_CENTRE, _
	TXT_THERE_WERE_VALIDIATION_ERRORS, _
	TXT_TOGGLE_DISPLAY_ALL, _
	TXT_TOTAL_PROFILES, _
	TXT_UNBLOCK, _
	TXT_UNBLOCKED, _
	TXT_UNSUBSCRIBE, _
	TXT_UNSUBSCRIBE_ME, _
	TXT_UNSUBSCRIBE_SOMETHING_WENT_WRONG, _
	TXT_UNSUBSCRIBE_SUCCESSFUL, _
	TXT_UNSUBSCRIBED, _
	TXT_UNSUCCESSFUL, _
	TXT_UPDATE_VOL_PROFILE_INFO, _
	TXT_UPDATE_VOL_PROFILE_CRITERIA, _
	TXT_USE_MY_SAVED_SEARCH_PROFILE, _
	TXT_USER_NOT_AGREED_TO_CONTACT, _
	TXT_USERS_WITH_A_PROFILE, _
	TXT_USERS_WITHOUT_A_PROFILE, _
	TXT_VIEW_NAME, _
	TXT_VIEW_NUMBER, _
	TXT_VIEW_OR_UPDATE, _
	TXT_VIEWS_ALLOW_PROFILES, _
	TXT_VOL_PROFILE_CONFIRMATION, _
	TXT_VOL_PROFILE_DETAILS, _
	TXT_VOL_PROFILE_LOGIN, _
	TXT_VOL_PROFILE_PASSWORD_RESET, _
	TXT_VOL_PROFILE_PRIVACY_POLICY, _
	TXT_VOL_PROFILE_SEARCH_RESULTS, _
	TXT_VOL_PROFILE_SUMMARY, _
	TXT_VOL_PROFILE_UNSUBSCRIBE, _
	TXT_VOLUNTEER_PROFILE, _
	TXT_WELCOME, _
	TXT_WOULD_YOU_LIKE_TO_REACTIVATE, _
	TXT_YEAR, _
	TXT_YOU_HAVE_BEEN_SENT_PASSWORD, _
	TXT_YOU_MUST_FIRST, _
	TXT_YOU_REQUESTED_PW_RESET, _
	TXT_YOU_REQUESTED_REACTIVATION, _
	TXT_YOU_SIGNED_UP_FOR, _
	TXT_YOU_SUBMITTED_EMAIL_CHANGE, _
	TXT_YOUR_ACCOUNT_REACTIVATED, _
	TXT_YOUR_EMAIL_CONFIRMED, _
	TXT_YOUR_EMAIL_PLEASE_SIGN_IN, _
	TXT_YOUR_NEW_PASSWORD_IS, _
	TXT_YOUR_PASSWORD_COULD_NOT_BE_RESET, _
	TXT_YOUR_PASSWORD_IS_RESET, _
	TXT_YOUR_PROFILE_COULD_NOT_BE_REACTIVATED, _
	TXT_YOUR_PERSONAL_INFORMATION_WAS_SUCCESSFULLY_UPDATED, _
	TXT_YOUR_PROFILE_COULD_NOT_BE_CREATED

Sub setTxtVOLProfile()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_ACCEPT_AND_CLOSE = "Accepter et fermer"
			TXT_AGE_GROUP = "Groupe d'âge"
			TXT_AGE_GROUP_ADULTS = "Adultes (26-59)"
			TXT_AGE_GROUP_CHILDREN = "Enfants (12 et moins)"
			TXT_AGE_GROUP_OLDER_ADULTS = "Personnes âgées (60 et plus)"
			TXT_AGE_GROUP_YOUNG_ADULTS = "Jeunes adultes (18-25)"
			TXT_AGE_GROUP_YOUTH = "Adolescents (13-17)"
			TXT_AGE_GROUPS = "Groupes d'âge"
			TXT_AGREED_TO_BE_CONTACTED = "A accepté d'être contacté"
			TXT_AGREED_TO_PRIVACY_POLICY = "A accepté la politique de confidentialité"
			TXT_APPLICATION_COUNT = "Nombre de candidatures"
			TXT_APPLICATION_DATE = "Date"
			TXT_APPLICATIONS = "Candidatures"
			TXT_APPLICATIONS_OVER_TIME = "Applications sur la durée"
			TXT_ARE_YOU_SURE_DEACTIVATE_ACCOUNT = "Êtes-vous certain de vouloir désactiver votre compte de profil de bénévole ?"
			TXT_AREA_OF_INTEREST = "Centre d'intérêt :"
			TXT_AREA_OF_INTEREST_ERROR = "Centres d'intérêt n'est pas un ID de liste valide."
			TXT_BLOCK = "Bloquer"
			TXT_BLOCKED = "Bloqué"
			TXT_BY = " par "
			TXT_COMMUNITY_ERROR = "Communautés n'est pas un ID de liste valide."
			TXT_CONFIRM_APPLICATION_HIDE = "Confirmer le cachement de la candidature"
			TXT_CONFIRM_DEACTIVATE_ACCOUNT = "Confirmer la désactivation du compte"
			TXT_CONFIRM_EMAIL_ADDRESS = "confirmer le changement de votre adresse courriel :"
			TXT_CONTACT_INFO = "Coordonnées"
			TXT_COUNT = "Nombre"
			TXT_CREATE_NEW_VOL_PROFILE = "Créer un nouveau profil de bénévole"
			TXT_CREATE_PROFILE = "Créer un profil"
			TXT_CREATE_PROFILE_BENEFITS_1 = "La création d'un profil de bénévole vous permettra de :"
			TXT_CREATE_PROFILE_BENEFITS_2 = "Gagner du temps à chaque nouvelle canditure, en n'ayant pas à resaisir vos informations personnelles ou vérifications de sécurité supplémentaires."
			TXT_CREATE_PROFILE_BENEFITS_3 = "Sauvegarder vos critères de recherche pour des recherches plus simples et plus rapides."
			TXT_CREATE_PROFILE_BENEFITS_4 = "Choisir d'être alerté lorsque des postes correspondant à vos critères de recherche sont ajoutés ou mis à jour."
			TXT_CREATE_VOL_PROFILE = "Créer un profil de bénévole"
			TXT_CREATED_DATE = "Date de création"
			TXT_CRITERIA_DEMOGRAPHICS = "Critères/Démographie"
			TXT_CURRENT_PASSWORD_REQUIRED = "Le mot de passe actuel est un champ obligatoire pour changer son mot de passe."
			TXT_DATE_OF_BIRTH = "Date de naissance"
			TXT_DATE_OF_BIRTH_ERROR = "La date de naissance doit être antérieure à la date d'aujourd'hui ou vide. "
			TXT_DATES_AND_TIMES = "Dates et heures"
			TXT_DEACTIVATE = "Désactiver"
			TXT_DEACTIVATE_ACCOUNT = "Désactiver le compte de profil de bénévole"
			TXT_DEACTIVATE_PROMPT = "Utilisez le lien ci-dessus si vous voulez désactiver votre compte. Pour les paramètres de courriel, consultez votre """"Profil de recherche""""."
			TXT_DID_NOT_SELECT_ANY = " n'ont pas sélectionné de communautés spécifiques."
			TXT_DO_YOU_HAVE_A_PROFILE_ALREADY = "Avez-vous déjà un profil ?"
			TXT_EDIT_OUTCOME = "Modifier le résultat"
			TXT_EMAIL_ADDRESS = "Adresse courriel"
			TXT_EMAIL_MY_NEW_PW = "Envoyer mon nouveau mot de passe par courriel"
			TXT_EMAIL_NOTIFICATIONS = "Notifications par courriel"
			TXT_EMAIL_REQUIRED = "l'adresse courriel est un champ obligatoire."
			TXT_EMAIL_SENT = "Un courriel vous a été envoyé pour confirmer votre nouvelle adresse. Vous devrez cliquer le lien indiqué dans le courriel pour terminer la procédure d'inscription, avant de pouvoir vous connecter."
			TXT_EMAIL_SUBJECT = "Confirmation de la mise à jour du courriel du profil de bénévole"
			TXT_EMAIL_REACTIVATE_SUBJECT = "Confirmation de la réactivation du compte du profil de bénévole"
			TXT_ERROR_EDITING_OUTCOME = "Une erreur est survenue lors de la mise à jour du résultat :"
			TXT_ERROR_UPDATING_PROFILE = "Une erreur est survenue lors de la mise à jour des informations du profil :"
			TXT_FIND_INTERESTS = "Trouver des intérêts"
			TXT_FINISH_CREATING_ACCOUNT = "finir de créer votre compte :"
			TXT_FINISH_REACTIVATING_ACCOUNT = "terminer la réactivation de votre compte :"
			TXT_FIRST_NAME_REQUIRED = "Le Prénom est un champ obligatoire."
			TXT_FORGOT_PASSWORD = "Mot de passe oublié"
			TXT_HI = "Bonjour"
			TXT_I_AGREE_TO_PRIVACY_POLICY_1 = "J'autorise l'utilisation de mes informations"
			TXT_I_AGREE_TO_PRIVACY_POLICY_2 = "tel que mentionné dans la"
			TXT_INST_COMMUNITIES = "A des occasions dans l'une ou plusieurs des communautés suivantes :"
			TXT_INST_CONFIRM_APPLICATION_HIDE = "Vous ne pourrez pas réafficher cette candidature ; êtes-vous certain de vouloir la cacher ?"
			TXT_INST_DATE_OF_BIRTH = "Les correspondances adaptées à votre âge n'ont pas pu être déterminées. (ex. [DATE])"
			TXT_INST_DATES_AND_TIMES_PROFILE = "Limiter aux dossiers ayant <em>l'une ou plusieurs</em> des dates/heures suivantes :"
			TXT_INST_PROFILE_SEARCH = "Utiliser ce formulaire pour rechercher et afficher les détails limités des profils de bénévoles vérifiés, lorsque l'utilisateur du profil a accepté de partager ses informations et d'être contacté."
			TXT_INST_PROFILE_VIEWS = "Il n'y a aucune vue autorisant les profils de bénévoles."
			TXT_INST_RESET_PW = "Les mots de passe ne peuvent être retrouvés. Si vous avez oublié votre mot de passe, vous pouvez utiliser ce formulaire pour en recevoir un nouveau par courriel."
			TXT_INST_UNSUBSCRIBE = "TRANSLATE_FR -- This will unsubscribe [EMAIL] from all volunteer profile emails from this site. You can also <a href=""[LOGIN_URL]"">log in</a> and check your settings on your profile page. Please click the button below to confirm you wish to unsubscribe."
			TXT_INST_UNSUBSCRIBE_STAFF = "Remarque : cela révoquera également l'accord de cet utilisateur d'être contacté (le cas échéant) et ne pourra pas être annulé par le personnel."
			TXT_INTEREST = "Intérêts"
			TXT_INVALID_CT_VALUE = "Le jeton de confirmation fourni n'est plus valide. Les jetons de confirmation expirent après deux semaines et ne peuvent être utilisés qu'une seule fois. " & _
				"Si vous avez utilisé ce lien dans le passé, l'adresse e-mail de votre profil a peut-être déjà été vérifiée avec succès, ce qui signifie que vous pouvez vous connecter normalement."
			TXT_INVALID_PID_VALUE = "L'ID de profil de bénévole indiqué n'est pas valide"
			TXT_LAST_NAME_REQUIRED = "Le nom de famille est un champ obligatoire."
			TXT_LINK_EXPIRE_NOTICE = "Ce lien expirera après la première fois que vous cliquerez dessus, ou dans deux semaines, selon la première éventualité."
			TXT_LIST_APPLICATIONS = "Lister les candidatures"
			TXT_LOGIN_CONFLICT = "Conflit de nom d'utilisateur"
			TXT_LOGIN_NOW = "Se connecter maintenant !"
			TXT_LOGOUT_BEFORE_CREATE = "Vous devez d'abord vous déconnecter avant de créer un nouveau profil."
			TXT_MAY_REVIEW_MY_SEARCHING_PROFILE = "peut consulter mon profil de recherche et me contacter au sujet d'occasions potentielles."
			TXT_MY_APPLICATIONS = "Mes demandes"
			TXT_MY_PERSONAL_INFO = "Mes informations personnelles"
			TXT_MY_SEARCH_PROFILE = "Mon profil de recherche"
			TXT_NEW_VP = "Nouveau"
			TXT_NO_COMMUNITIES_HAVE_BEEN_SELECTED = "Aucune communauté n'a été sélectionnée par les utilisateurs du profil"
			TXT_NO_INTERESTS_HAVE_BEEN_SELECTED = "Aucun centre d'intérêt n'a été sélectionné par les utilisateurs du Profil"
			TXT_NO_VOL_PROFILE_EMAIL = "Aucun courriel de profil n'a été sélectionné."
			TXT_NO_VOL_PROFILES = "Il n'y a pas de profil de bénévole."
			TXT_NONE_SPECIFIED = """-- Non précisé --"
			TXT_NOTIFY_ME_NEW = "M'avertir lorsqu'il y a de nouvelles occasions correspondant à mes critères."
			TXT_NOTIFY_ME_UPDATED = "M'avertir lorsque des occasions correspondant à mes critères sont mises à jour."
			TXT_OF_UC = "Sur "
			TXT_OF_YOUR_CIOC_LOGIN = "avec votre nom d'utilisateur CIOC avant d'accéder à la section des profils de bénévoles du site."
			TXT_OUTCOME = "Résultat"
			TXT_PASSWORD_NOT_SECURE_VP = "Le mot de passe n'est pas sécurisé."
			TXT_PASSWORD_REQUIRED_VP = "Le Mot de passe est un champ obligatoire."
			TXT_PASSWORDS_MUST_MATCH_VP = "Le mot de passe et la confirmation du mot de passe doivent correspondre."
			TXT_PERSONAL_INFO = "Informations personnelles"
			TXT_PLEASE_FOLLOW_LINK = "Veuillez cliquer le lien ci-dessous pour"
			TXT_PREFERRED_LANGUAGE = "Je préfère recevoir les communications par"
			TXT_PRIVACY_POLICY = "Politique de confidentialité"
			TXT_PROFILE_COUNT = "Compte du profil"
			TXT_PROFILE_COUNT_ACTIVE = "Profils actifs"
			TXT_PROFILE_COUNT_AGREE_CONTACT = "A accepté d'être contacté"
			TXT_PROFILE_COUNT_AGREE_PRIVACY = "A accepté les termes de la politique de confidentialité"
			TXT_PROFILE_COUNT_RECEIVE_NEW = "Recevoir la notification sur les '""Nouveautés""'"
			TXT_PROFILE_COUNT_RECEIVE_UPDATED = "Recevoir la notification sur les '""Mises à jour'"""
			TXT_PROFILE_COUNT_TOTAL = "Total des profils"
			TXT_PROFILE_COUNT_VERIFIED = "Profils vérifiés"
			TXT_PROFILE_COUNTS = "Comptages généraux des profils"
			TXT_PROFILE_SEARCH = "Recherche sur les profils"
			TXT_PROFILE_VIEWS = "Vues des profils"
			TXT_PROFILE_WAS = "Le profil était"
			TXT_PROFILES_OVER_TIME = "Profils sur la durée"
			TXT_REACTIVATE_ACCOUNT = "Réactiver le compte"
			TXT_RECEIVES_NEW_NOTIFICATIONS = "Recevoir les notifications sur les '""Nouveautés""'"
			TXT_RECEIVES_UPDATED_NOTIFICATIONS = "Recevoir les notifications sur les '""Mises à jour'"""
			TXT_REMEMBER_WORKS_WITH_ALL_SITES = "N'oubliez pas, votre profil fonctionne sur tous ces sites (vous pourriez devoir vous connecter de nouveau) :"
			TXT_REMOVE_ALL = "Supprimer tout"
			TXT_RETURN_TO_PROFILE_PAGE = "Retourner à la page de profil"
			TXT_SEARCH_NOW = "Rechercher maintenant"
			TXT_SEARCH_PROFILE = "Rechercher les Profils"
			TXT_SELECTED_INTERESTS = "Intérêts sélectionnés"
			TXT_SET_DATE_RANGE = "Définir une période"
			TXT_SINCE = "Depuis "
			TXT_START_A_NEW = "Commencer une nouvelle "
			TXT_SUBSCRIPTIONS = "Abonnements par courriel"
			TXT_SUBSCRIPTIONS_NEW = "TRANSLATE_FR -- This profile is receiving notifications for new opportunities by email."
			TXT_SUBSCRIPTIONS_NEW_AND_UPDATED = "TRANSLATE_FR -- This profile is receiving notifications for new and update opportunities by email."
			TXT_SUBSCRIPTIONS_NONE = "TRANSLATE_FR -- This profile is not receiving notifications of opportunities by email."
			TXT_SUCCESS_CREATE = "Votre profil de bénévole a été créé avec succès."
			TXT_SUCCESS_CRITERIA = "Vos critéres de recherche ont été mis à jour avec succès."
			TXT_SUCCESS_DEACTIVATE = "Votre compte a été désactivé."
			TXT_SUCCESS_REACTIVATE = "Votre profil de bénévole a été réactivé avec succès."
			TXT_SUCCESS_UPDATE = "Vos informations personnelles ont été mises à jour avec succès."
			TXT_SUCCESSFUL = "Réussi"
			TXT_THE_PROFILE_ID = "l'ID du profil"
			TXT_THE_VOLUNTEER_CENTRE = "Le centre de bénévolat"
			TXT_THERE_WERE_VALIDIATION_ERRORS = "Il y a des erreurs de validation :"
			TXT_TOGGLE_DISPLAY_ALL = "Activer/Désactiver afficher tout"
			TXT_TOTAL_PROFILES = " profils au total, "
			TXT_UNBLOCK = "Bloqué"
			TXT_UNBLOCKED = "Débloqué"
			TXT_UNSUBSCRIBE = "Se désabonner"
			TXT_UNSUBSCRIBE_ME = "Désabonnez-moi"
			TXT_UNSUBSCRIBE_SOMETHING_WENT_WRONG = "TRANSLATE_FR -- Something didn't work when attempting to unsubscribe you. Please check your unsubscribe link and try again or <a href=""[LOGIN_URL]"">log in</a> and check your delivery settings."
			TXT_UNSUBSCRIBE_SUCCESSFUL = "TRANSLATE_FR -- You were successfully unsubscribed."
			TXT_UNSUBSCRIBED = "Désabonné"
			TXT_UNSUCCESSFUL = "Sans succès"
			TXT_UPDATE_VOL_PROFILE_INFO = "Mettre à jour les Informations du profil de bénévole"
			TXT_UPDATE_VOL_PROFILE_CRITERIA = "Mettre à jour les Critères de recherche sur les profils de bénévole"
			TXT_USE_MY_SAVED_SEARCH_PROFILE = "Utiliser mon profil enregistré"
			TXT_USER_NOT_AGREED_TO_CONTACT = "Cet utilisateur n'a pas accepté d'être contacté."
			TXT_USERS_WITH_A_PROFILE = "Utilisateurs avec un profil"
			TXT_USERS_WITHOUT_A_PROFILE = "Utilisateurs sans profil"
			TXT_VIEW_NAME = "Afficher le nom"
			TXT_VIEW_NUMBER = "No de vue"
			TXT_VIEW_OR_UPDATE = "Afficher ou mettre à jour"
			TXT_VIEWS_ALLOW_PROFILES = "Les vues publiques suivantes sont configurées pour autoriser les profils de bénévoles :"
			TXT_VOL_PROFILE_CONFIRMATION = "Confirmation du profil du bénévole"
			TXT_VOL_PROFILE_DETAILS = "Détails du profil du bénévole"
			TXT_VOL_PROFILE_LOGIN = "Nom d'utilisateur du profil du bénévole"
			TXT_VOL_PROFILE_PASSWORD_RESET = "Réinitialisation du mot de passe du profil du bénévole"
			TXT_VOL_PROFILE_PRIVACY_POLICY = "Politique de confidentialité du profil du bénévole"
			TXT_VOL_PROFILE_SEARCH_RESULTS = "Résultats de recherche sur les profils de bénévole"
			TXT_VOL_PROFILE_SUMMARY = "Résumé du profil de bénévole"
			TXT_VOL_PROFILE_UNSUBSCRIBE = "TRANSLATE_FR -- Volunteer Profile Unsubscribe"
			TXT_VOLUNTEER_PROFILE = "Profil du bénévole"
			TXT_WELCOME = "Bienvenue,"
			TXT_WOULD_YOU_LIKE_TO_REACTIVATE = "Souhaitez-vous réactiver votre compte ?"
			TXT_YEAR = "Année"
			TXT_YOU_HAVE_BEEN_SENT_PASSWORD = "Un courriel avec votre nouveau mot de passe vous a été envoyé."
			TXT_YOU_MUST_FIRST = "Vous devez d'abord"
			TXT_YOU_REQUESTED_PW_RESET = "Vous venez de demander un nouveau mot de passe pour votre profil sur"
			TXT_YOU_REQUESTED_REACTIVATION = "Vous avez récemment réactivé votre compte de profil de bénévole sur notre base de données des occasions de bénévolat, sur"
			TXT_YOU_SIGNED_UP_FOR = "Vous venez de vous inscrire pour un compte Profil de bénévole sur notre base de données des occasions de bénévolat, sur"
			TXT_YOU_SUBMITTED_EMAIL_CHANGE = "Vous venez de soumettre une demande de changement de courriel pour votre profil de bénévole dans notre base de données, sur"
			TXT_YOUR_ACCOUNT_REACTIVATED = "Votre compte a été réactivé. Veuillez vous connecter en utilisant le formulaire ci-dessous."
			TXT_YOUR_EMAIL_CONFIRMED = "Votre adresse courriel a été confirmée."
			TXT_YOUR_EMAIL_PLEASE_SIGN_IN = "Votre adresse courriel a été confirmée. Veuillez vous connecter en utilisant le formulaire ci-dessous."
			TXT_YOUR_NEW_PASSWORD_IS = "Votre nouveau mot de passe est :"
			TXT_YOUR_PASSWORD_COULD_NOT_BE_RESET = "Votre mot de passe n'a pu être réinitialisé :"
			TXT_YOUR_PASSWORD_IS_RESET = "Votre mot de passe a été réinitialisé."
			TXT_YOUR_PROFILE_COULD_NOT_BE_REACTIVATED = "Votre profil n'a pu être réactivé : "
			TXT_YOUR_PERSONAL_INFORMATION_WAS_SUCCESSFULLY_UPDATED = "Vos informations personnelles ont été mises à jour avec succès."
			TXT_YOUR_PROFILE_COULD_NOT_BE_CREATED = "Votre profil n'a pu être créé :"
		Case Else
			TXT_ACCEPT_AND_CLOSE = "Accept and Close"
			TXT_AGE_GROUP = "Age Group"
			TXT_AGE_GROUP_ADULTS = "Adults (26-59)"
			TXT_AGE_GROUP_CHILDREN = "Children (12 and under)"
			TXT_AGE_GROUP_OLDER_ADULTS = "Older Adults (60+)"
			TXT_AGE_GROUP_YOUNG_ADULTS = "Young Adults (18-25)"
			TXT_AGE_GROUP_YOUTH = "Youth (13-17)"
			TXT_AGE_GROUPS = "Age Groups"
			TXT_AGREED_TO_BE_CONTACTED = "Agreed to be Contacted"
			TXT_AGREED_TO_PRIVACY_POLICY = "Agreed to the Privacy Policy"
			TXT_APPLICATION_COUNT = "Application Count"
			TXT_APPLICATION_DATE = "Date"
			TXT_APPLICATIONS = "Applications"
			TXT_APPLICATIONS_OVER_TIME = "Applications over Time"
			TXT_ARE_YOU_SURE_DEACTIVATE_ACCOUNT = "Are you sure you want to deactivate your Volunteer Profile account?"
			TXT_AREA_OF_INTEREST = "Area of Interest:"
			TXT_AREA_OF_INTEREST_ERROR = "Areas of Interest is not a valid ID List."
			TXT_BLOCK = "Block"
			TXT_BLOCKED = "Blocked"
			TXT_BY = " by "
			TXT_COMMUNITY_ERROR = "Communities is not a valid ID List."
			TXT_CONFIRM_APPLICATION_HIDE = "Confirm Application Hide"
			TXT_CONFIRM_DEACTIVATE_ACCOUNT = "Confirm Account Deactivation"
			TXT_CONFIRM_EMAIL_ADDRESS = "confirm your Email address change" & TXT_COLON
			TXT_CONTACT_INFO = "Contact Info"
			TXT_COUNT = "Count"
			TXT_CREATE_NEW_VOL_PROFILE = "Create a New Volunteer Profile"
			TXT_CREATE_PROFILE = "Create Profile"
			TXT_CREATE_PROFILE_BENEFITS_1 = "Creating a Volunteer Profile will allow you to:"
			TXT_CREATE_PROFILE_BENEFITS_2 = "Save time applying for positions, by not having to enter in personal details with every application or enter in extra security checks."
			TXT_CREATE_PROFILE_BENEFITS_3 = "Save your search criteria for faster, simpler searches."
			TXT_CREATE_PROFILE_BENEFITS_4 = "Have the option to be notified when there are new or updated positions matching your search criteria."
			TXT_CREATE_VOL_PROFILE = "Create Volunteer Profile"
			TXT_CREATED_DATE = "Created Date"
			TXT_CRITERIA_DEMOGRAPHICS = "Criteria / Demographics"
			TXT_CURRENT_PASSWORD_REQUIRED = "You must supply your current password when changing your password."
			TXT_DATE_OF_BIRTH = "Date of Birth"
			TXT_DATE_OF_BIRTH_ERROR = "Date of Birth must be before today or empty."
			TXT_DATES_AND_TIMES = "Dates and Times"
			TXT_DEACTIVATE = "Deactivate"
			TXT_DEACTIVATE_ACCOUNT = "Deactivate Volunteer Profile Account"
			TXT_DEACTIVATE_PROMPT = "Use the above link if you would like to deactivate your account. For Email settings see your ""Search Profile""."
			TXT_DID_NOT_SELECT_ANY = " did not select any specific communities."
			TXT_DO_YOU_HAVE_A_PROFILE_ALREADY = "Do you already have a Profile?"
			TXT_EDIT_OUTCOME = "Edit Outcome"
			TXT_EMAIL_ADDRESS = "Email Address"
			TXT_EMAIL_MY_NEW_PW = "Email My New Password"
			TXT_EMAIL_NOTIFICATIONS = "Email Notifications"
			TXT_EMAIL_REQUIRED = "Email Address is a required field."
			TXT_EMAIL_SENT = "You have been sent an Email message to confirm your Email address. You will need to click the link provided in the Email to complete the registration process before you can log in."
			TXT_EMAIL_SUBJECT = "Volunteer Profile Email update confirmation"
			TXT_EMAIL_REACTIVATE_SUBJECT = "Volunteer Profile account reactivation confirmation"
			TXT_ERROR_EDITING_OUTCOME = "Error editing outcome" & TXT_COLON
			TXT_ERROR_UPDATING_PROFILE = "Error updating profile information" & TXT_COLON
			TXT_FIND_INTERESTS = "Find Interests"
			TXT_FINISH_CREATING_ACCOUNT = "finish creating your account" & TXT_COLON
			TXT_FINISH_REACTIVATING_ACCOUNT = "finish reactivating your account:"
			TXT_FIRST_NAME_REQUIRED = "First Name is a required field."
			TXT_FORGOT_PASSWORD = "Forgot Password"
			TXT_HI = "Hi"
			TXT_I_AGREE_TO_PRIVACY_POLICY_1 = "I agree to allow my information to be used"
			TXT_I_AGREE_TO_PRIVACY_POLICY_2 = "as specified in the"
			TXT_INST_COMMUNITIES = "Has opportunities in any of the following communities:"
			TXT_INST_CONFIRM_APPLICATION_HIDE = "You will not be able to restore this application once it is hidden; are you sure that you want to hide it?"
			TXT_INST_DATE_OF_BIRTH = "Used to determine matches suitable for your age. (ex. [DATE])"
			TXT_INST_DATES_AND_TIMES_PROFILE = "Confine to opportunities having <em>any</em> of the following dates/times:"
			TXT_INST_PROFILE_SEARCH = "Use this form to search and display limited details of verified Volunteer Profiles where the Profile user has agreed to share their information and be contacted."
			TXT_INST_PROFILE_VIEWS = "There are no Views allowing Volunteer Profiles."
			TXT_INST_RESET_PW = "It is not possible to retrieve passwords. If you have forgotten your password, you can use this form to have a new one sent to you via Email."
			TXT_INST_UNSUBSCRIBE = "This will unsubscribe [EMAIL] from all Volunteer Profile emails from this site. You can also <a href=""[LOGIN_URL]"">log in</a> and check your settings on your profile page. Please click the button below to confirm that you wish to unsubscribe."
			TXT_INST_UNSUBSCRIBE_STAFF = "Note: this will also revoke this user's agreement to be contacted (if applicable), and cannot be undone by staff."
			TXT_INTEREST = "Interest"
			TXT_INVALID_CT_VALUE = "The confirmation token provided is no longer valid. Confirmation tokens expire after two weeks, and may be used only once. " & _
				"If you have used this link in the past, the email for your Profile may have already been successfully verified, which means you may log in normally."
			TXT_INVALID_PID_VALUE = "The Volunteer Profile ID given is not valid"
			TXT_LAST_NAME_REQUIRED = "Last Name is a required field."
			TXT_LINK_EXPIRE_NOTICE = "The link will expire after the first time that you click on it, or in two weeks, whichever comes first."
			TXT_LIST_APPLICATIONS = "List Applications"
			TXT_LOGIN_CONFLICT = "Login Conflict"
			TXT_LOGIN_NOW = "Login now!"
			TXT_LOGOUT_BEFORE_CREATE = "You must first log out before creating a new profile."
			TXT_MAY_REVIEW_MY_SEARCHING_PROFILE = "may review my searching profile and contact me about potential opportunities."
			TXT_MY_APPLICATIONS = "My Applications"
			TXT_MY_PERSONAL_INFO = "My Personal Info"
			TXT_MY_SEARCH_PROFILE = "My Search Profile"
			TXT_NEW_VP = "New"
			TXT_NO_COMMUNITIES_HAVE_BEEN_SELECTED = "No Communities have been selected by Profile users"
			TXT_NO_INTERESTS_HAVE_BEEN_SELECTED = "No Areas of Interest have been selected by Profile users"
			TXT_NO_VOL_PROFILE_EMAIL = "No Volunteer Profile Email was provided."
			TXT_NO_VOL_PROFILES = "There are no Volunteer Profiles."
			TXT_NONE_SPECIFIED = "-- None Specified --"
			TXT_NOTIFY_ME_NEW = "Notify me when there are new Opportunities that match my criteria. "
			TXT_NOTIFY_ME_UPDATED = "Notify me when Opportunities that match my criteria are updated."
			TXT_OF_UC = "Of "
			TXT_OF_YOUR_CIOC_LOGIN = "of your CIOC login before accessing the Volunteer Profiles section of the site."
			TXT_OUTCOME = "Outcome"
			TXT_PASSWORD_NOT_SECURE_VP = "Password is not secure."
			TXT_PASSWORD_REQUIRED_VP = "Password is a required field."
			TXT_PASSWORDS_MUST_MATCH_VP = "Password and Confirm Password fields must match."
			TXT_PERSONAL_INFO = "Personal Info"
			TXT_PLEASE_FOLLOW_LINK = "Please follow the link below to"
			TXT_PREFERRED_LANGUAGE = "I prefer to receive communications in"
			TXT_PRIVACY_POLICY = "Privacy Policy"
			TXT_PROFILE_COUNT = "Profile Count"
			TXT_PROFILE_COUNT_ACTIVE = "Active Profiles"
			TXT_PROFILE_COUNT_AGREE_CONTACT = "Agreed to be Contacted"
			TXT_PROFILE_COUNT_AGREE_PRIVACY = "Agreed to the Privacy Policy"
			TXT_PROFILE_COUNT_RECEIVE_NEW = "Receive ""New"" Notification"
			TXT_PROFILE_COUNT_RECEIVE_UPDATED = "Receive ""Updated"" Notification"
			TXT_PROFILE_COUNT_TOTAL = "Total Profiles"
			TXT_PROFILE_COUNT_VERIFIED = "Verified Profiles"
			TXT_PROFILE_COUNTS = "General Profile Counts"
			TXT_PROFILE_SEARCH = "Profile Search"
			TXT_PROFILE_VIEWS = "Profile Views"
			TXT_PROFILE_WAS = "Profile was "
			TXT_PROFILES_OVER_TIME = "Profiles Over Time"
			TXT_REACTIVATE_ACCOUNT = "Reactivate Account"
			TXT_RECEIVES_NEW_NOTIFICATIONS = "Receives ""New"" Notifications"
			TXT_RECEIVES_UPDATED_NOTIFICATIONS = "Receives ""Updated"" Notifications"
			TXT_REMEMBER_WORKS_WITH_ALL_SITES = "Remember, your profile works with all of these sites (you may need to sign in again):"
			TXT_REMOVE_ALL = "Remove All"
			TXT_RETURN_TO_PROFILE_PAGE = "Return to Profile Page"
			TXT_SEARCH_NOW = "Search Now"
			TXT_SEARCH_PROFILE = "Search Profile"
			TXT_SELECTED_INTERESTS = "Selected Interests"
			TXT_SET_DATE_RANGE = "Set Date Range"
			TXT_SINCE = "Since "
			TXT_START_A_NEW = "Start a new "
			TXT_SUBSCRIPTIONS = "Email Subscriptions"
			TXT_SUBSCRIPTIONS_NEW = "This profile is receiving notifications for new opportunities by email."
			TXT_SUBSCRIPTIONS_NEW_AND_UPDATED = "This profile is receiving notifications for new and update opportunities by email."
			TXT_SUBSCRIPTIONS_NONE = "This profile is not receiving notifications of opportunities by email."
			TXT_SUCCESS_CREATE = "Your Volunteer Profile was successfully created."
			TXT_SUCCESS_CRITERIA = "Your search criteria was successfully updated."
			TXT_SUCCESS_DEACTIVATE = "Your account has been deactivated."
			TXT_SUCCESS_REACTIVATE = "Your Volunteer profile was successfully reactivated."
			TXT_SUCCESS_UPDATE = "Your personal information was successfully updated."
			TXT_SUCCESSFUL = "Successful"
			TXT_THE_PROFILE_ID = "the Profile ID"
			TXT_THE_VOLUNTEER_CENTRE = "The Volunteer Centre"
			TXT_THERE_WERE_VALIDIATION_ERRORS = "There were validation errors" & TXT_COLON
			TXT_TOGGLE_DISPLAY_ALL = "Toggle Display All"
			TXT_TOTAL_PROFILES = " total Profiles, "
			TXT_UNBLOCK = "Unblock"
			TXT_UNBLOCKED = "Unblocked"
			TXT_UNSUBSCRIBE = "Unsubscribe"
			TXT_UNSUBSCRIBE_ME = "Unsubscribe Me"
			TXT_UNSUBSCRIBE_SOMETHING_WENT_WRONG = "Something didn't work when attempting to unsubscribe your email. Please check your unsubscribe link and try again or <a href=""[LOGIN_URL]"">log in</a> and check your delivery settings."
			TXT_UNSUBSCRIBE_SUCCESSFUL = "You were successfully unsubscribed."
			TXT_UNSUBSCRIBED = "Unsubscribed"
			TXT_UNSUCCESSFUL = "Unsuccessful"
			TXT_UPDATE_VOL_PROFILE_INFO = "Update Volunteer Profile Info"
			TXT_UPDATE_VOL_PROFILE_CRITERIA = "Update Volunteer Profile Search Criteria"
			TXT_USE_MY_SAVED_SEARCH_PROFILE = "Use my saved Search Profile"
			TXT_USER_NOT_AGREED_TO_CONTACT = "This User has not agreed to be contacted."
			TXT_USERS_WITH_A_PROFILE = "Users with a Profile"
			TXT_USERS_WITHOUT_A_PROFILE = "Users without a Profile"
			TXT_VIEW_NAME = "View Name"
			TXT_VIEW_NUMBER = "View #"
			TXT_VIEW_OR_UPDATE = "View or Update"
			TXT_VIEWS_ALLOW_PROFILES = "The following public Views are set to allow Volunteer Profiles" & TXT_COLON
			TXT_VOL_PROFILE_CONFIRMATION = "Volunteer Profile Confirmation"
			TXT_VOL_PROFILE_DETAILS = "Volunteer Profile Details"
			TXT_VOL_PROFILE_LOGIN = "Volunteer Profile Login"
			TXT_VOL_PROFILE_PASSWORD_RESET = "Volunteer Profile Password Reset"
			TXT_VOL_PROFILE_PRIVACY_POLICY = "Volunteer Profile Privacy Policy"
			TXT_VOL_PROFILE_SEARCH_RESULTS = "Volunteer Profile Search Results"
			TXT_VOL_PROFILE_SUMMARY = "Volunteer Profile Summary"
			TXT_VOL_PROFILE_UNSUBSCRIBE = "Volunteer Profile Unsubscribe"
			TXT_VOLUNTEER_PROFILE = "Volunteer Profile"
			TXT_WELCOME = "Welcome,"
			TXT_WOULD_YOU_LIKE_TO_REACTIVATE = "Would you like to reactivate your account?"
			TXT_YEAR = "Year"
			TXT_YOU_HAVE_BEEN_SENT_PASSWORD = "You have been sent an Email with your new password."
			TXT_YOU_MUST_FIRST = "You must first"
			TXT_YOU_REQUESTED_PW_RESET = "You recently requested a new password for your profile on"
			TXT_YOU_SIGNED_UP_FOR = "You recently signed up for a Volunteer Profile account for our Volunteer Opportunities database, located at"
			TXT_YOU_REQUESTED_REACTIVATION = "You recently reactivated your Volunteer Profile account for our Volunteer Opportunities database, located at"
			TXT_YOU_SIGNED_UP_FOR = "You recently signed up for a Volunteer Profile account for our Volunteer Opportunities database, located at"
			TXT_YOU_SUBMITTED_EMAIL_CHANGE = "You recently submitted a change Email request for your Volunteer Profile in our database, located at"
			TXT_YOUR_ACCOUNT_REACTIVATED = "Your account has been reactivated. Please sign in using the form below."
			TXT_YOUR_EMAIL_CONFIRMED = "Your Email address has been confirmed."
			TXT_YOUR_EMAIL_PLEASE_SIGN_IN = "Your Email address has been confirmed. Please sign in using the form below."
			TXT_YOUR_NEW_PASSWORD_IS = "Your new password is" & TXT_COLON
			TXT_YOUR_PASSWORD_COULD_NOT_BE_RESET = "Your password could not be reset" & TXT_COLON
			TXT_YOUR_PASSWORD_IS_RESET = "Your password has been reset."
			TXT_YOUR_PROFILE_COULD_NOT_BE_REACTIVATED = "Your profile could not be reactivated: "
			TXT_YOUR_PERSONAL_INFORMATION_WAS_SUCCESSFULLY_UPDATED = "Your personal information was successfully updated."
			TXT_YOUR_PROFILE_COULD_NOT_BE_CREATED = "Your profile could not be created" & TXT_COLON
	End Select
End Sub

Call setTxtVOLProfile()
%>
