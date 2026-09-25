-- Run this once in Supabase: Dashboard -> SQL Editor -> New query -> paste -> Run

create table readings (
  id bigint generated always as identity primary key,
  sensor_type text not null check (sensor_type in ('temperature','humidity','distance')),
  value numeric not null,
  unit text not null,
  user_id uuid references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

create index idx_readings_type_time on readings (sensor_type, created_at);

alter table readings enable row level security;

-- each signed-in user can only see their own readings
create policy "read own readings" on readings
  for select using (auth.uid() = user_id);

-- each signed-in user can only insert readings tagged as their own
create policy "insert own readings" on readings
  for insert with check (auth.uid() = user_id);
