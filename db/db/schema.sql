-- Supabase DDL – Auto-Resale Store
-- run: supabase db push

create extension if not exists "pgcrypto";

-- 1 users (Supabase Auth manages insert)
create table if not exists public.users (
  id            uuid primary key default gen_random_uuid(),
  email         text,
  referral_code text unique,
  created_at    timestamptz default now()
);

-- 2 products
create table if not exists public.products (
  id          uuid primary key default gen_random_uuid(),
  name        text,
  price       numeric(10,2),
  description text,
  image_url   text,
  vendor      text,          -- 'temu' or local
  created_at  timestamptz default now()
);

-- 3 inventory
create table if not exists public.inventory (
  product_id  uuid references public.products(id) on delete cascade,
  stock       int  default 0,
  last_seen_at timestamptz default now(),
  primary key (product_id)
);

-- 4 orders
create type public.order_status as enum ('pending','paid','fulfilled');
create table if not exists public.orders (
  id                 uuid primary key default gen_random_uuid(),
  user_id            uuid references public.users(id),
  stripe_session_id  text,
  status             public.order_status default 'pending',
  total              numeric(10,2),
  created_at         timestamptz default now()
);

-- 5 order_items
create table if not exists public.order_items (
  order_id   uuid references public.orders(id) on delete cascade,
  product_id uuid references public.products(id),
  qty        int,
  unit_price numeric(10,2),
  primary key (order_id, product_id)
);

-- 6 coupons
create table if not exists public.coupons (
  id            uuid primary key default gen_random_uuid(),
  code          text unique,
  percent_off   int,
  expires_at    timestamptz,
  usage_count   int default 0
);

-- 7 referrals
create table if not exists public.referrals (
  id                uuid primary key default gen_random_uuid(),
  referrer_user_id  uuid references public.users(id),
  referred_user_id  uuid references public.users(id),
  reward_given      bool default false,
  created_at        timestamptz default now()
);

-- ---------- Row-Level Security ----------
alter table public.users      enable row level security;
alter table public.orders     enable row level security;
alter table public.order_items enable row level security;

-- User can see / edit only their row
create policy "Users own row"
  on public.users
  for select using ( auth.uid() = id );

-- Orders visible to owner
create policy "Own orders" on public.orders
  for select using ( auth.uid() = user_id );

create policy "Own order_items" on public.order_items
  for select using (
    auth.uid() in (select user_id from public.orders where id = order_id)
  );
