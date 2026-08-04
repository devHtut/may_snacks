-- 07_warehouse_ops.sql
-- Disposal Requests (Damage Write-Offs) and Physical Stock Audits

-- 1. Create Disposal Requests Table
CREATE TABLE IF NOT EXISTS public.disposals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
  batch_id UUID REFERENCES public.batches(id) ON DELETE CASCADE NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  reason TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  requested_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for Disposals
ALTER TABLE public.disposals ENABLE ROW LEVEL SECURITY;

-- Disposal Policies
-- Read: Admins and Warehouse Managers can read all disposals
CREATE POLICY "Allow read access to disposals for admins and warehouse managers"
ON public.disposals FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND (role = 'admin' OR role = 'warehouse_manager')
  )
);

-- Insert: Admins and Warehouse Managers can insert disposal requests
CREATE POLICY "Allow insert access to disposals for admins and warehouse managers"
ON public.disposals FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND (role = 'admin' OR role = 'warehouse_manager')
  )
  AND (requested_by = auth.uid() OR public.is_admin())
);

-- Update: Admins can update all (approve/reject). Warehouse managers can only update pending ones they requested (e.g. edit before approval)
CREATE POLICY "Allow update access to disposals for authorized roles"
ON public.disposals FOR UPDATE
TO authenticated
USING (
  public.is_admin()
  OR (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'warehouse_manager'
    )
    AND requested_by = auth.uid()
    AND status = 'pending'
  )
)
WITH CHECK (
  public.is_admin()
  OR (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'warehouse_manager'
    )
    AND requested_by = auth.uid()
    AND status = 'pending'
  )
);

-- Delete: Admins only
CREATE POLICY "Allow delete access to disposals for admins only"
ON public.disposals FOR DELETE
TO authenticated
USING (public.is_admin());


-- 2. Create Physical Stock Audits Table
CREATE TABLE IF NOT EXISTS public.physical_audits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
  batch_id UUID REFERENCES public.batches(id) ON DELETE CASCADE NOT NULL,
  system_quantity INTEGER NOT NULL CHECK (system_quantity >= 0),
  physical_quantity INTEGER NOT NULL CHECK (physical_quantity >= 0),
  discrepancy INTEGER NOT NULL,
  notes TEXT,
  audited_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for Physical Audits
ALTER TABLE public.physical_audits ENABLE ROW LEVEL SECURITY;

-- Physical Audit Policies
-- Read: Admins and Warehouse Managers can read all audits
CREATE POLICY "Allow read access to audits for admins and warehouse managers"
ON public.physical_audits FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND (role = 'admin' OR role = 'warehouse_manager')
  )
);

-- Insert: Admins and Warehouse Managers can log audits
CREATE POLICY "Allow insert access to audits for admins and warehouse managers"
ON public.physical_audits FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND (role = 'admin' OR role = 'warehouse_manager')
  )
  AND (audited_by = auth.uid() OR public.is_admin())
);
