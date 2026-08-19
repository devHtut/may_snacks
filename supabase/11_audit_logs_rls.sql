-- 11_audit_logs_rls.sql
-- Fix Row Level Security policies on audit_logs table for all authenticated roles

-- 1. Ensure RLS is enabled
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- 2. Drop existing restrictive policies
DROP POLICY IF EXISTS "Allow read access to audit logs for admins only" ON public.audit_logs;
DROP POLICY IF EXISTS "Allow insert access to audit logs for authenticated users" ON public.audit_logs;
DROP POLICY IF EXISTS "Allow all access to audit logs for authenticated users" ON public.audit_logs;

-- 3. Create full RLS policies for authenticated users
CREATE POLICY "Allow select for authenticated users on audit logs"
ON public.audit_logs FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Allow insert for authenticated users on audit logs"
ON public.audit_logs FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Allow update for authenticated users on audit logs"
ON public.audit_logs FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);
