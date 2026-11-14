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
