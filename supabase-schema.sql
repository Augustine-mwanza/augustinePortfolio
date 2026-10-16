-- Run this in the Supabase SQL Editor to create the portfolio project store.
create table if not exists public.portfolio_projects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  category text not null default 'creative',
  category_label text not null default 'Creative Work',
  icon text not null default 'fa-code',
  image_url text,
  project_url text,
  tags text[] not null default '{}',
  published boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.portfolio_projects enable row level security;

drop policy if exists "Published projects are visible to everyone" on public.portfolio_projects;
create policy "Published projects are visible to everyone"
  on public.portfolio_projects for select
  to anon, authenticated
  using (published or (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Only admins can insert projects" on public.portfolio_projects;
create policy "Only admins can insert projects"
  on public.portfolio_projects for insert
  to authenticated
  with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Only admins can update projects" on public.portfolio_projects;
create policy "Only admins can update projects"
  on public.portfolio_projects for update
  to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
  with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Only admins can delete projects" on public.portfolio_projects;
create policy "Only admins can delete projects"
  on public.portfolio_projects for delete
  to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

grant select on public.portfolio_projects to anon, authenticated;
grant insert, update, delete on public.portfolio_projects to authenticated;

-- Initial project content. Safe to run more than once.
insert into public.portfolio_projects (title, description, category, category_label, icon, image_url, tags, sort_order)
select seed.title, seed.description, seed.category, seed.category_label, seed.icon, seed.image_url, seed.tags, seed.sort_order
from (values
  ('Mathematical & Numerical Modeling Suite', 'Python and Jupyter notebook scripts analyzing differential equations, population dynamics, and numerical approximations.', 'math', 'Math & Modeling', 'fa-chart-line', null::text, array['Python','Jupyter','NumPy','Pandas','Matplotlib','SciPy','SymPy'], 1),
  ('Number Representation in Computers', 'A Jupyter notebook exploring how integers are represented using fixed-width binary formats, including unsigned and signed two''s-complement values.', 'math', 'Math & Computing', 'fa-microchip', 'number-representation-project.png', array['Python','Jupyter','Computer Science'], 2),
  ('Space Planning & Furniture Layout Visualizer', 'Interactive grid tool for calculating material requirements, board cutting optimizations, and spatial furniture fitting.', 'woodwork', 'Joinery & Space', 'fa-border-all', null::text, array['HTML5/JS','Geometry','Optimization'], 3),
  ('Custom Furniture & Woodworking Showcase', 'Precision joinery projects engineered for custom residential and commercial interiors at Timber World Limited.', 'woodwork', 'Craftsmanship', 'fa-couch', 'crafting-cabinet.jpg', array['Joinery','Furniture Design','Measurements'], 4),
  ('Image Processing & Vision Analysis Tools', 'OpenCV Python scripts designed for edge detection, shape feature extraction, and automated surface defect analysis.', 'vision', 'Computer Vision', 'fa-eye', null::text, array['Python','OpenCV','Feature Analysis'], 5),
  ('Professional Profile Portrait', 'A personal branding portrait created to present a clear and professional visual identity across portfolio and career materials.', 'creative', 'Creative Work', 'fa-camera', 'profile-project.jpg', array['Photography','Branding'], 6)
) as seed(title, description, category, category_label, icon, image_url, tags, sort_order)
where not exists (
  select 1 from public.portfolio_projects existing where existing.title = seed.title
);
