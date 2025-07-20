-- Seed data – demo products
insert into public.products (name, price, description, image_url, vendor)
values
 ('Hoodie',   49.00, 'Cozy streetwear hoodie',  '/img/hoodie.png', 'temu'),
 ('Cap',      19.00, 'Adjustable snap-back cap','/img/cap.png',    'temu'),
 ('Sneakers', 79.00, 'Urban sneakers',          '/img/shoe.png',   'temu');
