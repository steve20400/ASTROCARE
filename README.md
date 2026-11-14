# AstroCare
 
Offline health monitoring for astronauts on long-duration missions.
Team **Falcon Health** - NASA Space Apps Challenge 2026, challenge
"Create Health Monitoring Software for Astronauts on Space Missions".
 
## What it does
 
- Collect health indicators by hand: heart rate, blood pressure, SpO2, blood glucose,
  body temperature, sleep, mood, fatigue, weight.
- Show each indicator in green, orange or red, always with a text label and an icon.
- Interactive human figure: tap a body zone to see its indicators.
- Synergies: combinations of indicators and spaceflight hazards that raise the risk.
- Alerts with plain-language recommendations and step-by-step emergency protocols.
- Measurement reminders, a daily streak, a crew overview and a report for flight surgeons.
- Five mission environments: spacecraft, space station, rover, lunar base, Mars base.
- English and French. Light and dark themes.
 
## Works without any network
 
All data stays on the device (local storage). There is no server and no remote database.
The analysis (thresholds, trends, synergies) runs on the device.
 
## Build
 
GitHub Actions builds the Android APK on every push to `main`
(see `.github/workflows/build.yml`). Download it from the workflow run, under Artifacts.
 
To build locally: `flutter create --platforms=android --project-name astrocare .`,
then `flutter pub get` and `flutter build apk --release`.
 
## NASA and partner resources used
 
- NASA Human Research Program, 5 Hazards of Human Spaceflight: https://www.nasa.gov/hrp/hazards/
- NASA Human Research Program, Risks of Human Spaceflight: https://www.nasa.gov/hrp/risks/
- NASA, Ongoing HRP Research in Space: https://www.nasa.gov/hrp/ongoing-hrp-research/
- Canadian Space Agency, Monitoring Radiation for Astronaut Health:
  https://www.asc-csa.gc.ca/eng/news/articles/2026/2026-02-26-monitoring-radiation-astronaut-health.asp
- Canadian Space Agency, Why Do We Conduct Science Experiments in Space?:
  https://www.asc-csa.gc.ca/eng/iss/science/why-do-we-conduct-science-experiments-in-space.asp
## Disclaimer
 
AstroCare is a hackathon prototype. It is not a medical device and does not replace
a physician. Reference ranges are indicative values for healthy adults on Earth.
 
## Use of AI
 
AI assistants (Claude, Arena) helped write the specification, the design and the code.
The team reviewed the result. No AI-generated image is used.
