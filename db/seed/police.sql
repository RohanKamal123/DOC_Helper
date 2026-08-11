-- Seed data for service_id = 'police' (Police Clearance Certificate / PCC).
-- Researched 2026-08-08 against pcc.police.gov.bd (referenced across many
-- sources, incl. Bangladesh government mission/consulate pages) and
-- multiple independent secondary sources reporting a consistent 500 BDT
-- fee and 7-21 working day processing range.

INSERT INTO sources (url, title, publisher, last_verified_date, notes) VALUES
  ('https://pcc.police.gov.bd/', 'Police Clearance Certificate (PCC) Portal', 'police.gov.bd', '2026-08-08',
   'Official PCC application portal. Fee (500 BDT) and process consistently corroborated across multiple independent sources, including Bangladesh government mission pages abroad. Processing-time estimates vary by source (7-21 working days reported); shown as a range.');

-- Office (national-level placeholder: applies online first, then may need
-- in-person verification at the Detective Branch (DB)/Superintendent of
-- Police office covering the applicant's district of residence).
INSERT INTO offices (service_id, office_level, name_en, name_bn, address_en, address_bn, source_id)
SELECT 'police', 'national',
  'Detective Branch (DB) / Superintendent of Police (SP) office for your district of residence',
  'আপনার বসবাসের জেলার গোয়েন্দা শাখা (ডিবি) / পুলিশ সুপারের কার্যালয়',
  'Apply online first at pcc.police.gov.bd. Address/background verification may involve your local Thana (police station) and the district''s DB/SP office.',
  'প্রথমে pcc.police.gov.bd এ অনলাইনে আবেদন করুন। ঠিকানা/পূর্ববৃত্তান্ত যাচাইয়ে আপনার স্থানীয় থানা এবং জেলার ডিবি/এসপি কার্যালয় জড়িত থাকতে পারে।',
  id
FROM sources WHERE url = 'https://pcc.police.gov.bd/';

-- Fees
INSERT INTO fees (service_id, fee_type, amount_bdt, unit, notes_en, notes_bn, source_id)
SELECT 'police', 'application', 500, 'per application',
  'Paid online or via bank (Sonali Bank or another authorized bank) during application.',
  'আবেদনের সময় অনলাইনে বা ব্যাংকের মাধ্যমে (সোনালী ব্যাংক বা অন্য অনুমোদিত ব্যাংক) পরিশোধ।',
  id
FROM sources WHERE url = 'https://pcc.police.gov.bd/';

-- Required documents
INSERT INTO required_documents (service_id, document_en, document_bn, is_mandatory, applies_to, sort_order, source_id)
SELECT 'police', v.document_en, v.document_bn, v.is_mandatory, v.applies_to, v.sort_order, s.id
FROM (VALUES
  ('Valid passport (bio-data page copy)', 'বৈধ পাসপোর্ট (বায়োডাটা পৃষ্ঠার কপি)', true, 'all', 1),
  ('National ID (NID)', 'জাতীয় পরিচয়পত্র (এনআইডি)', true, 'all', 2),
  ('Proof of present and permanent address', 'বর্তমান ও স্থায়ী ঠিকানার প্রমাণ', true, 'all', 3),
  ('Recent passport-size photograph', 'সাম্প্রতিক পাসপোর্ট সাইজ ছবি', true, 'all', 4),
  ('Treasury challan / payment receipt for the fee', 'ফি বাবদ ট্রেজারি চালান / পেমেন্ট রশিদ', true, 'all', 5)
) AS v(document_en, document_bn, is_mandatory, applies_to, sort_order)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://pcc.police.gov.bd/') AS s;

-- Steps
INSERT INTO steps (service_id, step_number, title_en, title_bn, is_online, source_id)
SELECT 'police', v.step_number, v.title_en, v.title_bn, v.is_online, s.id
FROM (VALUES
  (1, 'Create an account and apply online at pcc.police.gov.bd', 'pcc.police.gov.bd এ অ্যাকাউন্ট তৈরি করে অনলাইনে আবেদন করুন', true),
  (2, 'Upload scanned copies of your passport, NID, and photo, and state the purpose of the certificate', 'পাসপোর্ট, এনআইডি ও ছবির স্ক্যান কপি আপলোড করুন এবং সার্টিফিকেটের উদ্দেশ্য উল্লেখ করুন', true),
  (3, 'Pay the fee online or via authorized bank', 'অনলাইনে বা অনুমোদিত ব্যাংকের মাধ্যমে ফি পরিশোধ করুন', true),
  (4, 'Address/background verification is conducted, which may involve your local Thana', 'ঠিকানা/পূর্ববৃত্তান্ত যাচাই করা হয়, যাতে আপনার স্থানীয় থানা জড়িত থাকতে পারে', false),
  (5, 'Download or collect the certificate once approved (processing typically 7-21 working days, per various reports)', 'অনুমোদিত হলে সার্টিফিকেট ডাউনলোড বা সংগ্রহ করুন (প্রক্রিয়াকরণ সাধারণত ৭-২১ কর্মদিবস, বিভিন্ন সূত্র অনুযায়ী)', true)
) AS v(step_number, title_en, title_bn, is_online)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://pcc.police.gov.bd/') AS s;

-- Online portal
INSERT INTO online_portals (service_id, portal_name, url, description_en, description_bn) VALUES
  ('police', 'Police Clearance Certificate Portal', 'https://pcc.police.gov.bd/', 'Apply for a PCC, pay fees, and track/download your certificate.', 'পিসিসির আবেদন, ফি পরিশোধ এবং সার্টিফিকেট ট্র্যাক/ডাউনলোড করুন।');
