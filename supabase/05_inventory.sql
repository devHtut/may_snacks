-- 05_inventory.sql
-- Products (Master Data) and Batches Tables

-- 1. Create Products Table
CREATE TABLE IF NOT EXISTS public.products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  sku TEXT NOT NULL UNIQUE,
  price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for Products
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Product Policies
CREATE POLICY "Allow read access to products for authenticated users"
ON public.products FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Allow full access to products for admins"
ON public.products FOR ALL
TO authenticated
USING (public.is_admin());

-- 2. Create Batches Table
CREATE TABLE IF NOT EXISTS public.batches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
  batch_number TEXT NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity >= 0),
  initial_quantity INTEGER NOT NULL CHECK (initial_quantity >= quantity),
  expiry_date DATE NOT NULL,
  received_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for Batches
ALTER TABLE public.batches ENABLE ROW LEVEL SECURITY;

-- Batch Policies
CREATE POLICY "Allow read access to batches for authenticated users"
ON public.batches FOR SELECT
TO authenticated
USING (true);

-- Allow both admins and warehouse managers to insert new batches (Stock In)
CREATE POLICY "Allow insert access to batches for admins and warehouse managers"
ON public.batches FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND (role = 'admin' OR role = 'warehouse_manager')
  )
);

-- Allow both admins and warehouse managers to update batches (e.g. stock deduction on order fulfillment)
CREATE POLICY "Allow update access to batches for admins and warehouse managers"
ON public.batches FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND (role = 'admin' OR role = 'warehouse_manager')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND (role = 'admin' OR role = 'warehouse_manager')
  )
);

-- Allow full access to admins only
CREATE POLICY "Allow delete access to batches for admins only"
ON public.batches FOR DELETE
TO authenticated
USING (public.is_admin());

-- Seed initial products for May Snacks
INSERT INTO public.products (name, sku, price) VALUES
  ('Butter Bread', 'MS-BUTTER-BREAD', 1500.00),
  ('Crispy Rusks (Mini)', 'MS-MINI-RUSK', 1200.00),
  ('Chocolate Cake Slice', 'MS-CHOCO-CAKE', 2000.00),
  ('Vanilla Cookies Pack', 'MS-VANILLA-COOKIE', 2500.00)
ON CONFLICT (sku) DO NOTHING;
