create or replace function update_username(new_username text)
returns void as $$
begin
  update public.profiles
  set username = new_username
  where id = auth.uid();
end;
$$ language plpgsql;