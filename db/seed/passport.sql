-- Seed data for service_id = 'passport' (e-Passport).
-- Researched 2026-08-08. Primary fee source is a Bangladesh government
-- mission page (mofa.gov.bd), which independently corroborates the same
-- fee table published across many embassy/consulate sites — used here
-- because the main dip.gov.bd/epassport.gov.bd domains were not reliably
-- fetchable via automated tools during this research pass. Re-verify
-- against epassport.gov.bd before relying on exact fee figures.

INSERT INTO sources (url, title, publisher, last_verified_date, notes) VALUES
  ('https://wellington.mofa.gov.bd/pages/static-pages/%E0%A6%87-%E0%A6%AA%E0%A6%BE%E0%A6%B8%E0%A6%AA%E0%A7%8B%E0%A6%B0%E0%A7%8D%E0%A6%9F-%E0%A6%AB%E0%A6%BF-xkjhe4-696d9e012d35eac273b4fb16',
   'E-Passport Fees', 'mofa.gov.bd', '2026-08-08',
   'Bangladesh government mission page; fee table cross-referenced across multiple mofa.gov.bd embassy/consulate pages reporting identical figures. Domestic fees in BDT; abroad fees in USD noted separately. Verify against epassport.gov.bd before relying on exact amounts.'),
  ('https://www.epassport.gov.bd/', 'e-Passport Online Portal', 'epassport.gov.bd', '2026-08-08', 'Official online application portal (Department of Immigration & Passports).');

-- Office (national-level placeholder: applicants are assigned a Regional
-- Passport Office based on district during online application; district-
-- specific office rows are Phase 3+ follow-up work).
INSERT INTO offices (service_id, office_level, name_en, name_bn, address_en, address_bn, source_id)
SELECT 'passport', 'national',
  'Regional Passport Office (assigned by district during application)',
  'আঞ্চলিক পাসপোর্ট অফিস (আবেদনের সময় জেলা অনুযায়ী নির্ধারিত)',
  'Apply online and select your district/nearest police station area — the system assigns your Regional Passport Office for the biometric enrollment appointment.',
  'অনলাইনে আবেদন করে আপনার জেলা/নিকটস্থ থানা এলাকা নির্বাচন করুন — সিস্টেম বায়োমেট্রিক নিবন্ধনের জন্য আপনার আঞ্চলিক পাসপোর্ট অফিস নির্ধারণ করবে।',
  id
FROM sources WHERE url = 'https://www.epassport.gov.bd/';

-- Fees (48/64 pages x 5/10 years x regular/express/super-express, domestic BDT)
INSERT INTO fees (service_id, fee_type, amount_bdt, unit, notes_en, notes_bn, source_id)
SELECT 'passport', v.fee_type, v.amount_bdt, 'per application', v.notes_en, v.notes_bn, s.id
FROM (VALUES
  ('48pg_5yr_regular', 4025, '48 pages, 5-year validity, regular delivery (~21 days).', '৪৮ পৃষ্ঠা, ৫ বছর মেয়াদ, নিয়মিত ডেলিভারি (~২১ দিন)।'),
  ('48pg_5yr_express', 6325, '48 pages, 5-year validity, express delivery (~10 days).', '৪৮ পৃষ্ঠা, ৫ বছর মেয়াদ, এক্সপ্রেস ডেলিভারি (~১০ দিন)।'),
  ('48pg_5yr_super_express', 8625, '48 pages, 5-year validity, super express delivery (~2 days).', '৪৮ পৃষ্ঠা, ৫ বছর মেয়াদ, সুপার এক্সপ্রেস ডেলিভারি (~২ দিন)।'),
  ('48pg_10yr_regular', 5750, '48 pages, 10-year validity, regular delivery.', '৪৮ পৃষ্ঠা, ১০ বছর মেয়াদ, নিয়মিত ডেলিভারি।'),
  ('48pg_10yr_express', 8050, '48 pages, 10-year validity, express delivery.', '৪৮ পৃষ্ঠা, ১০ বছর মেয়াদ, এক্সপ্রেস ডেলিভারি।'),
  ('48pg_10yr_super_express', 10350, '48 pages, 10-year validity, super express delivery.', '৪৮ পৃষ্ঠা, ১০ বছর মেয়াদ, সুপার এক্সপ্রেস ডেলিভারি।'),
  ('64pg_5yr_regular', 6325, '64 pages, 5-year validity, regular delivery.', '৬৪ পৃষ্ঠা, ৫ বছর মেয়াদ, নিয়মিত ডেলিভারি।'),
  ('64pg_5yr_express', 8625, '64 pages, 5-year validity, express delivery.', '৬৪ পৃষ্ঠা, ৫ বছর মেয়াদ, এক্সপ্রেস ডেলিভারি।'),
  ('64pg_5yr_super_express', 12075, '64 pages, 5-year validity, super express delivery.', '৬৪ পৃষ্ঠা, ৫ বছর মেয়াদ, সুপার এক্সপ্রেস ডেলিভারি।'),
  ('64pg_10yr_regular', 8050, '64 pages, 10-year validity, regular delivery.', '৬৪ পৃষ্ঠা, ১০ বছর মেয়াদ, নিয়মিত ডেলিভারি।'),
  ('64pg_10yr_express', 10350, '64 pages, 10-year validity, express delivery.', '৬৪ পৃষ্ঠা, ১০ বছর মেয়াদ, এক্সপ্রেস ডেলিভারি।'),
  ('64pg_10yr_super_express', 13800, '64 pages, 10-year validity, super express delivery.', '৬৪ পৃষ্ঠা, ১০ বছর মেয়াদ, সুপার এক্সপ্রেস ডেলিভারি।')
) AS v(fee_type, amount_bdt, notes_en, notes_bn)
CROSS JOIN (SELECT id FROM sources WHERE url LIKE 'https://wellington.mofa.gov.bd%') AS s;

-- Required documents
INSERT INTO required_documents (service_id, document_en, document_bn, is_mandatory, applies_to, sort_order, source_id)
SELECT 'passport', v.document_en, v.document_bn, v.is_mandatory, v.applies_to, v.sort_order, s.id
FROM (VALUES
  ('Printed online application summary', 'অনলাইন আবেদনের প্রিন্ট করা সারসংক্ষেপ', true, 'all', 1),
  ('Original National ID Card (NID)', 'মূল জাতীয় পরিচয়পত্র (এনআইডি)', true, 'all', 2),
  ('Online Birth Registration Certificate (English) — if under 18 or no NID', 'অনলাইন জন্মনিবন্ধন সনদ (ইংরেজি) — ১৮ বছরের নিচে হলে বা এনআইডি না থাকলে', false, 'all', 3),
  ('Payment slip (A-Challan / e-Challan)', 'পেমেন্ট স্লিপ (এ-চালান / ই-চালান)', true, 'all', 4),
  ('Previous passport, if any', 'পূর্ববর্তী পাসপোর্ট (যদি থাকে)', false, 'renewal', 5)
) AS v(document_en, document_bn, is_mandatory, applies_to, sort_order)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://www.epassport.gov.bd/') AS s;

-- Steps
INSERT INTO steps (service_id, step_number, title_en, title_bn, is_online, source_id)
SELECT 'passport', v.step_number, v.title_en, v.title_bn, v.is_online, s.id
FROM (VALUES
  (1, 'Fill out the online application at epassport.gov.bd, selecting your district and nearest police station area', 'epassport.gov.bd এ অনলাইনে আবেদন পূরণ করুন, আপনার জেলা ও নিকটস্থ থানা এলাকা নির্বাচন করুন', true),
  (2, 'Pay the fee via A-Challan/e-Challan or bank', 'এ-চালান/ই-চালান বা ব্যাংকের মাধ্যমে ফি পরিশোধ করুন', true),
  (3, 'Print the application summary and required documents', 'আবেদনের সারসংক্ষেপ ও প্রয়োজনীয় কাগজপত্র প্রিন্ট করুন', false),
  (4, 'Visit your assigned Regional Passport Office on the appointment date with your original NID', 'নির্ধারিত তারিখে মূল এনআইডি নিয়ে আপনার নির্ধারিত আঞ্চলিক পাসপোর্ট অফিসে যান', false),
  (5, 'Complete biometric enrollment (photo, fingerprints, signature)', 'বায়োমেট্রিক নিবন্ধন সম্পন্ন করুন (ছবি, আঙুলের ছাপ, স্বাক্ষর)', false),
  (6, 'Collect the passport once ready, per your chosen delivery speed', 'নির্বাচিত ডেলিভারি সময় অনুযায়ী প্রস্তুত হলে পাসপোর্ট সংগ্রহ করুন', false)
) AS v(step_number, title_en, title_bn, is_online)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://www.epassport.gov.bd/') AS s;

-- Online portal
INSERT INTO online_portals (service_id, portal_name, url, description_en, description_bn) VALUES
  ('passport', 'e-Passport Online Portal', 'https://www.epassport.gov.bd/', 'Apply for a new e-passport or renewal, check status, and pay fees.', 'নতুন ই-পাসপোর্ট বা নবায়নের আবেদন, অবস্থা যাচাই এবং ফি পরিশোধ করুন।');
