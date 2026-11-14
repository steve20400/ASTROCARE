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
  "nav.dashboard": "Dashboard",
  "nav.body": "Body",
  "nav.synergies": "Synergies",
  "nav.alerts": "Alerts",
  "nav.more": "More",
  "level.nominal": "Nominal",
  "level.attention": "Attention",
  "level.critical": "Critical",
  "level.nodata": "No data",
  "status.active": "Active",
  "status.acknowledged": "Acknowledged",
  "status.resolved": "Resolved",
  "cause.threshold": "The value is outside its reference range.",
  "cause.trend": "The value is far from your own usual values, even if it is still in range.",
  "cause.synergy":
      "Several indicators are degraded at the same time under a spaceflight hazard.",
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
  "haz.radiation.desc": "Space radiation can damage cells, the nervous system and immunity.",
  "haz.isolation.desc": "Months in a small group affect sleep, mood and performance.",
  "haz.distance.desc": "Far from Earth, help is delayed: the crew must act on its own.",
  "haz.gravity.desc": "Weightlessness weakens bones, muscles and the cardiovascular system.",
  "haz.environment.desc": "Air, temperature, noise and microbes of the cabin act on the body.",
  "zone.head": "Head: sleep and behavioral health",
  "zone.heart": "Heart and circulation",
  "zone.lungs": "Lungs and oxygen",
  "zone.abdomen": "Metabolism and nutrition",
  "zone.core": "Body temperature and immunity",
  "zone.legs": "Bones and muscles",
  "dash.member": "Crew member",
  "dash.overall": "Overall status",
  "dash.autonomous": "Autonomous mode: all data stays on this device.",
  "dash.streak": "{0}-day measurement streak",
  "dash.streak.none": "Record a measurement today to start your streak.",
  "dash.reminders": "Measurements due",
  "dash.indicators": "Health indicators",
  "dash.add": "Add measurement",
  "dash.nodata": "Not measured yet",
  "dash.measure": "Measure",
  "add.title": "New measurement",
  "add.indicator": "Indicator",
  "add.value": "Value",
  "add.save": "Save",
  "add.cancel": "Cancel",
  "add.invalid": "Enter a number between {0} and {1}.",
  "add.how": "How to measure",
  "add.saved": "{0} recorded: {1}",
  "add.view": "View alert",
  "add.score.hint": "1 = lowest, 5 = highest",
  "ind.last": "Last value",
  "ind.trend": "Evolution over time",
  "ind.range": "Reference range",
  "ind.what": "What it means",
  "ind.how": "How to measure",
  "ind.space": "In space",
  "ind.history": "History",
  "ind.needTwo": "Record at least two measurements to see the curve.",
  "range.nominal": "Nominal: {0} to {1} {2}",

  "range.relative": "Nominal: within {0} % of your pre-flight weight ({1} kg)",
  "range.note": "Indicative values for healthy adults on Earth.",
  "body.title": "Tap a body zone",
  "body.hint": "Each zone shows the worst status of its indicators.",
  "synergy.title": "Synergy",
  "synergy.heatmap": "Indicators and spaceflight hazards",
  "synergy.heatmap.hint":
      "A colored cell links an indicator to a hazard. Faded: hazard less present here.",
  "synergy.rules": "Combined risks",
  "synergy.active": "Active",
  "synergy.inactive": "Not active",
  "synergy.none": "No risky combination right now.",
  "synergy.conditions": "Active when all of these are at attention or worse:",
  "synergy.under": "Under the hazard: {0}",
  "synergy.risk": "Risk",
  "synergy.advice": "What to do",
  "alerts.none": "No alert. Keep measuring regularly.",
  "alerts.crew": "Whole crew",
  "alerts.open": "Open alerts",
  "alerts.past": "Resolved alerts",
  "alert.value": "Measured value",
  "alert.cause": "Why this alert",
  "alert.space": "Link with spaceflight",
  "alert.reco": "Recommended actions",
  "alert.protocol": "Emergency protocol",
  "alert.ack": "Actions done: acknowledge",
  "alert.acked": "Alert acknowledged. Take a control measurement.",
  "alert.control": "Take a control measurement",
  "alert.ground": "Report this to the flight surgeons at the next contact with Earth.",
  "settings.section": "Mission settings",
  "settings.language": "Language",
  "settings.theme": "Dark theme",
  "settings.environment": "Mission environment",
  "crew.title": "Crew overview",
  "crew.hint": "Tap a member to switch profile.",
  "rem.title": "Measurement reminders",
  "rem.off": "Off",
  "rem.every": "Every {0} h",
  "report.title": "Crew health report",
  "report.generated": "Generated",
  "report.status": "Overall status",
  "report.openAlerts": "Open alerts",
  "report.button": "Generate the report for the ground",
  "report.copy": "Copy",
  "report.copied": "Report copied. Send it when the link with Earth is available.",
  "report.close": "Close",
  "demo.title": "Demonstration",
  "demo.load": "Load demo data",
  "demo.loaded": "Demo data loaded: four crew profiles over ten days.",
  "demo.reset": "Erase all data",
  "demo.confirm": "Erase all measurements and alerts stored on this device?",
  "demo.yes": "Erase",
  "about.title": "About",
  "about.disclaimer":
      "AstroCare is a hackathon prototype. It is not a medical device and does not replace "
      "a physician.",
  "about.resources": "NASA and partner resources",
  "about.team": "Team Falcon Health - NASA Space Apps Challenge 2026",
  "about.ai":
      "AI assistants helped write the design and the code. The team reviewed the result.",
  "syn.immune.name": "Sleep debt, fatigue and radiation",
  "syn.immune.risk": "Higher risk of a weakened immune system and slower recovery.",
  "syn.immune.advice":
      "Protect the next sleep period, lighten the schedule, and keep hygiene strict.",
  "syn.cardio.name": "Heart rate and blood pressure in altered gravity",
  "syn.cardio.risk": "Possible cardiovascular deconditioning or fluid shift effects.",
  "syn.cardio.advice":
      "Rest 10 minutes, measure again, hydrate, and keep the daily exercise session.",
  "syn.behavior.name": "Low mood and poor sleep in isolation",
  "syn.behavior.risk": "Higher risk for behavioral health and team performance.",
  "syn.behavior.advice":
      "Talk with a crewmate, plan a private call with family, and keep a regular sleep "
      "schedule.",
  "syn.nutrition.name": "Weight change and blood glucose",
  "syn.nutrition.risk": "Possible inadequate nutrition with muscle and bone loss.",
  "syn.nutrition.advice":
      "Log your meals for three days, eat the planned calories, and keep resistive exercise.",
  "syn.hypoxia.name": "Low oxygen and fast heart rate",
  "syn.hypoxia.risk": "Possible lack of oxygen, from the cabin air or from the lungs.",
  "syn.hypoxia.advice":
      "Check the cabin air (O2, CO2), move to a ventilated area, and alert the crew now.",
  "ind.heartRate.name": "Heart rate",
  "ind.heartRate.what": "Number of heartbeats per minute at rest.",
  "ind.heartRate.how":

      "Sit still for 5 minutes. Use the pulse oximeter, or count the pulse at the wrist for "
      "60 s.",
  "ind.heartRate.space":
      "In weightlessness the heart works differently and can lose conditioning.",
  "ind.heartRate.attention":
      "Rest 10 minutes and measure again. Drink water. Avoid effort until it settles.",
  "ind.heartRate.critical":
      "Stop all activity and stay still.|Tell a crewmate now.|Measure blood pressure and "
      "SpO2.|Follow the medical officer and prepare a message to the flight surgeons.",
  "ind.bpSystolic.name": "Blood pressure (systolic)",
  "ind.bpSystolic.what":
      "Pressure in the arteries when the heart contracts. It is the higher number.",
  "ind.bpSystolic.how":
      "Rest 5 minutes. Place the cuff on the bare upper arm at heart level. Do not talk.",
  "ind.bpSystolic.space": "Body fluids move toward the head and change blood pressure.",
  "ind.bpSystolic.attention":
      "Rest and measure again in 15 minutes. Reduce salt and check hydration.",
  "ind.bpSystolic.critical":
      "Sit or secure yourself and stay calm.|Tell a crewmate now.|Measure again after 5 "
      "minutes.|If it stays critical, follow the medical officer and contact the flight "
      "surgeons.",
  "ind.bpDiastolic.name": "Blood pressure (diastolic)",
  "ind.bpDiastolic.what":
      "Pressure in the arteries between two heartbeats. It is the lower number.",
  "ind.bpDiastolic.how": "Read it on the same cuff measurement as the systolic pressure.",
  "ind.bpDiastolic.space": "Fluid shift and deconditioning change the tone of blood vessels.",
  "ind.bpDiastolic.attention": "Rest and measure again in 15 minutes. Check hydration.",
  "ind.bpDiastolic.critical":
      "Sit or secure yourself.|Tell a crewmate now.|Measure again after 5 minutes.|If it "
      "stays critical, follow the medical officer and contact the flight surgeons.",
  "ind.spo2.name": "Oxygen saturation (SpO2)",
  "ind.spo2.what": "Share of the blood that carries oxygen.",
  "ind.spo2.how":
      "Warm your hand. Clip the pulse oximeter on a finger and wait for a stable reading.",
  "ind.spo2.space": "In a closed cabin, air quality (oxygen, CO2) acts directly on this value.",
  "ind.spo2.attention":
      "Breathe slowly and deeply, move to a ventilated area, measure again in 5 minutes.",
  "ind.spo2.critical":
      "Tell the crew now.|Check the cabin air: oxygen and CO2 levels.|Use the emergency "
      "oxygen supply if available.|Stay at rest and measure every 5 minutes.|Contact the "
      "flight surgeons.",
  "ind.glucose.name": "Blood glucose",
  "ind.glucose.what": "Amount of sugar in the blood, in mg/dL. Measure it before a meal.",
  "ind.glucose.how":
      "Wash and dry your hands. Prick the side of a fingertip and apply the drop to the "
      "strip.",
  "ind.glucose.space":
      "Space food, stress and less activity can disturb nutrition and metabolism.",
  "ind.glucose.attention":
      "If low, eat a snack with sugar. If high, drink water and measure again before the "
      "next meal.",
  "ind.glucose.critical":
      "If low: take fast sugar now (juice, glucose gel).|Tell a crewmate and do not stay "
      "alone.|Measure again after 15 minutes.|If high or not improving, follow the medical "
      "officer and contact the flight surgeons.",
  "ind.temperature.name": "Body temperature",
  "ind.temperature.what": "Temperature of the body, in degrees Celsius.",
  "ind.temperature.how": "Use the thermometer as instructed and stay still until the beep.",
  "ind.temperature.space":
      "Immunity changes in space: a fever can reveal an infection in the closed cabin.",
  "ind.temperature.attention":
      "Rest, drink water, and measure again in one hour. Limit contact with the crew.",
  "ind.temperature.critical":
      "Tell the medical officer now.|Rest and hydrate.|If fever: remove layers and cool "
      "down. If too cold: warm up with blankets.|Measure every 30 minutes.|Contact the "
      "flight surgeons.",
  "ind.sleepDuration.name": "Sleep duration",
  "ind.sleepDuration.what": "Hours slept during the last sleep period.",
  "ind.sleepDuration.how":
      "Enter the hours actually slept, not the time spent in the sleep station.",
  "ind.sleepDuration.space": "No natural day and night, noise and workload shorten sleep.",
  "ind.sleepDuration.attention":
      "Dim the lights one hour before sleep, avoid screens, and keep a fixed schedule.",
  "ind.sleepDuration.critical":
      "Tell the commander: fatigue is a safety risk.|Postpone critical tasks such as "
      "piloting or spacewalks.|Plan a recovery sleep period today.|Report it to the flight "
      "surgeons.",
  "ind.sleepQuality.name": "Sleep quality",
  "ind.sleepQuality.what":
      "Your own rating of the last sleep, from 1 (very poor) to 5 (very good).",
  "ind.sleepQuality.how": "Rate it right after waking up.",
  "ind.sleepQuality.space": "Noise, light and confinement disturb deep sleep.",
  "ind.sleepQuality.attention":
      "Use earplugs and an eye mask, and keep the sleep station cool and dark.",

  "ind.sleepQuality.critical":
      "Tell the commander.|Postpone critical tasks if you feel sleepy.|Plan a nap of 20 to "
      "30 minutes.|Report it to the flight surgeons.",
  "ind.mood.name": "Mood",
  "ind.mood.what": "Your own rating of your mood, from 1 (very low) to 5 (very good).",
  "ind.mood.how": "Answer honestly: how do you feel right now?",
  "ind.mood.space": "Isolation, confinement and distance from family weigh on morale.",
  "ind.mood.attention": "Take a break, do an activity you enjoy, and talk with a crewmate.",
  "ind.mood.critical":
      "Do not stay alone: talk to a crewmate you trust now.|Tell the medical officer.|Ask "
      "for a private conference with the ground support team.|Lighten your schedule for "
      "today.",
  "ind.fatigue.name": "Fatigue",
  "ind.fatigue.what": "Your own rating of fatigue, from 1 (rested) to 5 (exhausted).",
  "ind.fatigue.how": "Rate how tired you feel right now.",
  "ind.fatigue.space": "Workload, poor sleep and radiation exposure all increase fatigue.",
  "ind.fatigue.attention":
      "Take a 20-minute break, hydrate, and move the hardest task to later.",
  "ind.fatigue.critical":
      "Stop the current task safely.|Tell the commander: exhaustion is a safety risk.|Rest "
      "now.|Postpone critical operations and report it to the flight surgeons.",
  "ind.weight.name": "Body mass",
  "ind.weight.what": "Your body mass in kilograms, compared with your pre-flight value.",
  "ind.weight.how": "Use the body mass measurement device as trained, at the same time of day.",
  "ind.weight.space": "Without gravity, muscles and bones are less used and lose mass.",
  "ind.weight.attention":
      "Eat all planned meals and do not skip the resistive exercise session.",
  "ind.weight.critical":
      "Tell the medical officer.|Log every meal and drink for three days.|Follow the "
      "exercise plan under supervision.|Report it to the flight surgeons.",
};
 
const Map<String, String> kFr = {
  "nav.dashboard": "Tableau de bord",
  "nav.body": "Corps",
  "nav.synergies": "Synergies",
  "nav.alerts": "Alertes",
  "nav.more": "Plus",
  "level.nominal": "Nominal",
  "level.attention": "Attention",
  "level.critical": "Critique",
  "level.nodata": "Pas de donnée",
  "status.active": "Active",
  "status.acknowledged": "Acquittée",
  "status.resolved": "Résolue",
  "cause.threshold": "La valeur est en dehors de sa plage de référence.",
  "cause.trend":
      "La valeur s'écarte beaucoup de vos valeurs habituelles, même si elle reste dans la "
      "plage.",
  "cause.synergy": "Plusieurs indicateurs sont dégradés en même temps sous un danger spatial.",
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
  "haz.radiation.desc":
      "Les radiations spatiales abîment les cellules, le système nerveux et l'immunité.",
  "haz.isolation.desc":
      "Des mois en petit groupe agissent sur le sommeil, l'humeur et la performance.",
  "haz.distance.desc": "Loin de la Terre, l'aide arrive en retard : l'équipage doit agir seul.",
  "haz.gravity.desc":
      "L'apesanteur affaiblit les os, les muscles et le système cardiovasculaire.",
  "haz.environment.desc":
      "L'air, la température, le bruit et les microbes de la cabine agissent sur le corps.",
  "zone.head": "Tête : sommeil et santé comportementale",
  "zone.heart": "Cœur et circulation",
  "zone.lungs": "Poumons et oxygène",
  "zone.abdomen": "Métabolisme et nutrition",
  "zone.core": "Température du corps et immunité",
  "zone.legs": "Os et muscles",
  "dash.member": "Membre d'équipage",
  "dash.overall": "État général",
  "dash.autonomous": "Mode autonome : toutes les données restent sur cet appareil.",
  "dash.streak": "Série de {0} jours de mesures",
  "dash.streak.none": "Enregistrez une mesure aujourd'hui pour démarrer votre série.",
  "dash.reminders": "Mesures à faire",
  "dash.indicators": "Indicateurs de santé",
  "dash.add": "Ajouter une mesure",
  "dash.nodata": "Pas encore mesuré",

  "dash.measure": "Mesurer",
  "add.title": "Nouvelle mesure",
  "add.indicator": "Indicateur",
  "add.value": "Valeur",
  "add.save": "Enregistrer",
  "add.cancel": "Annuler",
  "add.invalid": "Saisissez un nombre entre {0} et {1}.",
  "add.how": "Comment mesurer",
  "add.saved": "{0} enregistré : {1}",
  "add.view": "Voir l'alerte",
  "add.score.hint": "1 = le plus bas, 5 = le plus haut",
  "ind.last": "Dernière valeur",
  "ind.trend": "Évolution dans le temps",
  "ind.range": "Plage de référence",
  "ind.what": "Ce que cela signifie",
  "ind.how": "Comment mesurer",
  "ind.space": "Dans l'espace",
  "ind.history": "Historique",
  "ind.needTwo": "Enregistrez au moins deux mesures pour voir la courbe.",
  "range.nominal": "Nominal : de {0} à {1} {2}",
  "range.relative": "Nominal : à moins de {0} % de votre poids avant le vol ({1} kg)",
  "range.note": "Valeurs indicatives pour un adulte en bonne santé sur Terre.",
  "body.title": "Touchez une zone du corps",
  "body.hint": "Chaque zone affiche le pire état de ses indicateurs.",
  "synergy.title": "Synergie",
  "synergy.heatmap": "Indicateurs et dangers du vol spatial",
  "synergy.heatmap.hint":
      "Une case colorée relie un indicateur à un danger. Atténuée : danger moins présent ici.",
  "synergy.rules": "Risques combinés",
  "synergy.active": "Active",
  "synergy.inactive": "Inactive",
  "synergy.none": "Aucune combinaison à risque pour le moment.",
  "synergy.conditions": "Active quand tous ces indicateurs sont en attention ou pire :",
  "synergy.under": "Sous le danger : {0}",
  "synergy.risk": "Risque",
  "synergy.advice": "Que faire",
  "alerts.none": "Aucune alerte. Continuez à mesurer régulièrement.",
  "alerts.crew": "Tout l'équipage",
  "alerts.open": "Alertes ouvertes",
  "alerts.past": "Alertes résolues",
  "alert.value": "Valeur mesurée",
  "alert.cause": "Pourquoi cette alerte",
  "alert.space": "Lien avec le vol spatial",
  "alert.reco": "Actions recommandées",
  "alert.protocol": "Protocole d'urgence",
  "alert.ack": "Actions faites : acquitter",
  "alert.acked": "Alerte acquittée. Faites une mesure de contrôle.",
  "alert.control": "Faire une mesure de contrôle",
  "alert.ground": "Signalez-le aux médecins de vol au prochain contact avec la Terre.",
  "settings.section": "Réglages de mission",
  "settings.language": "Langue",
  "settings.theme": "Thème sombre",
  "settings.environment": "Environnement de mission",
  "crew.title": "Vue de l'équipage",
  "crew.hint": "Touchez un membre pour changer de profil.",
  "rem.title": "Rappels de mesure",
  "rem.off": "Désactivé",
  "rem.every": "Toutes les {0} h",
  "report.title": "Rapport de santé de l'équipage",
  "report.generated": "Généré le",
  "report.status": "État général",
  "report.openAlerts": "Alertes ouvertes",
  "report.button": "Générer le rapport pour le sol",
  "report.copy": "Copier",
  "report.copied": "Rapport copié. Envoyez-le quand la liaison avec la Terre est disponible.",
  "report.close": "Fermer",
  "demo.title": "Démonstration",
  "demo.load": "Charger les données de démonstration",
  "demo.loaded": "Données de démonstration chargées : quatre profils sur dix jours.",
  "demo.reset": "Effacer toutes les données",
  "demo.confirm": "Effacer toutes les mesures et alertes enregistrées sur cet appareil ?",
  "demo.yes": "Effacer",
  "about.title": "À propos",
  "about.disclaimer":
      "AstroCare est un prototype de hackathon. Ce n'est pas un dispositif médical et il ne "
      "remplace pas un médecin.",
  "about.resources": "Ressources de la NASA et de ses partenaires",
  "about.team": "Équipe Falcon Health - NASA Space Apps Challenge 2026",
  "about.ai":
      "Des assistants IA ont aidé à écrire la conception et le code. L'équipe a relu le "
      "résultat.",
  "syn.immune.name": "Manque de sommeil, fatigue et radiations",
  "syn.immune.risk":
      "Risque accru d'affaiblissement immunitaire et de récupération plus lente.",

  "syn.immune.advice":
      "Protégez la prochaine période de sommeil, allégez le planning et gardez une hygiène "
      "stricte.",
  "syn.cardio.name": "Fréquence cardiaque et tension en gravité modifiée",
  "syn.cardio.risk":
      "Possible déconditionnement cardiovasculaire ou effet du déplacement des fluides.",
  "syn.cardio.advice":
      "Reposez-vous 10 minutes, mesurez à nouveau, hydratez-vous et gardez la séance "
      "d'exercice.",
  "syn.behavior.name": "Humeur basse et mauvais sommeil en isolement",
  "syn.behavior.risk":
      "Risque accru pour la santé comportementale et la performance de l'équipe.",
  "syn.behavior.advice":
      "Parlez à un coéquipier, prévoyez un appel privé avec la famille et gardez des "
      "horaires de sommeil réguliers.",
  "syn.nutrition.name": "Variation de poids et glycémie",
  "syn.nutrition.risk": "Nutrition peut-être inadaptée, avec perte musculaire et osseuse.",
  "syn.nutrition.advice":
      "Notez vos repas pendant trois jours, mangez les calories prévues et gardez "
      "l'exercice résistif.",
  "syn.hypoxia.name": "Oxygène bas et cœur rapide",
  "syn.hypoxia.risk": "Possible manque d'oxygène, lié à l'air de la cabine ou aux poumons.",
  "syn.hypoxia.advice":
      "Vérifiez l'air de la cabine (O2, CO2), allez dans une zone ventilée et alertez "
      "l'équipage tout de suite.",
  "ind.heartRate.name": "Fréquence cardiaque",
  "ind.heartRate.what": "Nombre de battements du cœur par minute, au repos.",
  "ind.heartRate.how":
      "Restez immobile 5 minutes. Utilisez l'oxymètre, ou comptez le pouls au poignet "
      "pendant 60 s.",
  "ind.heartRate.space":
      "En apesanteur, le cœur travaille autrement et peut se déconditionner.",
  "ind.heartRate.attention":
      "Reposez-vous 10 minutes et mesurez à nouveau. Buvez de l'eau. Évitez l'effort d'ici "
      "là.",
  "ind.heartRate.critical":
      "Arrêtez toute activité et restez immobile.|Prévenez un coéquipier tout de "
      "suite.|Mesurez la tension et la SpO2.|Suivez l'officier médical et préparez un "
      "message pour les médecins de vol.",
  "ind.bpSystolic.name": "Tension artérielle (systolique)",
  "ind.bpSystolic.what":
      "Pression dans les artères quand le cœur se contracte. C'est le chiffre le plus haut.",
  "ind.bpSystolic.how":
      "Reposez-vous 5 minutes. Placez le brassard sur le bras nu, à hauteur du cœur. Ne "
      "parlez pas.",
  "ind.bpSystolic.space": "Les fluides du corps montent vers la tête et modifient la tension.",
  "ind.bpSystolic.attention":
      "Reposez-vous et mesurez à nouveau dans 15 minutes. Réduisez le sel et vérifiez "
      "l'hydratation.",
  "ind.bpSystolic.critical":
      "Asseyez-vous ou attachez-vous, et restez calme.|Prévenez un coéquipier tout de "
      "suite.|Mesurez à nouveau après 5 minutes.|Si la valeur reste critique, suivez "
      "l'officier médical et contactez les médecins de vol.",
  "ind.bpDiastolic.name": "Tension artérielle (diastolique)",
  "ind.bpDiastolic.what":
      "Pression dans les artères entre deux battements. C'est le chiffre le plus bas.",
  "ind.bpDiastolic.how": "Lisez-la sur la même mesure au brassard que la tension systolique.",
  "ind.bpDiastolic.space":
      "Le déplacement des fluides et le déconditionnement modifient le tonus des vaisseaux.",
  "ind.bpDiastolic.attention":
      "Reposez-vous et mesurez à nouveau dans 15 minutes. Vérifiez l'hydratation.",
  "ind.bpDiastolic.critical":
      "Asseyez-vous ou attachez-vous.|Prévenez un coéquipier tout de suite.|Mesurez à "
      "nouveau après 5 minutes.|Si la valeur reste critique, suivez l'officier médical et "
      "contactez les médecins de vol.",
  "ind.spo2.name": "Saturation en oxygène (SpO2)",
  "ind.spo2.what": "Part du sang qui transporte de l'oxygène.",
  "ind.spo2.how":
      "Réchauffez votre main. Pincez l'oxymètre sur un doigt et attendez une valeur stable.",
  "ind.spo2.space":
      "Dans une cabine fermée, la qualité de l'air (oxygène, CO2) agit directement sur "
      "cette valeur.",
  "ind.spo2.attention":
      "Respirez lentement et profondément, allez dans une zone ventilée, mesurez à nouveau "
      "dans 5 minutes.",
  "ind.spo2.critical":
      "Prévenez l'équipage tout de suite.|Vérifiez l'air de la cabine : taux d'oxygène et "
      "de CO2.|Utilisez l'oxygène de secours s'il est disponible.|Restez au repos et "
      "mesurez toutes les 5 minutes.|Contactez les médecins de vol.",
  "ind.glucose.name": "Glycémie",
  "ind.glucose.what": "Quantité de sucre dans le sang, en mg/dL. Mesurez-la avant un repas.",
  "ind.glucose.how":
      "Lavez et séchez vos mains. Piquez le côté d'un doigt et déposez la goutte sur la "
      "bandelette.",

  "ind.glucose.space":
      "La nourriture spatiale, le stress et la baisse d'activité peuvent perturber la "
      "nutrition et le métabolisme.",
  "ind.glucose.attention":
      "Si elle est basse, prenez une collation sucrée. Si elle est haute, buvez de l'eau et "
      "mesurez avant le prochain repas.",
  "ind.glucose.critical":
      "Si elle est basse : prenez du sucre rapide tout de suite (jus, gel de "
      "glucose).|Prévenez un coéquipier et ne restez pas seul.|Mesurez à nouveau après 15 "
      "minutes.|Si elle est haute ou ne s'améliore pas, suivez l'officier médical et "
      "contactez les médecins de vol.",
  "ind.temperature.name": "Température corporelle",
  "ind.temperature.what": "Température du corps, en degrés Celsius.",
  "ind.temperature.how":
      "Utilisez le thermomètre comme indiqué et restez immobile jusqu'au bip.",
  "ind.temperature.space":
      "L'immunité change dans l'espace : une fièvre peut révéler une infection dans la "
      "cabine fermée.",
  "ind.temperature.attention":
      "Reposez-vous, buvez de l'eau et mesurez à nouveau dans une heure. Limitez les "
      "contacts avec l'équipage.",
  "ind.temperature.critical":
      "Prévenez l'officier médical tout de suite.|Reposez-vous et hydratez-vous.|En cas de "
      "fièvre : découvrez-vous et rafraîchissez-vous. Si vous avez trop froid : "
      "réchauffez-vous avec des couvertures.|Mesurez toutes les 30 minutes.|Contactez les "
      "médecins de vol.",
  "ind.sleepDuration.name": "Durée du sommeil",
  "ind.sleepDuration.what": "Heures dormies pendant la dernière période de sommeil.",
  "ind.sleepDuration.how":
      "Saisissez les heures réellement dormies, pas le temps passé dans la couchette.",
  "ind.sleepDuration.space":
      "L'absence de jour et de nuit naturels, le bruit et la charge de travail "
      "raccourcissent le sommeil.",
  "ind.sleepDuration.attention":
      "Baissez la lumière une heure avant de dormir, évitez les écrans et gardez un horaire "
      "fixe.",
  "ind.sleepDuration.critical":
      "Prévenez le commandant : la fatigue est un risque pour la sécurité.|Reportez les "
      "tâches critiques comme le pilotage ou les sorties.|Prévoyez une période de sommeil "
      "de récupération aujourd'hui.|Signalez-le aux médecins de vol.",
  "ind.sleepQuality.name": "Qualité du sommeil",
  "ind.sleepQuality.what":
      "Votre propre note du dernier sommeil, de 1 (très mauvais) à 5 (très bon).",
  "ind.sleepQuality.how": "Notez-la juste après le réveil.",
  "ind.sleepQuality.space":
      "Le bruit, la lumière et le confinement perturbent le sommeil profond.",
  "ind.sleepQuality.attention":
      "Utilisez des bouchons d'oreilles et un masque, et gardez la couchette fraîche et "
      "sombre.",
  "ind.sleepQuality.critical":
      "Prévenez le commandant.|Reportez les tâches critiques si vous somnolez.|Prévoyez une "
      "sieste de 20 à 30 minutes.|Signalez-le aux médecins de vol.",
  "ind.mood.name": "Humeur",
  "ind.mood.what": "Votre propre note de votre humeur, de 1 (très basse) à 5 (très bonne).",
  "ind.mood.how": "Répondez honnêtement : comment vous sentez-vous maintenant ?",
  "ind.mood.space":
      "L'isolement, le confinement et l'éloignement de la famille pèsent sur le moral.",
  "ind.mood.attention":
      "Faites une pause, une activité qui vous plaît, et parlez à un coéquipier.",
  "ind.mood.critical":
      "Ne restez pas seul : parlez tout de suite à un coéquipier de confiance.|Prévenez "
      "l'officier médical.|Demandez une conférence privée avec l'équipe de soutien au "
      "sol.|Allégez votre planning d'aujourd'hui.",
  "ind.fatigue.name": "Fatigue",
  "ind.fatigue.what": "Votre propre note de fatigue, de 1 (reposé) à 5 (épuisé).",
  "ind.fatigue.how": "Notez votre niveau de fatigue maintenant.",
  "ind.fatigue.space":
      "La charge de travail, le mauvais sommeil et l'exposition aux radiations augmentent "
      "la fatigue.",
  "ind.fatigue.attention":
      "Faites une pause de 20 minutes, hydratez-vous et décalez la tâche la plus difficile.",
  "ind.fatigue.critical":
      "Arrêtez la tâche en cours en sécurité.|Prévenez le commandant : l'épuisement est un "
      "risque pour la sécurité.|Reposez-vous maintenant.|Reportez les opérations critiques "
      "et signalez-le aux médecins de vol.",
  "ind.weight.name": "Masse corporelle",
  "ind.weight.what": "Votre masse en kilogrammes, comparée à votre valeur avant le vol.",
  "ind.weight.how":
      "Utilisez l'appareil de mesure de masse comme appris, à la même heure chaque jour.",
  "ind.weight.space":
      "Sans gravité, les muscles et les os travaillent moins et perdent de la masse.",
  "ind.weight.attention":
      "Mangez tous les repas prévus et ne sautez pas la séance d'exercice résistif.",
  "ind.weight.critical":

      "Prévenez l'officier médical.|Notez chaque repas et boisson pendant trois "
      "jours.|Suivez le plan d'exercice sous supervision.|Signalez-le aux médecins de vol.",
};
