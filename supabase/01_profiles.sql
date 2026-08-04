-- 1. Create Profile Table
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  role TEXT NOT NULL CHECK (role IN ('admin', 'warehouse_manager', 'sales_staff')),
  display_name TEXT,
  requires_password_reset BOOLEAN DEFAULT true NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Helper security definer function to check if the current user is an admin.
-- Running as SECURITY DEFINER bypasses RLS on the profiles table, preventing infinite recursion.
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create Row Level Security (RLS) Policies
-- A. Read access: Any authenticated user can read profiles (needed for display names, role checks)
CREATE POLICY "Allow read access for authenticated users" 
ON public.profiles FOR SELECT 
TO authenticated 
USING (true);

-- B. Update access: Users can update their own profile (needed for resetting passwords, changing name)
CREATE POLICY "Allow users to update their own profile" 
ON public.profiles FOR UPDATE 
TO authenticated 
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- C. Full admin access: Admin role has full rights
CREATE POLICY "Allow admins full access on profiles" 
ON public.profiles FOR ALL 
TO authenticated 
USING (public.is_admin());
