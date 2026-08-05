-- 09_customers.sql
-- Managed Customers / Shops Master Table and Approval Policies

CREATE TABLE IF NOT EXISTS public.customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  region TEXT NOT NULL,
  township TEXT NOT NULL,
  address TEXT,
  phone TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'approved' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.customers
ADD COLUMN IF NOT EXISTS region TEXT NOT NULL DEFAULT 'Yangon Region',
ADD COLUMN IF NOT EXISTS township TEXT NOT NULL DEFAULT 'Kamayut';

-- Enable RLS for Customers
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

-- Customers Policies
-- Read: Authenticated users can view approved customers. Admin & creator can view pending/rejected.
CREATE POLICY "Allow read access to customers"
ON public.customers FOR SELECT
TO authenticated
USING (
  status = 'approved'
  OR created_by = auth.uid()
  OR EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Insert: Admins and Sales Staff can create customers
CREATE POLICY "Allow insert access to customers"
ON public.customers FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND (role = 'admin' OR role = 'sales_staff')
  )
);

-- Update: Admins can update customer status (approve/reject) and details
CREATE POLICY "Allow update access to customers for admins"
ON public.customers FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Delete: Admins only
CREATE POLICY "Allow delete access to customers for admins"
ON public.customers FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Add customer_id foreign key column to orders table if not existing
ALTER TABLE public.orders
ADD COLUMN IF NOT EXISTS customer_id UUID REFERENCES public.customers(id) ON DELETE SET NULL;
