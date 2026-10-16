import { createClient } from '@supabase/supabase-js';

const url = process.env.SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const userId = process.env.ADMIN_USER_ID;

if (!url || !serviceRoleKey || !userId) {
  console.error('Set SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, and ADMIN_USER_ID before running this script.');
  process.exit(1);
}

const supabase = createClient(url, serviceRoleKey, {
  auth: { autoRefreshToken: false, persistSession: false },
});

const { data: lookup, error: lookupError } = await supabase.auth.admin.getUserById(userId);
if (lookupError || !lookup.user) {
  console.error(lookupError?.message || 'Admin user not found.');
  process.exit(1);
}

const appMetadata = { ...lookup.user.app_metadata, role: 'admin' };
const { error } = await supabase.auth.admin.updateUserById(userId, { app_metadata: appMetadata });
if (error) {
  console.error(error.message);
  process.exit(1);
}

console.log(`Admin role assigned to ${lookup.user.email || userId}. Sign out and sign in again to refresh the session.`);
