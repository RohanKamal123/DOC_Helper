-- Seed data for service_id = 'land' (Land Mutation / Namjari).
-- Researched 2026-08-08 against mutation.land.gov.bd (official e-mutation
-- portal) and cross-referenced Bangla-language sources reporting the same
-- fee breakdown, giving reasonable confidence in the figures below.

INSERT INTO sources (url, title, publisher, last_verified_date, notes) VALUES
  ('https://mutation.land.gov.bd/namjari-steps', 'ই-মিউটেশন আবেদন নিস্পত্তির ধাপসমূহ (E-Mutation Application Steps)', 'mutation.land.gov.bd', '2026-08-08',
   'Official e-mutation portal. Fee breakdown cross-referenced with independent Bangla-language sources reporting the same figures (court fee 20 + notice fee 50 = 70 BDT at application; record correction 1,000 + khatian copy 100-120 BDT on approval). The khatian copy fee is reported as either 100 or 120 BDT depending on source — flagged as a minor discrepancy, not re-verified directly.');

-- Office (national-level placeholder: mutation is handled by the Assistant
-- Commissioner (Land) / Upazila Land Office covering the land's location;
-- upazila-specific office rows are Phase 3+ follow-up).
INSERT INTO offices (service_id, office_level, name_en, name_bn, address_en, address_bn, source_id)
SELECT 'land', 'national',
  'Assistant Commissioner (Land) / Upazila Land Office',
  'সহকারী কমিশনার (ভূমি) / উপজেলা ভূমি অফিস',
  'Apply online first; the application routes to the AC (Land)/Upazila Land Office covering the land''s location for review and hearing.',
  'প্রথমে অনলাইনে আবেদন করুন; আবেদনটি জমির অবস্থান অনুযায়ী সংশ্লিষ্ট সহকারী কমিশনার (ভূমি)/উপজেলা ভূমি অফিসে পর্যালোচনা ও শুনানির জন্য যাবে।',
  id
FROM sources WHERE url = 'https://mutation.land.gov.bd/namjari-steps';

-- Fees
INSERT INTO fees (service_id, fee_type, amount_bdt, unit, notes_en, notes_bn, source_id)
SELECT 'land', v.fee_type, v.amount_bdt, 'per application', v.notes_en, v.notes_bn, s.id
FROM (VALUES
  ('court_fee', 20, 'Paid when submitting the application.', 'আবেদন জমা দেওয়ার সময় পরিশোধ।'),
  ('notice_fee', 50, 'Paid when submitting the application (notice issuance).', 'আবেদন জমা দেওয়ার সময় পরিশোধ (নোটিশ জারি)।'),
  ('record_correction_fee', 1000, 'Paid after the application is approved.', 'আবেদন অনুমোদনের পর পরিশোধ।'),
  ('khatian_copy_fee', 100, 'Certified mutation khatian copy, paid after approval. Some sources report 120 BDT — verify current amount at application time.', 'সার্টিফাইড নামজারি খতিয়ান কপি, অনুমোদনের পর পরিশোধ। কিছু সূত্রে ১২০ টাকা বলা হয়েছে — আবেদনের সময় নিশ্চিত হয়ে নিন।')
) AS v(fee_type, amount_bdt, notes_en, notes_bn)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://mutation.land.gov.bd/namjari-steps') AS s;

-- Required documents
INSERT INTO required_documents (service_id, document_en, document_bn, is_mandatory, applies_to, sort_order, source_id)
SELECT 'land', v.document_en, v.document_bn, v.is_mandatory, v.applies_to, v.sort_order, s.id
FROM (VALUES
  ('Registered sale deed (bia deed) and previous deed chain', 'রেজিস্ট্রিকৃত বিক্রয় দলিল (বায়া দলিল) ও পূর্ববর্তী দলিলের ধারা', true, 'all', 1),
  ('Latest khatian (record of rights) and porcha', 'সর্বশেষ খতিয়ান ও পর্চা', true, 'all', 2),
  ('Up-to-date land development tax (khajna) receipt', 'হালনাগাদ ভূমি উন্নয়ন কর (খাজনা) রশিদ', true, 'all', 3),
  ('Applicant''s NID', 'আবেদনকারীর এনআইডি', true, 'all', 4),
  ('Passport-size photograph', 'পাসপোর্ট সাইজ ছবি', true, 'all', 5)
) AS v(document_en, document_bn, is_mandatory, applies_to, sort_order)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://mutation.land.gov.bd/namjari-steps') AS s;

-- Steps
INSERT INTO steps (service_id, step_number, title_en, title_bn, is_online, source_id)
SELECT 'land', v.step_number, v.title_en, v.title_bn, v.is_online, s.id
FROM (VALUES
  (1, 'Apply online at mutation.land.gov.bd with deed, khatian, and tax receipt details', 'mutation.land.gov.bd এ দলিল, খতিয়ান ও কর রশিদের তথ্যসহ অনলাইনে আবেদন করুন', true),
  (2, 'Pay the court fee + notice fee (70 BDT total) online', 'কোর্ট ফি + নোটিশ ফি (মোট ৭০ টাকা) অনলাইনে পরিশোধ করুন', true),
  (3, 'The AC (Land)/Upazila Land Office reviews the application and may hold a hearing to confirm there is no competing claim', 'সহকারী কমিশনার (ভূমি)/উপজেলা ভূমি অফিস আবেদন পর্যালোচনা করে এবং প্রতিদ্বন্দ্বী দাবি নেই তা নিশ্চিত করতে শুনানি করতে পারে', false),
  (4, 'If approved, pay the record correction fee + khatian copy fee (~1,100 BDT total)', 'অনুমোদিত হলে রেকর্ড সংশোধন ফি + খতিয়ান কপি ফি (মোট ~১,১০০ টাকা) পরিশোধ করুন', true),
  (5, 'Receive the mutated khatian in your name', 'আপনার নামে নামজারিকৃত খতিয়ান গ্রহণ করুন', false)
) AS v(step_number, title_en, title_bn, is_online)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://mutation.land.gov.bd/namjari-steps') AS s;

-- Online portal
INSERT INTO online_portals (service_id, portal_name, url, description_en, description_bn) VALUES
  ('land', 'Land Mutation (e-Namjari) Portal', 'https://mutation.land.gov.bd/', 'Apply for mutation, pay fees, and track application status.', 'নামজারির আবেদন, ফি পরিশোধ ও আবেদনের অবস্থা ট্র্যাক করুন।'),
  ('land', 'Digital Land Services Portal', 'https://land.gov.bd/', 'Check CS/SA/RS khatian records and other land services.', 'সিএস/এসএ/আরএস খতিয়ান রেকর্ড ও অন্যান্য ভূমি সেবা দেখুন।');
