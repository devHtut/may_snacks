-- 10_reserved_stocks.sql
-- Reserved Stocks Table for Holding Stock between Order Placement and Manager Fulfillment

CREATE TABLE IF NOT EXISTS public.reserved_stocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
  batch_id UUID REFERENCES public.batches(id) ON DELETE SET NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'fulfilled', 'released')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for Reserved Stocks
ALTER TABLE public.reserved_stocks ENABLE ROW LEVEL SECURITY;

-- Reserved Stocks Policies
-- 1. Read: Authenticated users can read reserved stocks
CREATE POLICY "Allow read access to reserved stocks for authenticated users"
ON public.reserved_stocks FOR SELECT
TO authenticated
USING (true);

-- 2. Insert: Authenticated users (Sales staff, Admins, Warehouse managers) can insert
CREATE POLICY "Allow insert access to reserved stocks for authenticated users"
ON public.reserved_stocks FOR INSERT
TO authenticated
WITH CHECK (true);

-- 3. Update: Authenticated users can update status ('fulfilled', 'released')
CREATE POLICY "Allow update access to reserved stocks for authenticated users"
ON public.reserved_stocks FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- 4. Delete: Authenticated users can delete reserved stocks
CREATE POLICY "Allow delete access to reserved stocks for authenticated users"
ON public.reserved_stocks FOR DELETE
TO authenticated
USING (true);
