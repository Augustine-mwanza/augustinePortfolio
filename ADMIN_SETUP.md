# Portfolio admin setup

The admin dashboard is at `/admin.html`. It manages project cards. Supabase Auth handles sign-in, and Postgres Row Level Security restricts project edits to users whose trusted `app_metadata.role` is `admin`.

## 1. Create the Supabase project

Create a Supabase project and enable email/password sign-in. In the Supabase SQL Editor, run the contents of `supabase-schema.sql`. It creates the project table, access policies, and initial portfolio projects.

## 2. Configure the public client

Copy the Project URL and publishable key from Supabase API settings into `supabase-config.js`. The publishable key is intended for browser code; never put a secret/service-role key in this file. Keep Row Level Security enabled.

## 3. Create the administrator

Create your user in Supabase Authentication and copy its user ID. Assign its trusted admin role from your local PowerShell terminal. Replace the sample values with your own, and do not commit or share the service-role key:

```powershell
$env:SUPABASE_URL = "https://YOUR_PROJECT.supabase.co"
$env:SUPABASE_SERVICE_ROLE_KEY = "YOUR_SECRET_SERVICE_ROLE_KEY"
$env:ADMIN_USER_ID = "YOUR_AUTH_USER_UUID"
npm run set-admin-role
Remove-Item Env:SUPABASE_SERVICE_ROLE_KEY
Remove-Item Env:SUPABASE_URL
Remove-Item Env:ADMIN_USER_ID
```

The role script uses the service-role key only on your local machine to assign the trusted role. Never put that key in `supabase-config.js`, `index.html`, or GitHub. Sign out and back in after the role is assigned so the session token receives the new role.

Install the package dependency first with `npm install` if this is a fresh checkout.

## 4. Deploy

Commit and push `index.html`, `admin.html`, `supabase-config.js`, `supabase-schema.sql`, `scripts/set-admin-role.js`, `package.json`, and this guide. Deploy the repository as a static site on Vercel or GitHub Pages. Set the deployed site URL in Supabase Authentication URL Configuration and add the admin page URL to the allowed redirect URLs.

Visit `/admin.html`, sign in, then add, edit, publish, hide, or delete projects. Image paths should point to files committed to the site or public image URLs. Project edits appear on the public portfolio after it reloads.

## Local preview

Run `npm start` and open the local URL printed by the server. `admin.html` and the homepage both use the configuration from `supabase-config.js`.
