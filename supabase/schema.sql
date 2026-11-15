-- AstroCare online database. Run once in the Supabase SQL Editor.
 
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  role text not null,
  email text not null,
  created_at timestamptz not null default now()
);
 
create table if not exists public.measurements (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  indicator text not null,
  value double precision not null,
  at timestamptz not null
);
 
create table if not exists public.alerts (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  indicator text not null,
  value double precision not null,
  level text not null,
  cause text not null,
  rule_id text not null default '',
  status text not null,
  created_at timestamptz not null
);
 
alter table public.profiles enable row level security;
alter table public.measurements enable row level security;
alter table public.alerts enable row level security;
 
-- Each astronaut can read and write only their own rows.
create policy "own profile" on public.profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);
 
create policy "own measurements" on public.measurements
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own alerts" on public.alerts
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
