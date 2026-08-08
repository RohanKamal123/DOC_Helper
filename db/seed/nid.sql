-- Seed data for service_id = 'nid' (National ID).
-- Researched 2026-08-08 against nidw.gov.bd / services.nidw.gov.bd. The live
-- fee calculator (services.nidw.gov.bd/nid-pub/fees) renders amounts only
-- after an in-browser form submission and could not be scraped directly;
-- IssuanceDuplicateNID.php returned HTTP 503 at verification time. Fee
-- figures below are cross-referenced across multiple independent secondary
-- sources reporting the same official fee schedule — flagged in each
-- source's `notes` column. Re-verify directly against the official
-- calculator before treating exact amounts as final.

INSERT INTO sources (url, title, publisher, last_verified_date, notes) VALUES
  ('https://services.nidw.gov.bd/nid-pub/fees', 'NID Fee Calculator', 'nidw.gov.bd', '2026-08-08',
   'Official calculator renders fees dynamically after form submission; could not be fetched directly. Amounts below cross-referenced from 3+ independent secondary sources reporting the same schedule as of verification date. Re-verify before relying on exact figures.'),
  ('https://www.nidw.gov.bd/IssuanceDuplicateNID.php', 'Issuance of Duplicate NID', 'nidw.gov.bd', '2026-08-08',
   'Page returned HTTP 503 at verification time. Office/process described below reflects the standard, well-documented process (Upazila/Thana Election Office) corroborated by secondary sources.'),
  ('https://www.nidw.gov.bd/LawsRulesNIDCorrection.php', 'Laws & Rules for NID Correction', 'nidw.gov.bd', '2026-08-08', 'Legal basis for the correction process.'),
  ('https://ecs.gov.bd/page/dhaka-zilla-election-offices-contact', 'Dhaka Zilla Election Offices Contact', 'ecs.gov.bd', '2026-08-08',
   'Direct fetch returned HTTP 403 at verification time; address/phone below taken from a search-engine summary of this official ecs.gov.bd page, not independently re-confirmed by direct page load. Verify before treating as final — this single row exists to exercise find_nearest_office(district=''Dhaka'') during development; the other 11 services and most districts have no office-level data yet (Phase 3).');

-- Office (national-level placeholder: NID services are handled by the local
-- Upazila/Thana Election Office, of which there are ~495 — district/upazila-
-- specific rows are added in Phase 2 to power find_nearest_office).
INSERT INTO offices (service_id, office_level, name_en, name_bn, address_en, address_bn, source_id)
SELECT 'nid', 'national',
  'Upazila / Thana Election Office (your local office)',
  'উপজেলা/থানা নির্বাচন অফিস',
  'Apply online first, then visit your local Upazila or Thana Election Office to submit documents and biometrics.',
  'অনলাইনে আবেদন করার পর কাগজপত্র ও বায়োমেট্রিক জমা দিতে আপনার নিকটস্থ উপজেলা/থানা নির্বাচন অফিসে যান।',
  id
FROM sources WHERE url = 'https://www.nidw.gov.bd/IssuanceDuplicateNID.php';

-- District-level office (Dhaka) — seeded to exercise find_nearest_office
-- during Phase 2 development/testing. See caveat in the source row above.
INSERT INTO offices (service_id, office_level, name_en, name_bn, division, district, address_en, address_bn, phone, email, source_id)
SELECT 'nid', 'district',
  'District Election Office, Dhaka',
  'জেলা নির্বাচন অফিস, ঢাকা',
  'Dhaka', 'Dhaka',
  'Election Training Building, Agargaon, Dhaka',
  'নির্বাচন প্রশিক্ষণ ভবন, আগারগাঁও, ঢাকা',
  '+880-2-8181019',
  'sdeo.dhaka@gmail.com',
  id
FROM sources WHERE url = 'https://ecs.gov.bd/page/dhaka-zilla-election-offices-contact';

-- Fees
INSERT INTO fees (service_id, fee_type, amount_bdt, unit, notes_en, notes_bn, source_id)
SELECT 'nid', v.fee_type, v.amount_bdt, 'per application', v.notes_en, v.notes_bn, s.id
FROM (VALUES
  ('duplicate_1st_regular', 230, 'First-time reissue of a lost/damaged card, regular delivery.', 'প্রথমবার হারানো/নষ্ট কার্ড পুনরায় ইস্যু, সাধারণ ডেলিভারি।'),
  ('duplicate_1st_urgent', 345, 'First-time reissue, urgent delivery.', 'প্রথমবার পুনরায় ইস্যু, জরুরি ডেলিভারি।'),
  ('duplicate_2nd_regular', 345, 'Second-time reissue, regular delivery.', 'দ্বিতীয়বার পুনরায় ইস্যু, সাধারণ ডেলিভারি।'),
  ('duplicate_2nd_urgent', 575, 'Second-time reissue, urgent delivery.', 'দ্বিতীয়বার পুনরায় ইস্যু, জরুরি ডেলিভারি।'),
  ('duplicate_3rd_plus_regular', 525, 'Third or later reissue, regular delivery.', 'তৃতীয়বার বা তার বেশি পুনরায় ইস্যু, সাধারণ ডেলিভারি।'),
  ('duplicate_3rd_plus_urgent', 920, 'Third or later reissue, urgent delivery.', 'তৃতীয়বার বা তার বেশি পুনরায় ইস্যু, জরুরি ডেলিভারি।'),
  ('other_info_correction', 230, 'Correcting non-core fields (e.g. address).', 'অন্যান্য তথ্য সংশোধন (যেমন ঠিকানা)।'),
  ('nid_info_correction', 345, 'Correcting core identity fields (e.g. name, date of birth).', 'মূল তথ্য সংশোধন (যেমন নাম, জন্ম তারিখ)।'),
  ('combined_info_correction', 575, 'Correcting both core and other fields together.', 'মূল ও অন্যান্য তথ্য একসাথে সংশোধন।')
) AS v(fee_type, amount_bdt, notes_en, notes_bn)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://services.nidw.gov.bd/nid-pub/fees') AS s;

-- Required documents
INSERT INTO required_documents (service_id, document_en, document_bn, is_mandatory, applies_to, sort_order, source_id)
SELECT 'nid', v.document_en, v.document_bn, v.is_mandatory, v.applies_to, v.sort_order, s.id
FROM (VALUES
  ('General Diary (GD) copy from local police station', 'নিকটস্থ থানা থেকে জিডি কপি', true, 'duplicate', 1),
  ('Old NID card, if available', 'পুরাতন এনআইডি কার্ড (যদি থাকে)', false, 'duplicate', 2),
  ('Original Birth Certificate', 'মূল জন্মনিবন্ধন সনদ', true, 'all', 3),
  ('2 copies passport-size photograph', 'পাসপোর্ট সাইজ ছবি ২ কপি', true, 'all', 4),
  ('Proof of address (utility bill / house documents)', 'ঠিকানার প্রমাণ (ইউটিলিটি বিল / বাড়ির কাগজ)', true, 'correction', 5),
  ('Supporting document for the specific correction (e.g. SSC certificate for name/DOB)', 'নির্দিষ্ট সংশোধনের সমর্থনে কাগজ (যেমন নাম/জন্ম তারিখের জন্য এসএসসি সনদ)', true, 'correction', 6)
) AS v(document_en, document_bn, is_mandatory, applies_to, sort_order)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://www.nidw.gov.bd/LawsRulesNIDCorrection.php') AS s;

-- Steps
INSERT INTO steps (service_id, step_number, title_en, title_bn, is_online, source_id)
SELECT 'nid', v.step_number, v.title_en, v.title_bn, v.is_online, s.id
FROM (VALUES
  (1, 'Apply online at services.nidw.gov.bd (select correction or re-issue)', 'services.nidw.gov.bd এ অনলাইনে আবেদন করুন (সংশোধন বা পুনরায় ইস্যু বেছে নিন)', true),
  (2, 'Pay the applicable fee online (bKash/Nagad/Rocket/card)', 'অনলাইনে প্রযোজ্য ফি পরিশোধ করুন (বিকাশ/নগদ/রকেট/কার্ড)', true),
  (3, 'Print the application and attach required documents', 'আবেদনপত্র প্রিন্ট করুন এবং প্রয়োজনীয় কাগজপত্র সংযুক্ত করুন', false),
  (4, 'Submit the application and documents at your local Upazila/Thana Election Office', 'আপনার উপজেলা/থানা নির্বাচন অফিসে আবেদন ও কাগজপত্র জমা দিন', false),
  (5, 'Provide biometrics (fingerprint/photo) at the office if requested', 'প্রয়োজনে অফিসে বায়োমেট্রিক (আঙুলের ছাপ/ছবি) দিন', false),
  (6, 'Collect the new/corrected card once notified', 'নোটিফিকেশন পেলে নতুন/সংশোধিত কার্ড সংগ্রহ করুন', false)
) AS v(step_number, title_en, title_bn, is_online)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://www.nidw.gov.bd/IssuanceDuplicateNID.php') AS s;

-- Online portal
INSERT INTO online_portals (service_id, portal_name, url, description_en, description_bn) VALUES
  ('nid', 'NID Application System', 'https://services.nidw.gov.bd/nid-pub/', 'Apply for correction/re-issue and pay fees online.', 'অনলাইনে সংশোধন/পুনরায় ইস্যুর আবেদন ও ফি পরিশোধ করুন।');
