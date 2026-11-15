# AstroCare
 
Health monitoring for astronauts on long-duration missions.
Team **Falcon Health** - NASA Space Apps Challenge 2026, challenge
"Create Health Monitoring Software for Astronauts on Space Missions".
 
## What it does
 
- Each astronaut signs in to a personal account **before the mission**, while online.
- In space the app needs **no connection**: everything is stored on the device.
- Four indicators: heart rate, body temperature, sleep, mood.
- A human figure in real 3D: turn it in every direction, zoom, and touch a part of the
  body to see its health and illness thresholds, the related NASA risk and your own
  last values with their color code. It is drawn by the code: no 3D file, no network.
- For each indicator, a curve over the last 24 hours, 7 days, 30 days or everything.
- Green, orange or red status, always with an icon and a text label.
- Alerts with step-by-step first aid, chosen from the indicator and the direction of the
  deviation, and the warning signs that require the medical officer.
- A built-in first-aid guide, readable at any time without connection.
- **Automatic reports**: ten minutes after the last measurement, a PDF report is created
  with the new measurements and queued for the ground. A full report can also be shared.
- **Simulated downlink**: the queued reports cross a simulated link with the CCSDS File
  Delivery Protocol (class 2) in CCSDS Space Packets. One packet is lost on purpose and
  repaired. Reports are encrypted (ChaCha20) and signed (HMAC-SHA-256); the simulated
  ground station checks and decrypts them. The radio link itself is not real.
- When the internet is available again, the data is backed up to the online database.
- English and French. Light and dark themes.
 
## Architecture
 
- Local database (on the device): source of truth, used at all times.
- Online database (Supabase: accounts + PostgreSQL): sign-in and backup only.
- The analysis (thresholds, personal trend, combined risks) runs on the device.
 
## Supabase setup (once)
 
1. Create a project at https://supabase.com
2. SQL Editor: run `supabase/schema.sql` (three tables and their security policies).
3. Authentication > Sign In / Providers: turn off "Confirm email".
4. "Connect" button: copy the project URL and the publishable key into `lib/config.dart`.
## Visual identity
 
- Colors: NASA Space Apps brand guidelines (June 2026). Blues dominate, Neon Yellow is
  an accent only, reds are never a background, contrast is at least 4.5:1.
- Font: Fira Sans (SIL Open Font License), downloaded by `tool/get_fonts.sh` at build time.
- Logo: `assets/images/logo.png`, the team's own logo, also used as the app icon
  (`tool/make_icon.py`). No NASA logo or identity is used.
 
## Build
 
GitHub Actions builds the Android APK on every push to `main`
(see `.github/workflows/build.yml`). Download it from the workflow run, under Artifacts.
 
## NASA and partner resources used
 
- NASA Human Research Program, 5 Hazards of Human Spaceflight: https://www.nasa.gov/hrp/hazards/
- NASA Human Research Program, Risks of Human Spaceflight: https://www.nasa.gov/hrp/risks/
- NASA, Ongoing HRP Research in Space: https://www.nasa.gov/hrp/ongoing-hrp-research/
- Canadian Space Agency, Monitoring Radiation for Astronaut Health
- Canadian Space Agency, Why Do We Conduct Science Experiments in Space?
 
Each indicator is linked to a risk of the NASA Human Research Program:
cardiovascular adaptations, altered immune system responses, inadequate sleep and
irregular schedules, behavioral changes. The first-aid steps are general first-aid
actions; they are not prescribed by NASA.
 
## Disclaimer
 
AstroCare is a hackathon prototype. It is not a medical device and does not replace
a physician. Reference ranges are indicative values for healthy adults on Earth.
 
## Use of AI
 
AI assistants (Claude, Arena) helped write the specification, the design and the code.
The team reviewed the result. No AI-generated image is used.
