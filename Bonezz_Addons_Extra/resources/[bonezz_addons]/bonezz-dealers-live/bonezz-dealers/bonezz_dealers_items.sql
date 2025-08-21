-- bonezz-dealers: item bootstrap (INSERT IGNORE to avoid duplicates)
-- If your items schema is (name, label, weight, description) this will work.
-- If you are on newer qb-core with JSON columns, manage via shared/items.lua instead.

INSERT IGNORE INTO items (name, label, weight, description) VALUES
('xanax', 'Xanax', 1, 'A bar of relief'),
('oxy', 'Oxycodone', 1, 'Prescription painkiller'),
('adderall', 'Adderall', 1, 'Keeps you focused'),
('lean', 'Lean', 1, 'Purple drank cup'),
('weed_seed', 'Weed Seed', 1, 'Can be planted'),
('weed_bud', 'Weed Bud', 1, 'Unprocessed bud'),
('weed_bag', 'Bag of Weed', 1, 'Bagged for sale'),
('joint', 'Joint', 1, 'Pre-rolled smoke'),
('coke_leaf', 'Coca Leaf', 1, 'Raw coca leaf'),
('coke_paste', 'Cocaine Paste', 1, 'Intermediate product'),
('coke_brick', 'Coke Brick', 1, 'Kilo brick'),
('coke_baggy', 'Coke Baggy', 1, 'Baggy ready to sell'),
('meth_raw', 'Raw Meth', 1, 'Unprocessed crystals'),
('meth_bag', 'Bag of Meth', 1, 'Baggy of meth ready for sale');
