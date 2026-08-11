-- Seed data for service_id = 'taxtin' (TIN / e-TIN registration).
-- Researched 2026-08-08. This is the cleanest service to seed: NBR's
-- e-TIN registration is free, fully online, and consistently reported the
-- same way across many independent sources.

INSERT INTO sources (url, title, publisher, last_verified_date, notes) VALUES
  ('https://www.incometax.gov.bd/', 'NBR e-TIN / Income Tax Portal', 'incometax.gov.bd', '2026-08-08',
   'Official NBR e-TIN registration portal. Free of charge, fully online — consistently reported across multiple independent sources with no conflicting figures.');

-- No office needed: registration is entirely online and does not require
-- an in-person visit. (Physical tax circle/zone offices matter later, for
-- filing/queries, but not for TIN registration itself.)

-- Fees
INSERT INTO fees (service_id, fee_type, amount_bdt, unit, notes_en, notes_bn, source_id)
SELECT 'taxtin', 'registration', 0, 'per application',
  'e-TIN registration is completely free — no government fee at any stage.',
  'ই-টিআইএন নিবন্ধন সম্পূর্ণ বিনামূল্যে — কোনো ধাপেই সরকারি ফি নেই।',
  id
FROM sources WHERE url = 'https://www.incometax.gov.bd/';

-- Required documents
INSERT INTO required_documents (service_id, document_en, document_bn, is_mandatory, applies_to, sort_order, source_id)
SELECT 'taxtin', v.document_en, v.document_bn, v.is_mandatory, v.applies_to, v.sort_order, s.id
FROM (VALUES
  ('National ID (NID)', 'জাতীয় পরিচয়পত্র (এনআইডি)', true, 'all', 1),
  ('Active mobile number (ideally NID-linked)', 'সচল মোবাইল নম্বর (সম্ভব হলে এনআইডি-সংযুক্ত)', true, 'all', 2),
  ('Valid passport — for foreign nationals without an NID', 'বৈধ পাসপোর্ট — এনআইডি নেই এমন বিদেশি নাগরিকদের জন্য', false, 'all', 3)
) AS v(document_en, document_bn, is_mandatory, applies_to, sort_order)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://www.incometax.gov.bd/') AS s;

-- Steps
INSERT INTO steps (service_id, step_number, title_en, title_bn, is_online, source_id)
SELECT 'taxtin', v.step_number, v.title_en, v.title_bn, v.is_online, s.id
FROM (VALUES
  (1, 'Go to incometax.gov.bd and select e-TIN registration', 'incometax.gov.bd এ গিয়ে ই-টিআইএন নিবন্ধন নির্বাচন করুন', true),
  (2, 'Create an account using your NID and mobile number', 'আপনার এনআইডি ও মোবাইল নম্বর দিয়ে অ্যাকাউন্ট তৈরি করুন', true),
  (3, 'Fill in your personal and taxpayer details and submit', 'আপনার ব্যক্তিগত ও করদাতা তথ্য পূরণ করে জমা দিন', true),
  (4, 'Download your 12-digit e-TIN certificate instantly', 'তাৎক্ষণিকভাবে আপনার ১২-সংখ্যার ই-টিআইএন সার্টিফিকেট ডাউনলোড করুন', true)
) AS v(step_number, title_en, title_bn, is_online)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://www.incometax.gov.bd/') AS s;

-- Online portal
INSERT INTO online_portals (service_id, portal_name, url, description_en, description_bn) VALUES
  ('taxtin', 'NBR e-TIN / Income Tax Portal', 'https://www.incometax.gov.bd/', 'Register for e-TIN, download your certificate, and file returns — entirely online, free.', 'ই-টিআইএন নিবন্ধন, সার্টিফিকেট ডাউনলোড ও রিটার্ন দাখিল — সম্পূর্ণ অনলাইনে, বিনামূল্যে।');
