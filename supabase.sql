-- Shadow Hábitos: tabla donde se guarda tu avance para sincronizar iPhone y compu.
-- Pégalo completo en Supabase → SQL Editor → New query → Run.

create table if not exists public.habitos (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  data       jsonb not null,
  updated_at timestamptz not null default now()
);

-- Seguridad por filas: cada usuario solo puede ver y cambiar su propia fila.
alter table public.habitos enable row level security;

drop policy if exists "leer lo mio"   on public.habitos;
drop policy if exists "crear lo mio"  on public.habitos;
drop policy if exists "editar lo mio" on public.habitos;

create policy "leer lo mio" on public.habitos
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "crear lo mio" on public.habitos
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "editar lo mio" on public.habitos
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

-- Permisos explícitos para usuarios con sesión iniciada; los anónimos no tienen acceso.
revoke all on public.habitos from anon;
grant select, insert, update on public.habitos to authenticated;
