-- Bootstrapping the first Admin user in production
--
-- Since our public.create_staff_user() function requires an admin to call it,
-- you must create the very first admin user using one of the following methods:
--
-- METHOD 1: Using the Supabase SQL Editor (Recommended)
-- 1. Create a user normally through your app or the Supabase Auth Dashboard (e.g., admin@yourdomain.com).
-- 2. Run the SQL query below in the SQL Editor to promote them to the Admin role:

UPDATE public.profiles 
SET role = 'admin', 
    requires_password_reset = false 
WHERE email = 'admin@yourdomain.com'; -- Replace with your actual admin email

--
-- METHOD 2: Direct SQL seeding (If you want to create the user directly in database)
-- Run this SQL in the SQL Editor (replace email and password):
--
-- DO $$
-- DECLARE
--   new_admin_id UUID := gen_random_uuid();
-- BEGIN
--   INSERT INTO auth.users (
--     instance_id, id, email, encrypted_password, email_confirmed_at, 
--     raw_app_meta_data, raw_user_meta_data, created_at, updated_at, 
--     role, aud, confirmation_token
--   ) VALUES (
--     '00000000-0000-0000-0000-000000000000',
--     new_admin_id,
--     'admin@yourdomain.com', -- Change to your admin email
--     extensions.crypt('YourSecureAdminPassword123!', extensions.gen_salt('bf')), -- Change to your admin password
--     now(),
--     '{"provider": "email", "providers": ["email"]}'::jsonb,
--     '{"display_name": "Main Admin", "role": "admin", "requires_password_reset": false}'::jsonb,
--     now(),
--     now(),
--     'authenticated',
--     'authenticated',
--     ''
--   );
-- END $$;
