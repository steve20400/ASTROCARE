// Supabase project settings (dashboard: "Connect" button).
// These two values are public identifiers, not secrets: access is protected by the
// sign-in and by the row level security policies of the database.
// Never put the "secret" key or the database password in the app.
 
const String kSupabaseUrl = 'https://dwlyojrnkkghfcxvgdmf.supabase.co';
const String kSupabaseKey = 'sb_publishable_1zdVVo7UyvJIr33GfquUGQ_Inh8qwXW';
 
bool get isBackendConfigured => kSupabaseUrl.startsWith('https://') && kSupabaseKey.length > 20;
