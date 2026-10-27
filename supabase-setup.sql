-- 아워로그 서버 저장 설정 (One Phrase와 같은 Supabase 프로젝트에서 1회 실행)
-- 기록 테이블
create table if not exists public.hourlog_entries (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  date date not null,
  mode text not null default 'direct',
  start_time text not null default '',
  end_time text not null default '',
  break_min int not null default 0,
  minutes int not null,
  note text not null default '',
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);

-- 설정 + 삭제 표시 테이블
create table if not exists public.hourlog_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  week_start int not null default 3,
  cap_hours numeric not null default 30,
  deleted_ids jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

-- 본인 기록만 접근 가능하게 (RLS)
alter table public.hourlog_entries enable row level security;
alter table public.hourlog_settings enable row level security;

drop policy if exists "hourlog_entries_own" on public.hourlog_entries;
create policy "hourlog_entries_own" on public.hourlog_entries
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "hourlog_settings_own" on public.hourlog_settings;
create policy "hourlog_settings_own" on public.hourlog_settings
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
