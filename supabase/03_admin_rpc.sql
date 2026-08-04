-- 3. Security Definer RPC for Admin to create staff users (bypasses service_role client key requirement)
CREATE OR REPLACE FUNCTION public.create_staff_user(
  user_email TEXT,
  user_password TEXT,
  user_role TEXT,
  user_display_name TEXT
) RETURNS UUID AS $$
DECLARE
  new_user_id UUID;
  hashed_password TEXT;
BEGIN
  -- Security check: Ensure the caller is an Admin
  IF NOT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Only administrators can create staff accounts.';
  END IF;

  -- Check if user already exists
  IF EXISTS (SELECT 1 FROM auth.users WHERE email = user_email) THEN
    RAISE EXCEPTION 'A user with this email already exists.';
  END IF;

  -- Generate ID & Hash Password using extensions.crypt/bcrypt
  new_user_id := gen_random_uuid();
  hashed_password := extensions.crypt(user_password, extensions.gen_salt('bf'));

  -- Insert user into auth.users (Supabase Auth schema)
  -- We explicitly populate system token columns with empty strings and booleans with false
  -- to prevent Supabase GoTrue from throwing "Database error querying schema" due to NULL scans.
  INSERT INTO auth.users (
    instance_id, id, email, encrypted_password, email_confirmed_at, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at, 
    role, aud, confirmation_token, email_change, email_change_token_new,
    recovery_token, email_change_token_current, phone_change,
    phone_change_token, reauthentication_token, is_sso_user, is_anonymous
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    new_user_id,
    user_email,
    hashed_password,
    now(),
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    jsonb_build_object('display_name', user_display_name, 'role', user_role, 'requires_password_reset', true),
    now(),
    now(),
    'authenticated',
    'authenticated',
    '', -- confirmation_token
    '', -- email_change
    '', -- email_change_token_new
    '', -- recovery_token
    '', -- email_change_token_current
    '', -- phone_change
    '', -- phone_change_token
    '', -- reauthentication_token
    false, -- is_sso_user
    false -- is_anonymous
  );

  RETURN new_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Security Definer RPC for Admin to reset staff passwords and force password reset status
CREATE OR REPLACE FUNCTION public.reset_staff_password(
  target_user_id UUID,
  new_password TEXT
) RETURNS VOID AS $$
DECLARE
  hashed_password TEXT;
BEGIN
  -- Security check: Ensure the caller is an Admin
  IF NOT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Only administrators can reset staff passwords.';
  END IF;

  -- Hash password using extensions.crypt/bcrypt
  hashed_password := extensions.crypt(new_password, extensions.gen_salt('bf'));

  -- Update password in auth.users
  UPDATE auth.users
  SET encrypted_password = hashed_password,
      updated_at = now()
  WHERE id = target_user_id;

  -- Set requires_password_reset to true in profiles
  UPDATE public.profiles
  SET requires_password_reset = true,
      updated_at = now()
  WHERE id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
