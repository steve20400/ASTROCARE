// All texts of the app, in English and French. Embedded: no network is needed.
// In first-aid texts ("aid.<code>.<side>.steps"), steps are separated by "|".
 
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
  "ind.measure": "Measure",
  "range.nominal": "Nominal: {0} to {1} {2}",
  "range.note": "Indicative values for healthy adults on Earth.",
  "alerts.none": "No alert.",
  "alerts.open": "Open alerts",
  "alerts.past": "Resolved alerts",
  "alert.value": "Measured value",
  "alert.cause": "Why this alert",
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
  "report.button": "Share the full PDF report",
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
  "ind.temperature.name": "Body temperature",
  "ind.temperature.what": "Temperature of the body, in degrees Celsius.",
  "ind.temperature.how": "Use the thermometer as instructed and stay still until the beep.",
  "ind.temperature.space":
      "Immunity changes in space: a fever can reveal an infection in "
      "the closed cabin.",
  "ind.sleepDuration.name": "Sleep",
  "ind.sleepDuration.what": "Hours slept during the last sleep period.",
  "ind.sleepDuration.how":
      "Enter the hours actually slept, not the time spent in the "
      "sleep station.",
  "ind.sleepDuration.space": "No natural day and night, noise and workload shorten sleep.",
  "ind.mood.name": "Mood",
  "ind.mood.what": "Your own rating of your mood, from 1 (very low) to 5 (very good).",
  "ind.mood.how": "Answer honestly: how do you feel right now?",
  "ind.mood.space": "Isolation, confinement and distance from family weigh on morale.",
  "alert.reco": "Follow-up",
  "aid.title": "First aid",

  "aid.guide": "First-aid guide",
  "aid.guide.hint": "What to do, step by step. Works without connection.",
  "aid.intro":
      "For each situation the app can detect: the first actions to take, and the "
      "signs that mean you must call the medical officer.",
  "aid.urgent": "Tell the medical officer now if",
  "aid.critical": "Critical value: tell the medical officer now, then follow these steps.",
  "aid.ref": "NASA HRP reference",
  "aid.source":
      "General first-aid actions, linked to the risks listed by the NASA Human "
      "Research Program. They do not replace the medical officer or the flight "
      "surgeons.",
  "aid.generic.steps":
      "Rest for 10 minutes.|Take a control measurement.|If the value stays unusual, "
      "tell the medical officer.",
  "aid.heartRate.high.title": "Fast heart rate at rest",
  "aid.heartRate.high.steps":
      "Stop all effort and stay still.|Breathe slowly for 5 minutes: in for 4 "
      "seconds, out for 6 seconds.|Drink water.|Avoid coffee and other "
      "stimulants.|Measure again after 10 minutes.",
  "aid.heartRate.high.urgent":
      "you have chest pain, shortness of breath, you feel faint, or the rate stays "
      "above 120 bpm after resting.",
  "aid.heartRate.low.title": "Slow heart rate",
  "aid.heartRate.low.steps":
      "Stop the activity and secure yourself.|Check how you feel: dizziness, "
      "weakness, confusion?|Ask a crewmate to stay with you.|Measure again after 5 "
      "minutes.|No symptom at all: a slow rate can be normal for a trained person.",
  "aid.heartRate.low.urgent":
      "you feel dizzy or faint, you have chest pain, or the rate is below 40 bpm.",
  "aid.temperature.high.title": "Fever or overheating",
  "aid.temperature.high.steps":
      "Stop physical work and rest.|Drink water often, in small amounts.|Remove extra "
      "layers and cool the skin with a damp cloth.|Limit contact with the crew and "
      "clean your hands: it may be an infection.|Measure again every 30 minutes.",
  "aid.temperature.high.urgent":
      "the temperature is 38.5 °C or more, you are confused, you have a stiff neck or "
      "trouble breathing, or the fever lasts more than one day.",
  "aid.temperature.low.title": "Low body temperature",
  "aid.temperature.low.steps":
      "Put on dry, warm layers and cover your head.|Have a warm drink.|Move gently to "
      "warm up.|Check the cabin temperature.|Measure again after 30 minutes.",
  "aid.temperature.low.urgent":
      "the temperature is below 35 °C, you shiver strongly, you are confused or your "
      "speech is slurred.",
  "aid.sleepDuration.low.title": "Not enough sleep",
  "aid.sleepDuration.low.steps":
      "Tell your crewmates you are tired before any risky task.|Postpone critical "
      "tasks, or ask a crewmate to double-check your work.|Take a nap of 20 to 30 "
      "minutes.|No coffee in the 6 hours before sleep.|Dim the lights and stop "
      "screens one hour before sleep, and keep fixed hours.",
  "aid.sleepDuration.low.urgent":
      "you slept less than 5 hours for several nights, you fall asleep during tasks, "
      "or you make unusual mistakes.",
  "aid.sleepDuration.high.title": "Unusually long sleep",
  "aid.sleepDuration.high.steps":
      "After a heavy day, a long sleep can simply be recovery.|Check your other "
      "indicators: temperature and mood.|Get bright light and exercise soon after "
      "waking.|Keep fixed hours for sleeping and waking.",
  "aid.sleepDuration.high.urgent":
      "long sleep lasts several days, or comes with a low mood or a fever.",
  "aid.mood.low.title": "Low mood",
  "aid.mood.low.steps":
      "Take a 15-minute break from the task.|Talk with a crewmate you trust.|Do "
      "something you enjoy: music, photos, messages from family, tending the "
      "plants.|Exercise: it improves mood.|Write a few lines in your journal.",
  "aid.mood.low.urgent":
      "your mood is at 1, it stays low for several days, you lose interest in "
      "everything, or you think about harming yourself. Also ask for a private "
      "conference with the ground team.",
  "nav.body": "Body",
  "body.hint": "One finger: turn. Two fingers: zoom and move. Touch a part of the body.",
  "body.spin": "Automatic rotation",
  "body.zoomIn": "Zoom in",
  "body.zoomOut": "Zoom out",
  "body.reset": "Whole body",
  "body.yours": "Your last value",
  "body.details": "Details",
  "body.inSpace": "In space, according to NASA",
  "body.none": "No indicator is tracked for this part of the body in this version.",
  "ref.title": "Health and illness thresholds",
  "ref.range": "{0} to {1}",
  "ref.below": "below {0}",
  "ref.above": "above {0}",

  "ref.or": "or",
  "ref.nominal": "Healthy: {0} {1}",
  "ref.attention": "Watch: {0} {1}",
  "ref.critical": "Critical: {0} {1}",
  "zone.head.name": "Head: sleep and mood",
  "zone.chest.name": "Chest and heart",
  "zone.abdomen.name": "Abdomen: body temperature",
  "zone.arms.name": "Arms: muscles",
  "zone.legs.name": "Legs: bones and muscles",
  "zone.head.nasa":
      "Chronic sleep loss, constant work demands and a disturbed internal clock wear "
      "the crew down. Isolation and the distance from Earth can also weigh on mental "
      "health.",
  "zone.chest.nasa":
      "Weightlessness changes blood circulation and the way the heart and blood "
      "vessels work, which may raise the risk of cardiovascular events.",
  "zone.abdomen.nasa":
      "The stress of spaceflight changes the immune system and can wake up dormant "
      "viruses in the body. An abnormal temperature can be an early sign of "
      "infection.",
  "zone.arms.nasa":
      "Muscles weaken when they no longer carry weight. All astronauts exercise "
      "during their mission to limit the loss of muscle strength.",
  "zone.legs.nasa":
      "Without gravity, bones break down and become more brittle. NASA limits this "
      "with diet, exercise and medication.",
  "period.24h": "24 h",
  "period.7d": "7 days",
  "period.30d": "30 days",
  "period.all": "All",
  "trend.min": "Lowest",
  "trend.avg": "Average",
  "trend.max": "Highest",
  "trend.count": "{0} measurement(s) in this period",
  "trend.none": "No measurement in this period.",
  "tx.title": "Transmission to the ground",
  "tx.open.hint": "Automatic reports and link with the ground. {0} report(s) waiting on board.",
  "tx.link": "Link with the ground",
  "tx.simulated": "Simulated link",
  "tx.space": "Spacecraft",
  "tx.ground": "Ground",
  "tx.linkdown": "Link cut",
  "tx.waiting": "{0} waiting",
  "tx.received": "{0} received",
  "tx.status.down": "Link cut: {0} report(s) stay on board until it comes back.",
  "tx.status.idle": "Link open. Nothing to send.",
  "tx.status.sending": "Sending report {0}. {1}",
  "tx.number": "No. {0}",
  "tx.auto.title": "Automatic report",
  "tx.auto.text":
      "After each measurement the app waits. If no other measurement comes during "
      "that time, it creates a PDF report with the new measurements and the latest "
      "value of each indicator, and puts it in the queue for the ground.",
  "tx.auto.delay": "Waiting time after the last measurement",
  "tx.delay.30": "30 s (demo)",
  "tx.delay.600": "10 min",
  "tx.delay.3600": "1 h",
  "tx.auto.next": "Next report in {0} ({1} new measurement(s))",
  "tx.auto.none": "No new measurement is waiting.",
  "tx.auto.closed":
      "If the app is closed when the time comes, the report is created as soon as it "
      "is opened again.",
  "tx.now": "Create a report now",
  "tx.reports": "Reports",
  "tx.reports.none": "No report yet. Record a measurement.",
  "tx.r.auto": "automatic",
  "tx.r.manual": "manual",
  "tx.r.line": "{0} | {1} new measurement(s) | {2}",
  "tx.r.wait": "Waiting on board",
  "tx.r.sending": "Being sent",
  "tx.r.sent": "Received by the ground: {0} | {1} packets, {2} sent again",
  "tx.kb": "{0} KB",
  "tx.share": "Share this PDF",
  "tx.log": "Protocol log",
  "tx.log.none": "No transfer yet.",
  "tx.ev.md": "Metadata: file {0}, {1} bytes, signature attached",
  "tx.ev.fd": "File Data {0}/{1}: bytes {2} to {3}",
  "tx.ev.lost": "lost on the link",
  "tx.ev.eof": "EOF: end of file, checksum sent",
  "tx.ev.ackeof": "ACK: the ground confirms the EOF",
  "tx.ev.nak": "NAK: the ground asks again for bytes {0} to {1}",
  "tx.ev.refd": "File Data {0}/{1} sent again",
  "tx.ev.fin": "Finished: file complete and valid",
  "tx.ev.finbad": "Finished: file refused",

  "tx.ev.ackfin": "ACK: the spacecraft closes the transfer",
  "tx.log.ok":
      "Ground station: checksum correct, signature valid, report decrypted. "
      "Fingerprint {0}",
  "tx.sec.title": "Protocol and security",
  "tx.sec.cfdp":
      "File transfer: CCSDS File Delivery Protocol, class 2 (CCSDS 727.0-B). It "
      "replaced the older SCPS file protocol. A lost part is asked again, so the file "
      "always arrives whole.",
  "tx.sec.packet":
      "Each message travels in a CCSDS Space Packet (CCSDS 133.0-B) ended by a "
      "CRC-16: a damaged packet is refused.",
  "tx.sec.cipher":
      "The report is encrypted with ChaCha20 before it leaves: it cannot be read on "
      "the link.",
  "tx.sec.sign":
      "It is signed with HMAC-SHA-256 and the mission key: the ground checks who sent "
      "it and that nothing changed.",
  "tx.sec.limit":
      "The radio link is simulated inside the app: the delay is compressed and one "
      "packet is lost on purpose. Sharing the mission key with a real ground station "
      "is not done in this prototype.",
  "tx.pdf.auto":
      "Automatic report: created after the waiting time that follows the last "
      "measurement.",
  "tx.pdf.manual": "Report created by the astronaut.",
  "tx.pdf.new": "New measurements since the last report ({0})",
  "tx.pdf.nonew": "No new measurement.",
  "tx.pdf.latest": "Latest value of each indicator",
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
  "ind.measure": "Mesurer",
  "range.nominal": "Nominal : de {0} à {1} {2}",
  "range.note": "Valeurs indicatives pour un adulte en bonne santé sur Terre.",
  "alerts.none": "Aucune alerte.",
  "alerts.open": "Alertes ouvertes",
  "alerts.past": "Alertes résolues",
  "alert.value": "Valeur mesurée",
  "alert.cause": "Pourquoi cette alerte",
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
  "report.button": "Partager le rapport PDF complet",
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
  "ind.temperature.name": "Température corporelle",
  "ind.temperature.what": "Température du corps, en degrés Celsius.",
  "ind.temperature.how":

      "Utilisez le thermomètre comme indiqué et restez immobile "
      "jusqu'au bip.",
  "ind.temperature.space":
      "L'immunité change dans l'espace : une fièvre peut révéler une "
      "infection dans la cabine fermée.",
  "ind.sleepDuration.name": "Sommeil",
  "ind.sleepDuration.what": "Heures dormies pendant la dernière période de sommeil.",
  "ind.sleepDuration.how":
      "Saisissez les heures réellement dormies, pas le temps passé "
      "dans la couchette.",
  "ind.sleepDuration.space":
      "L'absence de jour et de nuit naturels, le bruit et la charge "
      "de travail raccourcissent le sommeil.",
  "ind.mood.name": "Humeur",
  "ind.mood.what": "Votre propre note de votre humeur, de 1 (très basse) à 5 (très bonne).",
  "ind.mood.how": "Répondez honnêtement : comment vous sentez-vous maintenant ?",
  "ind.mood.space":
      "L'isolement, le confinement et l'éloignement de la famille pèsent sur "
      "le moral.",
  "alert.reco": "Suivi",
  "aid.title": "Premiers secours",
  "aid.guide": "Guide de premiers secours",
  "aid.guide.hint": "Quoi faire, étape par étape. Fonctionne sans connexion.",
  "aid.intro":
      "Pour chaque situation que l'application peut détecter : les premiers gestes à "
      "faire, et les signes qui imposent d'appeler l'officier médical.",
  "aid.urgent": "Prévenez l'officier médical tout de suite si",
  "aid.critical":
      "Valeur critique : prévenez l'officier médical tout de suite, puis suivez ces "
      "étapes.",
  "aid.ref": "Référence NASA HRP",
  "aid.source":
      "Gestes généraux de premiers secours, reliés aux risques listés par le Human "
      "Research Program de la NASA. Ils ne remplacent ni l'officier médical ni les "
      "médecins de vol.",
  "aid.generic.steps":
      "Reposez-vous 10 minutes.|Faites une mesure de contrôle.|Si la valeur reste "
      "inhabituelle, prévenez l'officier médical.",
  "aid.heartRate.high.title": "Cœur rapide au repos",
  "aid.heartRate.high.steps":
      "Arrêtez tout effort et restez immobile.|Respirez lentement pendant 5 minutes : "
      "inspirez 4 secondes, expirez 6 secondes.|Buvez de l'eau.|Évitez le café et les "
      "autres excitants.|Mesurez à nouveau après 10 minutes.",
  "aid.heartRate.high.urgent":
      "vous avez une douleur dans la poitrine, vous êtes essoufflé, vous vous sentez "
      "près de vous évanouir, ou la fréquence reste au-dessus de 120 bpm après le "
      "repos.",
  "aid.heartRate.low.title": "Cœur lent",
  "aid.heartRate.low.steps":
      "Arrêtez l'activité et attachez-vous.|Observez-vous : vertiges, faiblesse, "
      "confusion ?|Demandez à un coéquipier de rester avec vous.|Mesurez à nouveau "
      "après 5 minutes.|Aucun symptôme : un cœur lent peut être normal chez une "
      "personne entraînée.",
  "aid.heartRate.low.urgent":
      "vous avez des vertiges, un malaise, une douleur dans la poitrine, ou la "
      "fréquence est en dessous de 40 bpm.",
  "aid.temperature.high.title": "Fièvre ou coup de chaleur",
  "aid.temperature.high.steps":
      "Arrêtez le travail physique et reposez-vous.|Buvez de l'eau souvent, par "
      "petites quantités.|Enlevez les couches en trop et rafraîchissez la peau avec "
      "un linge humide.|Limitez les contacts avec l'équipage et lavez-vous les mains "
      ": c'est peut-être une infection.|Mesurez à nouveau toutes les 30 minutes.",
  "aid.temperature.high.urgent":
      "la température atteint 38,5 °C ou plus, vous êtes confus, vous avez la nuque "
      "raide ou du mal à respirer, ou la fièvre dure plus d'un jour.",
  "aid.temperature.low.title": "Température du corps basse",
  "aid.temperature.low.steps":
      "Mettez des vêtements secs et chauds et couvrez-vous la tête.|Prenez une "
      "boisson chaude.|Bougez doucement pour vous réchauffer.|Vérifiez la température "
      "de la cabine.|Mesurez à nouveau après 30 minutes.",
  "aid.temperature.low.urgent":
      "la température est en dessous de 35 °C, vous frissonnez fortement, vous êtes "
      "confus ou vous avez du mal à parler.",
  "aid.sleepDuration.low.title": "Manque de sommeil",
  "aid.sleepDuration.low.steps":
      "Dites à vos coéquipiers que vous êtes fatigué avant toute tâche à "
      "risque.|Reportez les tâches critiques, ou demandez à un coéquipier de vérifier "
      "votre travail.|Faites une sieste de 20 à 30 minutes.|Pas de café dans les 6 "
      "heures avant de dormir.|Baissez la lumière et arrêtez les écrans une heure "
      "avant de dormir, et gardez des horaires fixes.",
  "aid.sleepDuration.low.urgent":
      "vous dormez moins de 5 heures depuis plusieurs nuits, vous vous endormez "
      "pendant les tâches, ou vous faites des erreurs inhabituelles.",
  "aid.sleepDuration.high.title": "Sommeil anormalement long",

  "aid.sleepDuration.high.steps":
      "Après une journée lourde, un long sommeil peut être une simple "
      "récupération.|Vérifiez vos autres indicateurs : température et "
      "humeur.|Exposez-vous à une lumière vive et faites de l'exercice peu après le "
      "réveil.|Gardez des heures fixes de coucher et de lever.",
  "aid.sleepDuration.high.urgent":
      "le long sommeil dure plusieurs jours, ou s'accompagne d'une humeur basse ou de "
      "fièvre.",
  "aid.mood.low.title": "Humeur basse",
  "aid.mood.low.steps":
      "Faites une pause de 15 minutes.|Parlez à un coéquipier de confiance.|Faites "
      "une activité qui vous plaît : musique, photos, messages de la famille, soin "
      "des plantes.|Faites de l'exercice : cela améliore l'humeur.|Écrivez quelques "
      "lignes dans votre journal.",
  "aid.mood.low.urgent":
      "votre humeur est à 1, elle reste basse plusieurs jours, vous perdez l'intérêt "
      "pour tout, ou vous pensez à vous faire du mal. Demandez aussi une conférence "
      "privée avec l'équipe au sol.",
  "nav.body": "Corps",
  "body.hint":
      "Un doigt : tourner. Deux doigts : zoomer et déplacer. Touchez une partie du "
      "corps.",
  "body.spin": "Rotation automatique",
  "body.zoomIn": "Zoomer",
  "body.zoomOut": "Dézoomer",
  "body.reset": "Corps entier",
  "body.yours": "Votre dernière valeur",
  "body.details": "Détails",
  "body.inSpace": "Dans l'espace, selon la NASA",
  "body.none": "Aucun indicateur n'est suivi pour cette partie du corps dans cette version.",
  "ref.title": "Seuils de santé et de maladie",
  "ref.range": "de {0} à {1}",
  "ref.below": "moins de {0}",
  "ref.above": "plus de {0}",
  "ref.or": "ou",
  "ref.nominal": "Sain : {0} {1}",
  "ref.attention": "À surveiller : {0} {1}",
  "ref.critical": "Critique : {0} {1}",
  "zone.head.name": "Tête : sommeil et humeur",
  "zone.chest.name": "Thorax et cœur",
  "zone.abdomen.name": "Abdomen : température du corps",
  "zone.arms.name": "Bras : muscles",
  "zone.legs.name": "Jambes : os et muscles",
  "zone.head.nasa":
      "Le manque de sommeil chronique, la charge de travail constante et une horloge "
      "interne déréglée usent l'équipage. L'isolement et la distance de la Terre "
      "peuvent aussi peser sur la santé mentale.",
  "zone.chest.nasa":
      "L'apesanteur modifie la circulation du sang et le fonctionnement du cœur et "
      "des vaisseaux, ce qui peut augmenter le risque d'accident cardiovasculaire.",
  "zone.abdomen.nasa":
      "Le stress du vol spatial modifie le système immunitaire et peut réveiller des "
      "virus dormants dans le corps. Une température anormale peut être un premier "
      "signe d'infection.",
  "zone.arms.nasa":
      "Les muscles s'affaiblissent quand ils ne portent plus de poids. Tous les "
      "astronautes font de l'exercice pendant leur mission pour limiter la perte de "
      "force.",
  "zone.legs.nasa":
      "Sans gravité, les os se dégradent et deviennent plus fragiles. La NASA limite "
      "cela par l'alimentation, l'exercice et les médicaments.",
  "period.24h": "24 h",
  "period.7d": "7 jours",
  "period.30d": "30 jours",
  "period.all": "Tout",
  "trend.min": "Plus bas",
  "trend.avg": "Moyenne",
  "trend.max": "Plus haut",
  "trend.count": "{0} mesure(s) sur cette période",
  "trend.none": "Aucune mesure sur cette période.",
  "tx.title": "Transmission vers le sol",
  "tx.open.hint":
      "Rapports automatiques et liaison avec le sol. {0} rapport(s) en attente à "
      "bord.",
  "tx.link": "Liaison avec le sol",
  "tx.simulated": "Liaison simulée",
  "tx.space": "Vaisseau",
  "tx.ground": "Sol",
  "tx.linkdown": "Liaison coupée",
  "tx.waiting": "{0} en attente",
  "tx.received": "{0} reçu(s)",
  "tx.status.down": "Liaison coupée : {0} rapport(s) restent à bord jusqu'à son retour.",
  "tx.status.idle": "Liaison ouverte. Rien à envoyer.",
  "tx.status.sending": "Envoi du rapport {0}. {1}",

  "tx.number": "n° {0}",
  "tx.auto.title": "Rapport automatique",
  "tx.auto.text":
      "Après chaque mesure, l'application attend. Si aucune autre mesure n'arrive "
      "pendant ce temps, elle crée un rapport PDF avec les nouvelles mesures et la "
      "dernière valeur de chaque indicateur, puis le met dans la file d'attente pour "
      "le sol.",
  "tx.auto.delay": "Attente après la dernière mesure",
  "tx.delay.30": "30 s (démo)",
  "tx.delay.600": "10 min",
  "tx.delay.3600": "1 h",
  "tx.auto.next": "Prochain rapport dans {0} ({1} nouvelle(s) mesure(s))",
  "tx.auto.none": "Aucune nouvelle mesure en attente.",
  "tx.auto.closed":
      "Si l'application est fermée à l'échéance, le rapport est créé dès sa "
      "réouverture.",
  "tx.now": "Créer un rapport maintenant",
  "tx.reports": "Rapports",
  "tx.reports.none": "Aucun rapport pour l'instant. Enregistrez une mesure.",
  "tx.r.auto": "automatique",
  "tx.r.manual": "manuel",
  "tx.r.line": "{0} | {1} nouvelle(s) mesure(s) | {2}",
  "tx.r.wait": "En attente à bord",
  "tx.r.sending": "Envoi en cours",
  "tx.r.sent": "Reçu par le sol : {0} | {1} paquets, {2} renvoyé(s)",
  "tx.kb": "{0} Ko",
  "tx.share": "Partager ce PDF",
  "tx.log": "Journal du protocole",
  "tx.log.none": "Aucun transfert pour l'instant.",
  "tx.ev.md": "Metadata : fichier {0}, {1} octets, signature jointe",
  "tx.ev.fd": "File Data {0}/{1} : octets {2} à {3}",
  "tx.ev.lost": "perdu sur la liaison",
  "tx.ev.eof": "EOF : fin du fichier, somme de contrôle envoyée",
  "tx.ev.ackeof": "ACK : le sol confirme l'EOF",
  "tx.ev.nak": "NAK : le sol redemande les octets {0} à {1}",
  "tx.ev.refd": "File Data {0}/{1} renvoyé",
  "tx.ev.fin": "Finished : fichier complet et valide",
  "tx.ev.finbad": "Finished : fichier refusé",
  "tx.ev.ackfin": "ACK : le vaisseau clôt le transfert",
  "tx.log.ok":
      "Station sol : somme de contrôle correcte, signature valide, rapport déchiffré. "
      "Empreinte {0}",
  "tx.sec.title": "Protocole et sécurité",
  "tx.sec.cfdp":
      "Transfert de fichier : CCSDS File Delivery Protocol, classe 2 (CCSDS 727.0-B). "
      "Il a remplacé l'ancien protocole de fichiers SCPS. Une partie perdue est "
      "redemandée : le fichier arrive toujours entier.",
  "tx.sec.packet":
      "Chaque message voyage dans un paquet CCSDS Space Packet (CCSDS 133.0-B) "
      "terminé par un CRC-16 : un paquet abîmé est refusé.",
  "tx.sec.cipher":
      "Le rapport est chiffré avec ChaCha20 avant de partir : il est illisible sur la "
      "liaison.",
  "tx.sec.sign":
      "Il est signé avec HMAC-SHA-256 et la clé de mission : le sol vérifie qui l'a "
      "envoyé et que rien n'a changé.",
  "tx.sec.limit":
      "La liaison radio est simulée dans l'application : le délai est compressé et un "
      "paquet est perdu exprès. Le partage de la clé de mission avec une vraie "
      "station sol n'est pas fait dans ce prototype.",
  "tx.pdf.auto":
      "Rapport automatique : créé après le temps d'attente qui suit la dernière "
      "mesure.",
  "tx.pdf.manual": "Rapport créé par l'astronaute.",
  "tx.pdf.new": "Nouvelles mesures depuis le dernier rapport ({0})",
  "tx.pdf.nonew": "Aucune nouvelle mesure.",
  "tx.pdf.latest": "Dernière valeur de chaque indicateur",
};
