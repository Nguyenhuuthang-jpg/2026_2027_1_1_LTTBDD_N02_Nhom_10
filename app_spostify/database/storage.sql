-- Bucket lưu file nhạc. Chạy trong Supabase SQL Editor, SAU schema.sql và policies.sql.
-- Bucket public: ai có link cũng nghe được (app phát nhạc bằng link audio_url).
-- Chỉ admin mới được tải lên / sửa / xóa file. Chạy lại nhiều lần cũng không sao.

insert into storage.buckets (id, name, public)
values ('songs', 'songs', true)
on conflict (id) do update set public = true;

drop policy if exists "songs bucket: admin tải lên" on storage.objects;
create policy "songs bucket: admin tải lên"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'songs' and public.is_admin());

drop policy if exists "songs bucket: admin sửa" on storage.objects;
create policy "songs bucket: admin sửa"
  on storage.objects for update to authenticated
  using (bucket_id = 'songs' and public.is_admin())
  with check (bucket_id = 'songs' and public.is_admin());

drop policy if exists "songs bucket: admin xóa" on storage.objects;
create policy "songs bucket: admin xóa"
  on storage.objects for delete to authenticated
  using (bucket_id = 'songs' and public.is_admin());
