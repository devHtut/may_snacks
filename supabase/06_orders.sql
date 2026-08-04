-- 06_orders.sql
-- Orders and Order Items Tables

-- 1. Create Orders Table
CREATE TABLE IF NOT EXISTS public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_name TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'packed', 'delivered')),
  sales_staff_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for Orders
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Orders Policies
-- Read: Admins, Warehouse Managers can read all. Sales Staff can only read their own orders.
CREATE POLICY "Allow read access to orders based on role"
ON public.orders FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND (role = 'admin' OR role = 'warehouse_manager')
  )
  OR sales_staff_id = auth.uid()
);

-- Insert: Admins and Sales Staff can create orders
CREATE POLICY "Allow insert access to orders for admins and sales staff"
ON public.orders FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND (role = 'admin' OR role = 'sales_staff')
  )
  AND (sales_staff_id = auth.uid() OR public.is_admin())
);

-- Update: Admins can update all. Warehouse managers can update order status (fulfill)
CREATE POLICY "Allow update access to orders for authorized roles"
ON public.orders FOR UPDATE
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

-- Delete: Admins, and Sales Staff can cancel their own pending orders
CREATE POLICY "Allow delete access to orders"
ON public.orders FOR DELETE
TO authenticated
USING (
  (sales_staff_id = auth.uid() AND status = 'pending') OR public.is_admin()
);

CREATE TABLE IF NOT EXISTS public.order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  product_name TEXT,
  product_price NUMERIC
);

ALTER TABLE public.order_items 
ADD COLUMN IF NOT EXISTS product_name TEXT,
ADD COLUMN IF NOT EXISTS product_price NUMERIC;

-- Enable RLS for Order Items
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- Order Items Policies
-- Read: Inherit read permission from order table check
CREATE POLICY "Allow read access to order items"
ON public.order_items FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.orders
    WHERE id = order_id
  )
);

-- Insert: Inherit insert permission from order table check
CREATE POLICY "Allow insert access to order items"
ON public.order_items FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.orders
    WHERE id = order_id
  )
);

-- Update: Inherit update check
CREATE POLICY "Allow update access to order items"
ON public.order_items FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.orders
    WHERE id = order_id
  )
);

-- Delete: Inherit delete check
CREATE POLICY "Allow delete access to order items"
ON public.order_items FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.orders
    WHERE id = order_id
  )
);
