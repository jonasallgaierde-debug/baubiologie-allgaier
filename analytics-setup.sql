-- Run once in the SQL Editor of project gwhiebjsemhjduzwjigi.
create table if not exists public.ba_traffic_admins(user_id uuid primary key references auth.users(id) on delete cascade);
alter table public.ba_traffic_admins enable row level security;
revoke all on public.ba_traffic_admins from anon, authenticated;
grant select on public.ba_traffic_admins to authenticated;
create policy "Own admin membership" on public.ba_traffic_admins for select to authenticated using(user_id=(select auth.uid()));
create table if not exists public.ba_traffic_events(
 id uuid primary key default gen_random_uuid(),
 created_at timestamptz not null default now(),
 event text not null check(event in ('pageview','phone','email','booking','instagram')),
 device text not null check(device in ('Mobil','Tablet','Desktop')),
 source text not null check(char_length(source)<=120)
);
alter table public.ba_traffic_events enable row level security;
revoke all on public.ba_traffic_events from anon, authenticated;
grant insert(event,device,source) on public.ba_traffic_events to anon;
grant select on public.ba_traffic_events to authenticated;
create policy "Public event submission" on public.ba_traffic_events for insert to anon with check(true);
create policy "Admins read statistics" on public.ba_traffic_events for select to authenticated using(exists(select 1 from public.ba_traffic_admins where user_id=(select auth.uid())));
create index ba_traffic_date on public.ba_traffic_events(created_at);
-- Retention: run periodically in SQL Editor or schedule using Supabase Cron:
-- delete from public.ba_traffic_events where created_at < now()-interval '90 days';
-- After creating your user in Authentication > Users, grant access:
-- insert into public.ba_traffic_admins(user_id) select id from auth.users where email='YOUR_ADMIN_EMAIL';
