// All texts of the app, in English and French. Embedded: no network is needed.
// In protocol texts ("ind.<code>.critical"), steps are separated by "|".
 
String translate(String lang, String key, [List<Object> args = const []]) {
  var s = (lang == 'fr' ? kFr[key] : null) ?? kEn[key] ?? key;
  for (var i = 0; i < args.length; i++) {
    s = s.replaceAll('{$i}', '${args[i]}');
  }
  return s;
}
 
const Map<String, String> kEn = {
  "nav.home": "Home",
  "nav.alerts": "Alerts",
  "nav.settings": "Settings",
  "level.nominal": "Nominal",
  "level.attention": "Attention",
  "level.critical": "Critical",
  "level.nodata": "No data",
  "status.active": "Active",
  "status.acknowledged": "Acknowledged",
  "status.resolved": "Resolved",
  "cause.threshold": "The value is outside its reference range.",
  "cause.trend": "The value is far from your own usual values.",
  "cause.synergy": "Two indicators are degraded at the same time.",
  "env.spacecraft": "Spacecraft (transit)",
  "env.station": "Space station",
  "env.rover": "Rover",
  "env.lunarBase": "Lunar base",
  "env.marsBase": "Mars base",
  "haz.radiation.name": "Radiation",
  "haz.isolation.name": "Isolation and confinement",
  "haz.distance.name": "Distance from Earth",
  "haz.gravity.name": "Gravity fields",
  "haz.environment.name": "Hostile closed environment",
  "login.in": "Sign in",
  "login.up": "Create account",
  "login.email": "Email",
  "login.password": "Password",
  "login.name": "Full name",
  "login.role": "Role in the crew",
  "login.submit.in": "Sign in",
  "login.submit.up": "Create my account",
  "login.info":
      "Sign in before the mission, while the internet is available. "
      "In space, the app works without any connection.",
  "login.required": "Fill in every field.",
  "login.pwshort": "The password needs at least 6 characters.",
  "err.NETWORK": "No internet connection. Signing in needs the internet.",
  "err.NOT_CONFIGURED": "The online database is not configured (file lib/config.dart).",
  "err.USER_ALREADY_EXISTS": "An account already uses this email.",
  "err.INVALID_CREDENTIALS": "Wrong email or password.",
  "err.WEAK_PASSWORD": "The password needs at least 6 characters.",
  "err.EMAIL_ADDRESS_INVALID": "This email address is not accepted.",
  "err.VALIDATION_FAILED": "This email address is not valid.",
  "err.EMAIL_NOT_CONFIRMED": "This account must be confirmed by email first.",
  "err.OVER_REQUEST_RATE_LIMIT": "Too many attempts. Wait one minute and try again.",
  "err.PERMISSION_DENIED": "Access refused by the online database.",
  "err.TABLE_MISSING": "The online tables are missing. Run supabase/schema.sql.",
  "err.generic": "Something went wrong ({0}). Try again.",
  "home.hello": "Hello, {0}",
  "home.overall": "Overall status",
  "home.nodata": "Not measured yet",
  "home.start": "Record your first measurement to see your status.",
  "home.combined": "Combined risk",
  "home.add": "Add measurement",
  "sync.title": "Online backup",
  "sync.ok": "All data is saved online.",
  "sync.pending":
      "{0} item(s) kept on this device. They will be sent when the internet "
      "is back.",
  "sync.running": "Sending...",
  "sync.now": "Send now",
  "sync.last": "Last backup: {0}",
  "sync.failed": "The online database cannot be reached right now.",
  "add.title": "New measurement",
  "add.indicator": "Indicator",
  "add.value": "Value",

  "add.save": "Save",
  "add.cancel": "Cancel",
  "add.invalid": "Enter a number between {0} and {1}.",
  "add.how": "How to measure",
  "add.saved": "{0} recorded: {1}",
  "add.view": "View alert",
  "add.score.hint": "1 = very low, 5 = very good",
  "ind.last": "Last value",
  "ind.trend": "Evolution over time",
  "ind.range": "Reference range",
  "ind.what": "What it means",
  "ind.how": "How to measure",
  "ind.space": "In space",
  "ind.history": "History",
  "ind.needTwo": "Record at least two measurements to see the curve.",
  "ind.measure": "Measure",
  "range.nominal": "Nominal: {0} to {1} {2}",
  "range.note": "Indicative values for healthy adults on Earth.",
  "alerts.none": "No alert.",
  "alerts.open": "Open alerts",
  "alerts.past": "Resolved alerts",
  "alert.value": "Measured value",
  "alert.cause": "Why this alert",
  "alert.reco": "Recommended actions",
  "alert.protocol": "Emergency protocol",
  "alert.ack": "Actions done: acknowledge",
  "alert.acked": "Alert acknowledged. Take a control measurement.",
  "alert.control": "Take a control measurement",
  "alert.ground": "Mention it in your next report to the flight surgeons.",
  "settings.profile": "My profile",
  "settings.language": "Language",
  "settings.theme": "Dark theme",
  "settings.environment": "Mission environment",
  "settings.logout": "Sign out",
  "settings.logout.warn": "Signing in again needs the internet. Do not sign out in space.",
  "settings.logout.pending": "{0} item(s) are not saved online yet.",
  "report.title": "Health report",
  "report.button": "Create the PDF report",
  "report.hint":
      "The PDF is created on this device, without the internet. Send it to the "
      "ground through the usual channel.",
  "report.generated": "Generated",
  "report.astronaut": "Astronaut",
  "report.account": "Account",
  "report.failed": "The report could not be shared.",
  "about.title": "About",
  "about.disclaimer":
      "AstroCare is a hackathon prototype. It is not a medical device and "
      "does not replace a physician.",
  "about.resources": "NASA and partner resources",
  "about.team": "Team Falcon Health - NASA Space Apps Challenge 2026",
  "syn.behavior.name": "Low mood and short sleep in isolation",
  "syn.behavior.risk": "Higher risk for behavioral health and performance.",
  "syn.behavior.advice":
      "Talk with a crewmate, plan a private call with family, and keep "
      "a regular sleep schedule.",
  "syn.infection.name": "Abnormal temperature and heart rate",
  "syn.infection.risk": "Possible infection or heat stress in the closed cabin.",
  "syn.infection.advice":
      "Rest, hydrate, limit contact with the crew, and tell the "
      "medical officer now.",
  "ind.heartRate.name": "Heart rate",
  "ind.heartRate.what": "Number of heartbeats per minute at rest.",
  "ind.heartRate.how":
      "Sit still for 5 minutes. Use the pulse oximeter, or count the "
      "pulse at the wrist for 60 seconds.",
  "ind.heartRate.space":
      "In weightlessness the heart works differently and can lose "
      "conditioning.",
  "ind.heartRate.attention":
      "Rest 10 minutes and measure again. Drink water. Avoid effort "
      "until it settles.",
  "ind.heartRate.critical":
      "Stop all activity and stay still.|Tell a crewmate now."
      "|Measure again after 5 minutes.|Follow the medical officer and prepare a report "
      "for the flight surgeons.",
  "ind.temperature.name": "Body temperature",
  "ind.temperature.what": "Temperature of the body, in degrees Celsius.",
  "ind.temperature.how": "Use the thermometer as instructed and stay still until the beep.",
  "ind.temperature.space":
      "Immunity changes in space: a fever can reveal an infection in "
      "the closed cabin.",
  "ind.temperature.attention":
      "Rest, drink water, and measure again in one hour. Limit "

      "contact with the crew.",
  "ind.temperature.critical":
      "Tell the medical officer now.|Rest and hydrate."
      "|Fever: remove layers and cool down. Too cold: warm up with blankets."
      "|Measure every 30 minutes.|Prepare a report for the flight surgeons.",
  "ind.sleepDuration.name": "Sleep",
  "ind.sleepDuration.what": "Hours slept during the last sleep period.",
  "ind.sleepDuration.how":
      "Enter the hours actually slept, not the time spent in the "
      "sleep station.",
  "ind.sleepDuration.space": "No natural day and night, noise and workload shorten sleep.",
  "ind.sleepDuration.attention":
      "Dim the lights one hour before sleep, avoid screens, and "
      "keep a fixed schedule.",
  "ind.sleepDuration.critical":
      "Tell the commander: fatigue is a safety risk."
      "|Postpone critical tasks such as piloting or spacewalks."
      "|Plan a recovery sleep period today.|Mention it in your report to the flight surgeons.",
  "ind.mood.name": "Mood",
  "ind.mood.what": "Your own rating of your mood, from 1 (very low) to 5 (very good).",
  "ind.mood.how": "Answer honestly: how do you feel right now?",
  "ind.mood.space": "Isolation, confinement and distance from family weigh on morale.",
  "ind.mood.attention": "Take a break, do an activity you enjoy, and talk with a crewmate.",
  "ind.mood.critical":
      "Do not stay alone: talk to a crewmate you trust now."
      "|Tell the medical officer.|Ask for a private conference with the ground support team."
      "|Lighten your schedule for today.",
};
 
const Map<String, String> kFr = {
  "nav.home": "Accueil",
  "nav.alerts": "Alertes",
  "nav.settings": "Réglages",
  "level.nominal": "Nominal",
  "level.attention": "Attention",
  "level.critical": "Critique",
  "level.nodata": "Pas de donnée",
  "status.active": "Active",
  "status.acknowledged": "Acquittée",
  "status.resolved": "Résolue",
  "cause.threshold": "La valeur est en dehors de sa plage de référence.",
  "cause.trend": "La valeur s'écarte beaucoup de vos valeurs habituelles.",
  "cause.synergy": "Deux indicateurs sont dégradés en même temps.",
  "env.spacecraft": "Vaisseau (transit)",
  "env.station": "Station spatiale",
  "env.rover": "Rover",
  "env.lunarBase": "Base lunaire",
  "env.marsBase": "Base martienne",
  "haz.radiation.name": "Radiations",
  "haz.isolation.name": "Isolement et confinement",
  "haz.distance.name": "Distance de la Terre",
  "haz.gravity.name": "Champs de gravité",
  "haz.environment.name": "Environnement clos hostile",
  "login.in": "Connexion",
  "login.up": "Créer un compte",
  "login.email": "Adresse e-mail",
  "login.password": "Mot de passe",
  "login.name": "Nom complet",
  "login.role": "Rôle dans l'équipage",
  "login.submit.in": "Se connecter",
  "login.submit.up": "Créer mon compte",
  "login.info":
      "Connectez-vous avant la mission, tant qu'Internet est disponible. "
      "Dans l'espace, l'application fonctionne sans aucune connexion.",
  "login.required": "Remplissez tous les champs.",
  "login.pwshort": "Le mot de passe doit contenir au moins 6 caractères.",
  "err.NETWORK": "Pas de connexion Internet. La connexion au compte en a besoin.",
  "err.NOT_CONFIGURED": "La base en ligne n'est pas configurée (fichier lib/config.dart).",
  "err.USER_ALREADY_EXISTS": "Un compte utilise déjà cette adresse e-mail.",
  "err.INVALID_CREDENTIALS": "Adresse e-mail ou mot de passe incorrect.",
  "err.WEAK_PASSWORD": "Le mot de passe doit contenir au moins 6 caractères.",
  "err.EMAIL_ADDRESS_INVALID": "Cette adresse e-mail n'est pas acceptée.",
  "err.VALIDATION_FAILED": "Cette adresse e-mail n'est pas valide.",
  "err.EMAIL_NOT_CONFIRMED": "Ce compte doit d'abord être confirmé par e-mail.",
  "err.OVER_REQUEST_RATE_LIMIT": "Trop d'essais. Attendez une minute et réessayez.",
  "err.PERMISSION_DENIED": "Accès refusé par la base en ligne.",
  "err.TABLE_MISSING": "Les tables en ligne sont absentes. Exécutez supabase/schema.sql.",
  "err.generic": "Une erreur est survenue ({0}). Réessayez.",
  "home.hello": "Bonjour, {0}",
  "home.overall": "État général",
  "home.nodata": "Pas encore mesuré",
  "home.start": "Enregistrez votre première mesure pour voir votre état.",
  "home.combined": "Risque combiné",
  "home.add": "Ajouter une mesure",

  "sync.title": "Sauvegarde en ligne",
  "sync.ok": "Toutes les données sont sauvegardées en ligne.",
  "sync.pending":
      "{0} élément(s) gardé(s) sur cet appareil. Ils seront envoyés au retour "
      "d'Internet.",
  "sync.running": "Envoi en cours...",
  "sync.now": "Envoyer maintenant",
  "sync.last": "Dernière sauvegarde : {0}",
  "sync.failed": "La base en ligne est injoignable pour le moment.",
  "add.title": "Nouvelle mesure",
  "add.indicator": "Indicateur",
  "add.value": "Valeur",
  "add.save": "Enregistrer",
  "add.cancel": "Annuler",
  "add.invalid": "Saisissez un nombre entre {0} et {1}.",
  "add.how": "Comment mesurer",
  "add.saved": "{0} enregistré : {1}",
  "add.view": "Voir l'alerte",
  "add.score.hint": "1 = très bas, 5 = très bon",
  "ind.last": "Dernière valeur",
  "ind.trend": "Évolution dans le temps",
  "ind.range": "Plage de référence",
  "ind.what": "Ce que cela signifie",
  "ind.how": "Comment mesurer",
  "ind.space": "Dans l'espace",
  "ind.history": "Historique",
  "ind.needTwo": "Enregistrez au moins deux mesures pour voir la courbe.",
  "ind.measure": "Mesurer",
  "range.nominal": "Nominal : de {0} à {1} {2}",
  "range.note": "Valeurs indicatives pour un adulte en bonne santé sur Terre.",
  "alerts.none": "Aucune alerte.",
  "alerts.open": "Alertes ouvertes",
  "alerts.past": "Alertes résolues",
  "alert.value": "Valeur mesurée",
  "alert.cause": "Pourquoi cette alerte",
  "alert.reco": "Actions recommandées",
  "alert.protocol": "Protocole d'urgence",
  "alert.ack": "Actions faites : acquitter",
  "alert.acked": "Alerte acquittée. Faites une mesure de contrôle.",
  "alert.control": "Faire une mesure de contrôle",
  "alert.ground": "Mentionnez-le dans votre prochain rapport aux médecins de vol.",
  "settings.profile": "Mon profil",
  "settings.language": "Langue",
  "settings.theme": "Thème sombre",
  "settings.environment": "Environnement de mission",
  "settings.logout": "Se déconnecter",
  "settings.logout.warn":
      "Se reconnecter demande Internet. Ne vous déconnectez pas dans "
      "l'espace.",
  "settings.logout.pending": "{0} élément(s) ne sont pas encore sauvegardés en ligne.",
  "report.title": "Rapport de santé",
  "report.button": "Créer le rapport PDF",
  "report.hint":
      "Le PDF est créé sur cet appareil, sans Internet. Envoyez-le au sol par "
      "le canal habituel.",
  "report.generated": "Généré le",
  "report.astronaut": "Astronaute",
  "report.account": "Compte",
  "report.failed": "Le rapport n'a pas pu être partagé.",
  "about.title": "À propos",
  "about.disclaimer":
      "AstroCare est un prototype de hackathon. Ce n'est pas un dispositif "
      "médical et il ne remplace pas un médecin.",
  "about.resources": "Ressources de la NASA et de ses partenaires",
  "about.team": "Équipe Falcon Health - NASA Space Apps Challenge 2026",
  "syn.behavior.name": "Humeur basse et sommeil court en isolement",
  "syn.behavior.risk": "Risque accru pour la santé comportementale et la performance.",
  "syn.behavior.advice":
      "Parlez à un coéquipier, prévoyez un appel privé avec la famille "
      "et gardez des horaires de sommeil réguliers.",
  "syn.infection.name": "Température et fréquence cardiaque anormales",
  "syn.infection.risk": "Possible infection ou coup de chaleur dans la cabine fermée.",
  "syn.infection.advice":
      "Reposez-vous, hydratez-vous, limitez les contacts avec "
      "l'équipage et prévenez l'officier médical tout de suite.",
  "ind.heartRate.name": "Fréquence cardiaque",
  "ind.heartRate.what": "Nombre de battements du cœur par minute, au repos.",
  "ind.heartRate.how":
      "Restez immobile 5 minutes. Utilisez l'oxymètre, ou comptez le "
      "pouls au poignet pendant 60 secondes.",
  "ind.heartRate.space":
      "En apesanteur, le cœur travaille autrement et peut se "
      "déconditionner.",
  "ind.heartRate.attention":

      "Reposez-vous 10 minutes et mesurez à nouveau. Buvez de "
      "l'eau. Évitez l'effort d'ici là.",
  "ind.heartRate.critical":
      "Arrêtez toute activité et restez immobile."
      "|Prévenez un coéquipier tout de suite.|Mesurez à nouveau après 5 minutes."
      "|Suivez l'officier médical et préparez un rapport pour les médecins de vol.",
  "ind.temperature.name": "Température corporelle",
  "ind.temperature.what": "Température du corps, en degrés Celsius.",
  "ind.temperature.how":
      "Utilisez le thermomètre comme indiqué et restez immobile "
      "jusqu'au bip.",
  "ind.temperature.space":
      "L'immunité change dans l'espace : une fièvre peut révéler une "
      "infection dans la cabine fermée.",
  "ind.temperature.attention":
      "Reposez-vous, buvez de l'eau et mesurez à nouveau dans "
      "une heure. Limitez les contacts avec l'équipage.",
  "ind.temperature.critical":
      "Prévenez l'officier médical tout de suite."
      "|Reposez-vous et hydratez-vous."
      "|Fièvre : découvrez-vous et rafraîchissez-vous. Trop froid : réchauffez-vous avec "
      "des couvertures.|Mesurez toutes les 30 minutes."
      "|Préparez un rapport pour les médecins de vol.",
  "ind.sleepDuration.name": "Sommeil",
  "ind.sleepDuration.what": "Heures dormies pendant la dernière période de sommeil.",
  "ind.sleepDuration.how":
      "Saisissez les heures réellement dormies, pas le temps passé "
      "dans la couchette.",
  "ind.sleepDuration.space":
      "L'absence de jour et de nuit naturels, le bruit et la charge "
      "de travail raccourcissent le sommeil.",
  "ind.sleepDuration.attention":
      "Baissez la lumière une heure avant de dormir, évitez les "
      "écrans et gardez un horaire fixe.",
  "ind.sleepDuration.critical":
      "Prévenez le commandant : la fatigue est un risque pour la "
      "sécurité.|Reportez les tâches critiques comme le pilotage ou les sorties."
      "|Prévoyez une période de sommeil de récupération aujourd'hui."
      "|Mentionnez-le dans votre rapport aux médecins de vol.",
  "ind.mood.name": "Humeur",
  "ind.mood.what": "Votre propre note de votre humeur, de 1 (très basse) à 5 (très bonne).",
  "ind.mood.how": "Répondez honnêtement : comment vous sentez-vous maintenant ?",
  "ind.mood.space":
      "L'isolement, le confinement et l'éloignement de la famille pèsent sur "
      "le moral.",
  "ind.mood.attention":
      "Faites une pause, une activité qui vous plaît, et parlez à un "
      "coéquipier.",
  "ind.mood.critical":
      "Ne restez pas seul : parlez tout de suite à un coéquipier de "
      "confiance.|Prévenez l'officier médical."
      "|Demandez une conférence privée avec l'équipe de soutien au sol."
      "|Allégez votre planning d'aujourd'hui.",
};
