-- Seed data for service_id = 'ssc' (SSC Certificate — duplicate/reissue).
-- Researched 2026-08-08. This process is board-specific and only Dhaka
-- Board's online path is confirmed here — Bangla-language sources (incl.
-- YouTube tutorials, searched per the standing instruction to check YouTube
-- when official pages are thin) confirm Dhaka Board now accepts the
-- reissue application online at dhakaeducation.gov.bd with a ~503 BDT
-- bKash payment, uploading the GD copy and newspaper-notice PDF. Other
-- boards (Rajshahi, Chittagong, Comilla, Jessore, Barisal, Sylhet,
-- Dinajpur, Mymensingh, Madrasah, Technical) were NOT individually
-- re-confirmed to have the same online option — for those, the original
-- manual path (Sonali Bank demand draft, in-person at the board's
-- Information Collection Center) is what's documented, seeded below as the
-- fallback. The exact collection/delivery method after a successful
-- application (in-person pickup vs. courier vs. downloadable PDF) is NOT
-- confirmed for either path — say so plainly rather than asserting one.

INSERT INTO sources (url, title, publisher, last_verified_date, notes) VALUES
  ('https://www.educationboardresults.gov.bd/', 'Education Board Results Portal', 'educationboardresults.gov.bd', '2026-08-08',
   'Official results portal, run by the Ministry of Education, covering all 11 education boards. General process/authority reference; does not itself handle duplicate-certificate reissue.'),
  ('https://dhakaeducation.gov.bd/', 'Dhaka Education Board — Official Site', 'dhakaeducation.gov.bd', '2026-08-08',
   'Confirmed via Bangla-language secondary sources (blog + YouTube tutorials) to host an online duplicate-certificate reissue application (upload GD copy + newspaper notice PDF, ~503 BDT via bKash) as of the sources'' publication dates in 2025. Not independently re-verified by direct page fetch — recommend confirming the exact fee and current form location on the site before relying on it. Applies to Dhaka Board only; other boards not confirmed to offer the same online option.');

-- Office (national-level placeholder: for boards without a confirmed online
-- path, applicants go in person to their specific Education Board's
-- Information Collection Center; board-specific office addresses are a
-- Phase 3+ follow-up).
INSERT INTO offices (service_id, office_level, name_en, name_bn, address_en, address_bn, source_id)
SELECT 'ssc', 'national',
  'Your Education Board (Information Collection Center, in person — or online for Dhaka Board)',
  'আপনার শিক্ষা বোর্ড (তথ্য সংগ্রহ কেন্দ্র, সরাসরি — অথবা ঢাকা বোর্ডের জন্য অনলাইনে)',
  'Dhaka Board: apply online at dhakaeducation.gov.bd. Other boards (Rajshahi, Chittagong, Comilla, Jessore, Barisal, Sylhet, Dinajpur, Mymensingh, Madrasah, Technical): visit that board''s Information Collection Center in person — confirm with them whether an online option now exists.',
  'ঢাকা বোর্ড: dhakaeducation.gov.bd এ অনলাইনে আবেদন করুন। অন্যান্য বোর্ড (রাজশাহী, চট্টগ্রাম, কুমিল্লা, যশোর, বরিশাল, সিলেট, দিনাজপুর, ময়মনসিংহ, মাদ্রাসা, কারিগরি): সংশ্লিষ্ট বোর্ডের তথ্য সংগ্রহ কেন্দ্রে সরাসরি যান — অনলাইন সুবিধা আছে কিনা তাদের কাছে নিশ্চিত হয়ে নিন।',
  id
FROM sources WHERE url = 'https://www.educationboardresults.gov.bd/';

-- Fees
INSERT INTO fees (service_id, fee_type, amount_bdt, unit, notes_en, notes_bn, source_id)
SELECT 'ssc', v.fee_type, v.amount_bdt, 'per application', v.notes_en, v.notes_bn, s.id
FROM (VALUES
  ('duplicate_dhaka_board_online', 503, 'Dhaka Board only, paid via bKash during the online application. Re-verify exact amount on dhakaeducation.gov.bd before relying on it.', 'শুধু ঢাকা বোর্ড, অনলাইন আবেদনের সময় বিকাশে পরিশোধ। নির্ভরযোগ্যভাবে নিশ্চিত হতে dhakaeducation.gov.bd এ যাচাই করুন।')
) AS v(fee_type, amount_bdt, notes_en, notes_bn)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://dhakaeducation.gov.bd/') AS s;

INSERT INTO fees (service_id, fee_type, amount_bdt, unit, notes_en, notes_bn, source_id)
SELECT 'ssc', 'duplicate_other_boards_estimate', 500, 'per application',
  'Other boards: no single confirmed figure — commonly reported range is roughly 300-700 BDT, paid via Sonali Bank demand draft to the board secretary. This row is a rough midpoint, NOT a confirmed amount — contact the specific board to confirm before paying.',
  'অন্যান্য বোর্ড: নিশ্চিত কোনো একক অংক নেই — সাধারণত আনুমানিক ৩০০-৭০০ টাকা, সোনালী ব্যাংক ডিমান্ড ড্রাফটের মাধ্যমে বোর্ড সচিব বরাবর। এটি একটি আনুমানিক মধ্যবিন্দু, নিশ্চিত অংক নয় — পরিশোধের আগে সংশ্লিষ্ট বোর্ডে নিশ্চিত হয়ে নিন।',
  id
FROM sources WHERE url = 'https://www.educationboardresults.gov.bd/';

-- Required documents
INSERT INTO required_documents (service_id, document_en, document_bn, is_mandatory, applies_to, sort_order, source_id)
SELECT 'ssc', v.document_en, v.document_bn, v.is_mandatory, v.applies_to, v.sort_order, s.id
FROM (VALUES
  ('General Diary (GD) copy from local police station', 'নিকটস্থ থানা থেকে জিডি কপি', true, 'duplicate', 1),
  ('Newspaper notice of the loss (name, roll number, exam centre, passing year, board) — PDF if applying online', 'হারানোর সংবাদপত্র বিজ্ঞপ্তি (নাম, রোল নম্বর, পরীক্ষা কেন্দ্র, পাসের সাল, বোর্ড) — অনলাইনে আবেদনের ক্ষেত্রে পিডিএফ', true, 'duplicate', 2),
  ('Application form (online form for Dhaka Board; paper form from the Information Collection Center for other boards)', 'আবেদন ফরম (ঢাকা বোর্ডের জন্য অনলাইন ফরম; অন্যান্য বোর্ডের জন্য তথ্য সংগ্রহ কেন্দ্র থেকে কাগজের ফরম)', true, 'duplicate', 3),
  ('Fee payment: bKash (Dhaka Board online) or Sonali Bank demand draft to the board secretary (other boards)', 'ফি পরিশোধ: বিকাশ (ঢাকা বোর্ড অনলাইন) অথবা সোনালী ব্যাংক ডিমান্ড ড্রাফট বোর্ড সচিব বরাবর (অন্যান্য বোর্ড)', true, 'duplicate', 4)
) AS v(document_en, document_bn, is_mandatory, applies_to, sort_order)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://www.educationboardresults.gov.bd/') AS s;

-- Steps
INSERT INTO steps (service_id, step_number, title_en, title_bn, is_online, source_id)
SELECT 'ssc', v.step_number, v.title_en, v.title_bn, v.is_online, s.id
FROM (VALUES
  (1, 'File a General Diary (GD) at your local police station as soon as you notice the loss', 'হারানো টের পাওয়ার সাথে সাথে নিকটস্থ থানায় জিডি করুন', false),
  (2, 'Publish a notice in a daily newspaper describing the lost document', 'হারানো নথি সম্পর্কে একটি দৈনিক পত্রিকায় বিজ্ঞপ্তি প্রকাশ করুন', false),
  (3, 'Dhaka Board: apply online at dhakaeducation.gov.bd, uploading the GD and newspaper-notice PDFs, and pay via bKash. Other boards: collect and submit the paper form at the board''s Information Collection Center with the GD copy, newspaper cutting, and bank draft', 'ঢাকা বোর্ড: dhakaeducation.gov.bd এ অনলাইনে জিডি ও পত্রিকা বিজ্ঞপ্তির পিডিএফ আপলোড করে আবেদন করুন এবং বিকাশে পরিশোধ করুন। অন্যান্য বোর্ড: বোর্ডের তথ্য সংগ্রহ কেন্দ্রে জিডি কপি, পত্রিকার কাটিং ও ব্যাংক ড্রাফটসহ কাগজের ফরম জমা দিন', true),
  (4, 'Collect the duplicate certificate/marksheet as instructed by the board — the exact collection method (in-person pickup, courier, or digital download) is not confirmed here, so ask the board directly when you apply', 'বোর্ডের নির্দেশনা অনুযায়ী ডুপ্লিকেট সনদ/মার্কশিট সংগ্রহ করুন — সংগ্রহের সঠিক পদ্ধতি (সরাসরি সংগ্রহ, কুরিয়ার, নাকি ডিজিটাল ডাউনলোড) এখানে নিশ্চিত নয়, আবেদনের সময় বোর্ডের কাছে জিজ্ঞাসা করুন', false)
) AS v(step_number, title_en, title_bn, is_online)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://www.educationboardresults.gov.bd/') AS s;

-- Online portals
INSERT INTO online_portals (service_id, portal_name, url, description_en, description_bn) VALUES
  ('ssc', 'Education Board Results Portal', 'https://www.educationboardresults.gov.bd/', 'Look up SSC results and marksheets online.', 'অনলাইনে এসএসসি ফলাফল ও মার্কশিট দেখুন।'),
  ('ssc', 'Dhaka Education Board — Duplicate Certificate Application', 'https://dhakaeducation.gov.bd/', 'Dhaka Board only: apply online for a duplicate/reissued certificate.', 'শুধু ঢাকা বোর্ড: ডুপ্লিকেট/পুনরায় ইস্যু সনদের জন্য অনলাইনে আবেদন করুন।');
