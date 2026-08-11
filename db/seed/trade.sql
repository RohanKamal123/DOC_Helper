-- Seed data for service_id = 'trade' (Trade License).
-- Researched 2026-08-08 against official DSCC/DNCC pages (dscc.gov.bd,
-- dncc.gov.bd) plus the national bangladesh.gov.bd trade-license page and
-- wehelp.smef.gov.bd (SME Foundation) process guides. There is no single
-- national authority — trade license is issued by whichever City
-- Corporation / Pourashova / Union Parishad covers the business address,
-- so the exact fee and process vary by locality; figures below are the
-- most commonly corroborated general structure, not a single fixed number.

INSERT INTO sources (url, title, publisher, last_verified_date, notes) VALUES
  ('https://dscc.gov.bd/pages/static-pages/6922dba2933eb65569e0b707', 'ট্রেড লাইসেন্স ইস্যু ও নবায়ন পদ্ধতি', 'dscc.gov.bd', '2026-08-08', 'Dhaka South City Corporation — official process page.'),
  ('https://dncc.gov.bd/pages/static-pages/6922e06d933eb65569e27049', 'ট্রেড লাইসেন্স ইস্যু ও নবায়ন পদ্ধতি', 'dncc.gov.bd', '2026-08-08', 'Dhaka North City Corporation — official process page.'),
  ('https://wehelp.smef.gov.bd/information-details/137', 'সিটি কর্পোরেশন থেকে ট্রেড লাইসেন্স প্রাপ্তির ধাপ সমূহ', 'wehelp.smef.gov.bd', '2026-08-08',
   'SME Foundation (government) process guide. Fee figures (10 BDT application fee; 100-40,000 BDT license fee depending on business type/scale, plus 30% signboard tax and VAT/source tax) are cross-referenced from secondary legal-service sources, not independently re-verified against a fee schedule document — treat as a general range, confirm the exact figure for your business type/location with the local office.');

-- Offices: no single national office — trade license is issued locally.
-- Two real, named offices are seeded (Dhaka North & South City
-- Corporations) to exercise find_nearest_office for Dhaka; a national
-- placeholder covers everywhere else until Phase 3+ adds more.
INSERT INTO offices (service_id, office_level, name_en, name_bn, division, district, address_en, address_bn, source_id)
SELECT 'trade', 'national',
  'Your local City Corporation / Pourashova / Union Parishad',
  'আপনার স্থানীয় সিটি কর্পোরেশন / পৌরসভা / ইউনিয়ন পরিষদ',
  NULL, NULL,
  'Trade license is issued by whichever local authority covers your business address — there is no single national office.',
  'ব্যবসার ঠিকানা অনুযায়ী স্থানীয় কর্তৃপক্ষ ট্রেড লাইসেন্স ইস্যু করে — কোনো একক জাতীয় অফিস নেই।',
  id
FROM sources WHERE url = 'https://wehelp.smef.gov.bd/information-details/137';

INSERT INTO offices (service_id, office_level, name_en, name_bn, division, district, address_en, address_bn, source_id)
SELECT 'trade', 'district', 'Dhaka South City Corporation (DSCC)', 'ঢাকা দক্ষিণ সিটি কর্পোরেশন', 'Dhaka', 'Dhaka',
  'For businesses in the DSCC area (see dscc.gov.bd for ward boundaries).', 'ডিএসসিসি এলাকার ব্যবসার জন্য (ওয়ার্ড সীমানার জন্য dscc.gov.bd দেখুন)।', id
FROM sources WHERE url = 'https://dscc.gov.bd/pages/static-pages/6922dba2933eb65569e0b707';

INSERT INTO offices (service_id, office_level, name_en, name_bn, division, district, address_en, address_bn, source_id)
SELECT 'trade', 'district', 'Dhaka North City Corporation (DNCC)', 'ঢাকা উত্তর সিটি কর্পোরেশন', 'Dhaka', 'Dhaka',
  'For businesses in the DNCC area (see dncc.gov.bd for ward boundaries).', 'ডিএনসিসি এলাকার ব্যবসার জন্য (ওয়ার্ড সীমানার জন্য dncc.gov.bd দেখুন)।', id
FROM sources WHERE url = 'https://dncc.gov.bd/pages/static-pages/6922e06d933eb65569e27049';

-- Fees
INSERT INTO fees (service_id, fee_type, amount_bdt, unit, notes_en, notes_bn, source_id)
SELECT 'trade', v.fee_type, v.amount_bdt, v.unit, v.notes_en, v.notes_bn, s.id
FROM (VALUES
  ('application_fee', 10, 'per application', 'Fixed application fee.', 'নির্ধারিত আবেদন ফি।'),
  ('license_fee_minimum', 100, 'per year (varies)', 'License fee starts around this figure and scales up to ~40,000 BDT depending on business type/scale — plus a 30% signboard tax and applicable VAT/source tax. Confirm the exact figure for your business category with the local office.', 'লাইসেন্স ফি প্রায় এই অংক থেকে শুরু হয়ে ব্যবসার ধরন/আকার অনুযায়ী ~৪০,০০০ টাকা পর্যন্ত হতে পারে — এর সাথে ৩০% সাইনবোর্ড কর ও প্রযোজ্য ভ্যাট/উৎস কর যুক্ত হয়। আপনার ব্যবসার শ্রেণির সঠিক অংক স্থানীয় অফিসে নিশ্চিত করুন।')
) AS v(fee_type, amount_bdt, unit, notes_en, notes_bn)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://wehelp.smef.gov.bd/information-details/137') AS s;

-- Required documents
INSERT INTO required_documents (service_id, document_en, document_bn, is_mandatory, applies_to, sort_order, source_id)
SELECT 'trade', v.document_en, v.document_bn, v.is_mandatory, v.applies_to, v.sort_order, s.id
FROM (VALUES
  ('Completed application form', 'পূরণকৃত আবেদনপত্র', true, 'all', 1),
  ('NID copy of the business owner', 'ব্যবসার মালিকের এনআইডি কপি', true, 'all', 2),
  ('2-3 passport-size photographs', '২-৩ কপি পাসপোর্ট সাইজ ছবি', true, 'all', 3),
  ('Proof of business address (rent receipt/agreement or holding tax payment receipt)', 'ব্যবসার ঠিকানার প্রমাণ (ভাড়ার রশিদ/চুক্তি বা হোল্ডিং ট্যাক্স রশিদ)', true, 'all', 4),
  ('Utility bill copy (electricity/gas/water)', 'ইউটিলিটি বিলের কপি (বিদ্যুৎ/গ্যাস/পানি)', true, 'all', 5),
  ('TIN certificate — for limited companies and other taxpayers', 'টিআইএন সার্টিফিকেট — লিমিটেড কোম্পানি ও অন্যান্য করদাতাদের জন্য', false, 'all', 6)
) AS v(document_en, document_bn, is_mandatory, applies_to, sort_order)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://wehelp.smef.gov.bd/information-details/137') AS s;

-- Steps
INSERT INTO steps (service_id, step_number, title_en, title_bn, is_online, source_id)
SELECT 'trade', v.step_number, v.title_en, v.title_bn, v.is_online, s.id
FROM (VALUES
  (1, 'Collect the application form from your local City Corporation/Pourashova/Union Parishad office (or its website, where available)', 'আপনার স্থানীয় সিটি কর্পোরেশন/পৌরসভা/ইউনিয়ন পরিষদ অফিস (বা সম্ভব হলে ওয়েবসাইট) থেকে আবেদনপত্র সংগ্রহ করুন', false),
  (2, 'Submit the completed form with required documents to the taxation officer', 'পূরণকৃত ফরম প্রয়োজনীয় কাগজপত্রসহ ট্যাক্সেশন অফিসারের কাছে জমা দিন', false),
  (3, 'A sanitary inspector may conduct a site inspection, depending on business type', 'ব্যবসার ধরন অনুযায়ী স্যানিটারি ইন্সপেক্টর সাইট পরিদর্শন করতে পারেন', false),
  (4, 'Deposit the applicable fee at the designated bank or office', 'প্রযোজ্য ফি নির্ধারিত ব্যাংক বা অফিসে জমা দিন', false),
  (5, 'Receive the trade license (City Corporation: ~3-5 working days; Pourashova: ~1-4 working days)', 'ট্রেড লাইসেন্স গ্রহণ করুন (সিটি কর্পোরেশন: ~৩-৫ কর্মদিবস; পৌরসভা: ~১-৪ কর্মদিবস)', false)
) AS v(step_number, title_en, title_bn, is_online)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://wehelp.smef.gov.bd/information-details/137') AS s;

-- Online portals (informational — not confirmed as full online application systems)
INSERT INTO online_portals (service_id, portal_name, url, description_en, description_bn) VALUES
  ('trade', 'Dhaka South City Corporation — Trade License Info', 'https://dscc.gov.bd/pages/static-pages/6922dba2933eb65569e0b707', 'Process information for DSCC-area businesses.', 'ডিএসসিসি এলাকার ব্যবসার জন্য প্রক্রিয়ার তথ্য।'),
  ('trade', 'Dhaka North City Corporation — Trade License Info', 'https://dncc.gov.bd/pages/static-pages/6922e06d933eb65569e27049', 'Process information for DNCC-area businesses.', 'ডিএনসিসি এলাকার ব্যবসার জন্য প্রক্রিয়ার তথ্য।');
