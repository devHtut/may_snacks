-- 08_audit_and_user_status.sql
-- User status toggles, Audit Logs, and Disposal approval RPCs

-- 1. Add is_active column to profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true NOT NULL;

-- 2. Create Audit Logs Table
CREATE TABLE IF NOT EXISTS public.audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  description TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for Audit Logs
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Audit Logs Policies
CREATE POLICY "Allow read access to audit logs for admins only"
ON public.audit_logs FOR SELECT
TO authenticated
USING (public.is_admin());

CREATE POLICY "Allow insert access to audit logs for authenticated users"
ON public.audit_logs FOR INSERT
TO authenticated
WITH CHECK (true);


-- 3. Security Definer RPC for Admin to toggle user active status
CREATE OR REPLACE FUNCTION public.toggle_user_status(
  target_user_id UUID,
  status BOOLEAN
) RETURNS VOID AS $$
BEGIN
  -- Security check: Ensure the caller is an Admin
  IF NOT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Only administrators can toggle user statuses.';
  END IF;

  -- Ensure we don't deactivate ourselves (the current admin)
  IF target_user_id = auth.uid() THEN
    RAISE EXCEPTION 'Administrators cannot deactivate their own accounts.';
  END IF;

  -- Update profiles active state
  UPDATE public.profiles
  SET is_active = status,
      updated_at = now()
  WHERE id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 4. Security Definer RPC for Admin to approve or reject disposal requests
CREATE OR REPLACE FUNCTION public.process_disposal_request(
  target_disposal_id UUID,
  decision TEXT
) RETURNS VOID AS $$
DECLARE
  disp_batch_id UUID;
  disp_qty INTEGER;
  disp_status TEXT;
BEGIN
  -- Security check: Ensure the caller is an Admin
  IF NOT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Only administrators can approve or reject disposal requests.';
  END IF;

  -- Get request info
  SELECT batch_id, quantity, status 
  INTO disp_batch_id, disp_qty, disp_status
  FROM public.disposals
  WHERE id = target_disposal_id;

  IF disp_status != 'pending' THEN
    RAISE EXCEPTION 'This disposal request is already processed. Current status: %', disp_status;
  END IF;

  IF decision = 'approved' THEN
    -- Deduct quantity from the corresponding batch
    UPDATE public.batches
    SET quantity = GREATEST(0, quantity - disp_qty)
    WHERE id = disp_batch_id;

    -- Update disposal status to approved
    UPDATE public.disposals
    SET status = 'approved'
    WHERE id = target_disposal_id;

  ELSIF decision = 'rejected' THEN
    -- Update disposal status to rejected
    UPDATE public.disposals
    SET status = 'rejected'
    WHERE id = target_disposal_id;

  ELSE
    RAISE EXCEPTION 'Invalid decision. Must be approved or rejected.';
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
