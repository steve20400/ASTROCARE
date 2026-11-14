// Firebase project settings. Replace the two values below with those of YOUR project:
// Firebase console > Project settings > General ("Project ID" and "Web API key").
// These two values are public identifiers, not secrets: access is protected by the
// sign-in and by the Firestore security rules.
 
const String kFirebaseApiKey = 'PASTE_WEB_API_KEY_HERE';
const String kFirebaseProjectId = 'PASTE_PROJECT_ID_HERE';
 
bool get isFirebaseConfigured =>
    !kFirebaseApiKey.startsWith('PASTE_') && !kFirebaseProjectId.startsWith('PASTE_');
