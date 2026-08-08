-- Seed data for service_id = 'import' (Import Registration Certificate / IRC).
-- Same issuing authority and research basis as export.sql (CCI&E) —
-- researched 2026-08-08.

INSERT INTO sources (url, title, publisher, last_verified_date, notes) VALUES
  ('https://ccie.gov.bd/', 'Office of the Chief Controller of Imports & Exports (CCI&E)', 'ccie.gov.bd', '2026-08-08',
   'Official CCI&E site, under the Ministry of Commerce. Fee ranges (initial registration ~5,000-80,000 BDT; renewal ~3,000-32,000 BDT, plus 15% VAT) cross-referenced from multiple legal/consulting-firm sources — not independently confirmed against an official fee schedule. Confirm the exact figure for your business type/capital before paying.');

INSERT INTO offices (service_id, office_level, name_en, name_bn, division, district, address_en, address_bn, phone, email, source_id)
SELECT 'import', 'national',
  'Office of the Chief Controller of Imports & Exports (CCI&E) — Headquarters',
  'আমদানি ও রপ্তানি প্রধান নিয়ন্ত্রকের কার্যালয় (সিসিআইএন্ডই) — সদর দপ্তর',
  'Dhaka', 'Dhaka',
  '62/3, NSC Tower, Level 15, Baitul Mokarram Road, Purana Paltan, Dhaka',
  '৬২/৩, এনএসসি টাওয়ার, লেভেল ১৫, বাইতুল মোকাররম রোড, পুরানা পল্টন, ঢাকা',
  '+880-2-9551556', 'controller.chief@ccie.gov.bd',
  id
FROM sources WHERE url = 'https://ccie.gov.bd/';

INSERT INTO fees (service_id, fee_type, amount_bdt, unit, notes_en, notes_bn, source_id)
SELECT 'import', v.fee_type, v.amount_bdt, 'per registration', v.notes_en, v.notes_bn, s.id
FROM (VALUES
  ('registration_minimum', 5000, 'Initial IRC registration starts around this figure and can go up to ~80,000 BDT depending on paid-up capital/business type, plus 15% VAT. Confirm your category''s exact fee with CCI&E.', 'প্রাথমিক আইআরসি নিবন্ধন প্রায় এই অংক থেকে শুরু হয়ে পরিশোধিত মূলধন/ব্যবসার ধরন অনুযায়ী ~৮০,০০০ টাকা পর্যন্ত হতে পারে, সাথে ১৫% ভ্যাট।'),
  ('renewal_minimum', 3000, 'Renewal fee starts around this figure and can go up to ~32,000 BDT, plus 15% VAT.', 'নবায়ন ফি প্রায় এই অংক থেকে শুরু হয়ে ~৩২,০০০ টাকা পর্যন্ত হতে পারে, সাথে ১৫% ভ্যাট।')
) AS v(fee_type, amount_bdt, notes_en, notes_bn)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://ccie.gov.bd/') AS s;

INSERT INTO required_documents (service_id, document_en, document_bn, is_mandatory, applies_to, sort_order, source_id)
SELECT 'import', v.document_en, v.document_bn, v.is_mandatory, v.applies_to, v.sort_order, s.id
FROM (VALUES
  ('Valid Trade License', 'বৈধ ট্রেড লাইসেন্স', true, 'all', 1),
  ('Membership Certificate from a recognized Chamber/Trade Association', 'স্বীকৃত চেম্বার/ট্রেড অ্যাসোসিয়েশনের সদস্যপদ সনদ', true, 'all', 2),
  ('Tax Identification Number (TIN) certificate', 'টিআইএন সার্টিফিকেট', true, 'all', 3),
  ('Bank Certificate/Solvency Certificate', 'ব্যাংক সার্টিফিকেট/সলভেন্সি সার্টিফিকেট', true, 'all', 4),
  ('Memorandum & Articles of Association and Certificate of Incorporation — for limited companies', 'স্মারকলিপি ও সংঘবিধি এবং নিবন্ধন সনদ — লিমিটেড কোম্পানির জন্য', false, 'all', 5)
) AS v(document_en, document_bn, is_mandatory, applies_to, sort_order)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://ccie.gov.bd/') AS s;

INSERT INTO steps (service_id, step_number, title_en, title_bn, is_online, source_id)
SELECT 'import', v.step_number, v.title_en, v.title_bn, v.is_online, s.id
FROM (VALUES
  (1, 'Apply to CCI&E with the required documents (in person, or via olm.ccie.gov.bd where applicable)', 'প্রয়োজনীয় কাগজপত্রসহ সিসিআইএন্ডই-তে আবেদন করুন (সরাসরি, অথবা প্রযোজ্য ক্ষেত্রে olm.ccie.gov.bd এর মাধ্যমে)', false),
  (2, 'Deposit the applicable fee at Bangladesh Bank or Sonali Bank under the specified Head of Account', 'নির্ধারিত হেড অব অ্যাকাউন্টে বাংলাদেশ ব্যাংক বা সোনালী ব্যাংকে প্রযোজ্য ফি জমা দিন', false),
  (3, 'Receive the Import Registration Certificate (IRC), typically within 4-5 working days with complete documentation', 'সম্পূর্ণ কাগজপত্র থাকলে সাধারণত ৪-৫ কর্মদিবসের মধ্যে আমদানি নিবন্ধন সনদ (আইআরসি) গ্রহণ করুন', false)
) AS v(step_number, title_en, title_bn, is_online)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://ccie.gov.bd/') AS s;

INSERT INTO online_portals (service_id, portal_name, url, description_en, description_bn) VALUES
  ('import', 'CCI&E Online License Management (OLM)', 'https://olm.ccie.gov.bd/', 'Certificate verification and related online services.', 'সনদ যাচাই ও সংশ্লিষ্ট অনলাইন সেবা।');
