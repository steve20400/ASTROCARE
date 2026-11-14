# AstroCare
 
Health monitoring for astronauts on long-duration missions.
Team **Falcon Health** - NASA Space Apps Challenge 2026, challenge
"Create Health Monitoring Software for Astronauts on Space Missions".
 
## What it does
 
- Each astronaut signs in to a personal account **before the mission**, while online.
- In space the app needs **no connection**: everything is stored on the device.
- Four indicators: heart rate, body temperature, sleep, mood.
- Green, orange or red status, always with an icon and a text label.
- Alerts with plain-language actions and a step-by-step emergency protocol.
- A **PDF health report** built on the device, to send to the ground through the usual channel.
- When the internet is available again, the data is backed up to the online database.
- English and French. Light and dark themes.
 
## Architecture
 
- Local database (on the device): source of truth, used at all times.
- Online database (Firebase Authentication + Cloud Firestore): accounts and backup only.
- The analysis (thresholds, personal trend, combined risks) runs on the device.
 
## Firebase setup (once)
 
1. Create a project at https://console.firebase.google.com
2. Authentication > Sign-in method: enable **Email/Password**.
3. Firestore Database: create the database, then paste `firestore.rules` in the Rules tab.
4. Project settings > General: copy the **Project ID** and the **Web API key**
   into `lib/config.dart`.
 
## Build
 
GitHub Actions builds the Android APK on every push to `main`
(see `.github/workflows/build.yml`). Download it from the workflow run, under Artifacts.
 
## NASA and partner resources used
 
- NASA Human Research Program, 5 Hazards of Human Spaceflight: https://www.nasa.gov/hrp/hazards/
- NASA Human Research Program, Risks of Human Spaceflight: https://www.nasa.gov/hrp/risks/
- NASA, Ongoing HRP Research in Space: https://www.nasa.gov/hrp/ongoing-hrp-research/
- Canadian Space Agency, Monitoring Radiation for Astronaut Health
- Canadian Space Agency, Why Do We Conduct Science Experiments in Space?
 
## Disclaimer
 
AstroCare is a hackathon prototype. It is not a medical device and does not replace
a physician. Reference ranges are indicative values for healthy adults on Earth.
 
## Use of AI
 
AI assistants (Claude, Arena) helped write the specification, the design and the code.
The team reviewed the result. No AI-generated image is used.
