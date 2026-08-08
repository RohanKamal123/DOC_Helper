-- Seed data for service_id = 'birth' (Birth Certificate).
-- Researched 2026-08-08 against bdris.gov.bd. The dedicated fee-schedule
-- page (orgbdr.gov.bd) returned HTTP 503 at verification time; fee figures
-- below are cross-referenced from Bangladesh government mission pages
-- (mofa.gov.bd embassy/consulate sites) and general web search summaries
-- reporting the same schedule. Re-verify before treating exact amounts as
-- final, especially the abroad (USD) fees.

INSERT INTO sources (url, title, publisher, last_verified_date, notes) VALUES
  ('https://bdris.gov.bd/', 'Bangladesh Birth and Death Registration Information System (BDRIS)', 'bdris.gov.bd', '2026-08-08',
   'Official portal home page. Dedicated fee-schedule sub-page (orgbdr.gov.bd) returned HTTP 503 at verification time; fees below cross-referenced from Bangladesh government mission (mofa.gov.bd) pages and secondary sources.'),
  ('https://bdris.gov.bd/br/correction', 'Birth Registration Correction Application', 'bdris.gov.bd', '2026-08-08', NULL),
  ('https://bdris.gov.bd/br/application', 'New Birth Registration Application', 'bdris.gov.bd', '2026-08-08', NULL);

-- Office (national-level placeholder: birth registration is fully
-- decentralized to the local Union Parishad / City Corporation ward /
-- Pourashova — district/upazila-specific rows are added in Phase 2).
INSERT INTO offices (service_id, office_level, name_en, name_bn, address_en, address_bn, source_id)
SELECT 'birth', 'national',
  'Local Registrar — Union Parishad / City Corporation / Pourashova',
  'স্থানীয় নিবন্ধক — ইউনিয়ন পরিষদ / সিটি কর্পোরেশন / পৌরসভা',
  'Apply online first, then visit the Union Parishad, City Corporation ward office, or Pourashova registrar covering your residence to complete verification.',
  'অনলাইনে আবেদনের পর যাচাইয়ের জন্য আপনার এলাকার ইউনিয়ন পরিষদ, সিটি কর্পোরেশন ওয়ার্ড অফিস বা পৌরসভা নিবন্ধকের কাছে যান।',
  id
FROM sources WHERE url = 'https://bdris.gov.bd/';

-- Fees
INSERT INTO fees (service_id, fee_type, amount_bdt, unit, notes_en, notes_bn, source_id)
SELECT 'birth', v.fee_type, v.amount_bdt, 'per application', v.notes_en, v.notes_bn, s.id
FROM (VALUES
  ('new_registration_within_45_days', 0, 'Free if registered within 45 days of birth.', 'জন্মের ৪৫ দিনের মধ্যে নিবন্ধন করলে বিনামূল্যে।'),
  ('late_registration_45days_to_5years', 25, 'Registration between 45 days and 5 years after birth.', 'জন্মের ৪৫ দিন থেকে ৫ বছরের মধ্যে নিবন্ধন।'),
  ('late_registration_after_5years', 50, 'Registration more than 5 years after birth.', 'জন্মের ৫ বছর পর নিবন্ধন।'),
  ('correction_general', 50, 'General info correction, domestic. $1 if applying from abroad.', 'সাধারণ তথ্য সংশোধন, দেশের ভেতরে। বিদেশ থেকে $১।'),
  ('correction_date_of_birth', 100, 'Date-of-birth correction, domestic. $2 if applying from abroad.', 'জন্ম তারিখ সংশোধন, দেশের ভেতরে। বিদেশ থেকে $২।')
) AS v(fee_type, amount_bdt, notes_en, notes_bn)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://bdris.gov.bd/') AS s;

-- Required documents
INSERT INTO required_documents (service_id, document_en, document_bn, is_mandatory, applies_to, sort_order, source_id)
SELECT 'birth', v.document_en, v.document_bn, v.is_mandatory, v.applies_to, v.sort_order, s.id
FROM (VALUES
  ('Hospital birth record or EPI (vaccination) card', 'হাসপাতালের জন্ম রেকর্ড বা ইপিআই (টিকা) কার্ড', true, 'first_time', 1),
  ('Parents'' NID or birth certificates', 'পিতামাতার এনআইডি বা জন্মনিবন্ধন সনদ', true, 'first_time', 2),
  ('Proof of address (utility bill)', 'ঠিকানার প্রমাণ (ইউটিলিটি বিল)', true, 'all', 3),
  ('Existing birth registration number/certificate', 'বিদ্যমান জন্মনিবন্ধন নম্বর/সনদ', true, 'correction', 4),
  ('Supporting proof for the corrected information (e.g. SSC certificate, NID)', 'সংশোধিত তথ্যের সমর্থনে প্রমাণ (যেমন এসএসসি সনদ, এনআইডি)', true, 'correction', 5)
) AS v(document_en, document_bn, is_mandatory, applies_to, sort_order)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://bdris.gov.bd/') AS s;

-- Steps
INSERT INTO steps (service_id, step_number, title_en, title_bn, is_online, source_id)
SELECT 'birth', v.step_number, v.title_en, v.title_bn, v.is_online, s.id
FROM (VALUES
  (1, 'Apply online at bdris.gov.bd (new registration or correction)', 'bdris.gov.bd এ অনলাইনে আবেদন করুন (নতুন নিবন্ধন বা সংশোধন)', true),
  (2, 'Upload the required supporting documents', 'প্রয়োজনীয় কাগজপত্র আপলোড করুন', true),
  (3, 'Pay the applicable fee online, if any (bKash/bank)', 'প্রযোজ্য হলে অনলাইনে ফি পরিশোধ করুন (বিকাশ/ব্যাংক)', true),
  (4, 'Submit/verify the application at your local Union Parishad, City Corporation ward, or Pourashova registrar office', 'আপনার ইউনিয়ন পরিষদ, সিটি কর্পোরেশন ওয়ার্ড বা পৌরসভা নিবন্ধকের কাছে আবেদন জমা/যাচাই করুন', false),
  (5, 'Collect the registered/corrected certificate', 'নিবন্ধিত/সংশোধিত সনদ সংগ্রহ করুন', false)
) AS v(step_number, title_en, title_bn, is_online)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://bdris.gov.bd/br/application') AS s;

-- Online portals
INSERT INTO online_portals (service_id, portal_name, url, description_en, description_bn) VALUES
  ('birth', 'Birth & Death Registration Information System (BDRIS)', 'https://bdris.gov.bd/', 'Apply for new registration and corrections.', 'নতুন নিবন্ধন ও সংশোধনের জন্য আবেদন করুন।'),
  ('birth', 'Application Status Check', 'https://bdris.gov.bd/br/application/status', 'Check the status of a submitted application.', 'জমাকৃত আবেদনের অবস্থা যাচাই করুন।');
