-- =====================================================================
-- Tài khoản mẫu để thử ứng dụng (chạy trong Supabase → SQL Editor).
-- Chạy SAU schema.sql và policies.sql. Chạy lại nhiều lần cũng không sao.
--
--   admin@giaidieu.vn  / 123456   → Quản trị viên
--   user@giaidieu.vn   / 123456   → Người dùng
--   lan@giaidieu.vn    / 123456   → Người dùng
--   khoa@giaidieu.vn   / 123456   → Người dùng (đã bị khóa, để thử chức năng khóa)
--
-- Email được xác nhận sẵn nên không cần bấm link trong hộp thư.
-- CHỈ dùng cho môi trường thử nghiệm – đổi mật khẩu trước khi đưa vào dùng thật.
-- =====================================================================

create or replace function pg_temp.create_sample_user(
  p_email text,
  p_password text,
  p_display_name text
) returns uuid
language plpgsql
as $$
declare
  v_id uuid;
begin
  select id into v_id from auth.users where email = p_email;
  if v_id is not null then
    return v_id; -- đã có thì bỏ qua
  end if;

  v_id := gen_random_uuid();

  insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
    created_at, updated_at,
    confirmation_token, recovery_token, email_change_token_new, email_change
  ) values (
    '00000000-0000-0000-0000-000000000000', v_id, 'authenticated', 'authenticated',
    p_email, extensions.crypt(p_password, extensions.gen_salt('bf')),
    now(), '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object('display_name', p_display_name),
    now(), now(),
    '', '', '', ''
  );

  insert into auth.identities (
    id, user_id, provider_id, provider, identity_data,
    last_sign_in_at, created_at, updated_at
  ) values (
    gen_random_uuid(), v_id, v_id::text, 'email',
    jsonb_build_object('sub', v_id::text, 'email', p_email, 'email_verified', true),
    now(), now(), now()
  );

  return v_id; -- trigger on_auth_user_created tự tạo dòng public.profiles
end;
$$;

select pg_temp.create_sample_user('admin@giaidieu.vn', '123456', 'Minh Anh');
select pg_temp.create_sample_user('user@giaidieu.vn',  '123456', 'Người dùng thử');
select pg_temp.create_sample_user('lan@giaidieu.vn',   '123456', 'Trần Lan');
select pg_temp.create_sample_user('khoa@giaidieu.vn',  '123456', 'Lê Khoa');

-- Bổ sung profile nếu tài khoản được tạo trước khi có trigger.
insert into public.profiles (id, email, display_name)
select u.id, u.email, coalesce(u.raw_user_meta_data ->> 'display_name', split_part(u.email, '@', 1))
from auth.users u
where u.email like '%@giaidieu.vn'
on conflict (id) do nothing;

-- Phân quyền / trạng thái.
-- Trigger protect_profile_columns chặn đổi role khi không có admin đăng nhập
-- (SQL Editor không có auth.uid()), nên tạm tắt trigger trong lúc cập nhật.
do $$
declare
  v_has_trigger boolean := exists (
    select 1 from pg_trigger
    where tgname = 'protect_profile_columns'
      and tgrelid = 'public.profiles'::regclass
  );
begin
  if v_has_trigger then
    alter table public.profiles disable trigger protect_profile_columns;
  end if;

  update public.profiles set role = 'admin', is_active = true where email = 'admin@giaidieu.vn';
  update public.profiles set is_active = false               where email = 'khoa@giaidieu.vn';

  if v_has_trigger then
    alter table public.profiles enable trigger protect_profile_columns;
  end if;
end;
$$;

-- Kiểm tra kết quả
select email, display_name, role, is_active from public.profiles
where email like '%@giaidieu.vn' order by role, email;
