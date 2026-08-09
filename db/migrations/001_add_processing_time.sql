-- Adds processing_time_en/processing_time_bn to fees, and backfills them
-- only where independently sourced during earlier research (see notes below
-- and the corresponding db/seed/*.sql files for original citations).
-- Safe to re-run: ADD COLUMN IF NOT EXISTS, UPDATE is idempotent.

ALTER TABLE fees ADD COLUMN IF NOT EXISTS processing_time_en TEXT;
ALTER TABLE fees ADD COLUMN IF NOT EXISTS processing_time_bn TEXT;

-- passport: explicit per-tier days, sourced from wellington.mofa.gov.bd (see db/seed/passport.sql)
UPDATE fees SET
  processing_time_en = CASE fee_type
    WHEN '48pg_5yr_regular' THEN '~21 days (regular delivery)'
    WHEN '48pg_5yr_express' THEN '~10 days (express delivery)'
    WHEN '48pg_5yr_super_express' THEN '~2 days (super express delivery)'
    WHEN '48pg_10yr_regular' THEN '~21 days (regular delivery)'
    WHEN '48pg_10yr_express' THEN '~10 days (express delivery)'
    WHEN '48pg_10yr_super_express' THEN '~2 days (super express delivery)'
    WHEN '64pg_5yr_regular' THEN '~21 days (regular delivery)'
    WHEN '64pg_5yr_express' THEN '~10 days (express delivery)'
    WHEN '64pg_5yr_super_express' THEN '~2 days (super express delivery)'
    WHEN '64pg_10yr_regular' THEN '~21 days (regular delivery)'
    WHEN '64pg_10yr_express' THEN '~10 days (express delivery)'
    WHEN '64pg_10yr_super_express' THEN '~2 days (super express delivery)'
  END,
  processing_time_bn = CASE fee_type
    WHEN '48pg_5yr_regular' THEN '~২১ দিন (নিয়মিত ডেলিভারি)'
    WHEN '48pg_5yr_express' THEN '~১০ দিন (এক্সপ্রেস ডেলিভারি)'
    WHEN '48pg_5yr_super_express' THEN '~২ দিন (সুপার এক্সপ্রেস ডেলিভারি)'
    WHEN '48pg_10yr_regular' THEN '~২১ দিন (নিয়মিত ডেলিভারি)'
    WHEN '48pg_10yr_express' THEN '~১০ দিন (এক্সপ্রেস ডেলিভারি)'
    WHEN '48pg_10yr_super_express' THEN '~২ দিন (সুপার এক্সপ্রেস ডেলিভারি)'
    WHEN '64pg_5yr_regular' THEN '~২১ দিন (নিয়মিত ডেলিভারি)'
    WHEN '64pg_5yr_express' THEN '~১০ দিন (এক্সপ্রেস ডেলিভারি)'
    WHEN '64pg_5yr_super_express' THEN '~২ দিন (সুপার এক্সপ্রেস ডেলিভারি)'
    WHEN '64pg_10yr_regular' THEN '~২১ দিন (নিয়মিত ডেলিভারি)'
    WHEN '64pg_10yr_express' THEN '~১০ দিন (এক্সপ্রেস ডেলিভারি)'
    WHEN '64pg_10yr_super_express' THEN '~২ দিন (সুপার এক্সপ্রেস ডেলিভারি)'
  END
WHERE service_id = 'passport';

-- birth: general range from secondary sources, not split by fee type
UPDATE fees SET
  processing_time_en = 'Typically 7-15 working days (some sources report up to 15 days for corrections); not independently confirmed per fee type.',
  processing_time_bn = 'সাধারণত ৭-১৫ কর্মদিবস (কিছু সূত্রে সংশোধনের ক্ষেত্রে ১৫ দিন পর্যন্ত বলা হয়েছে); প্রতিটি ফি অনুযায়ী আলাদাভাবে নিশ্চিত নয়।'
WHERE service_id = 'birth';

-- police clearance: single fee row
UPDATE fees SET
  processing_time_en = 'Typically 7-21 working days, per multiple secondary sources; not independently confirmed.',
  processing_time_bn = 'সাধারণত ৭-২১ কর্মদিবস, একাধিক সূত্র অনুযায়ী; স্বতন্ত্রভাবে নিশ্চিত নয়।'
WHERE service_id = 'police';

-- land mutation: overall process time, applies to all fee rows for the one process
UPDATE fees SET
  processing_time_en = 'Overall mutation process typically takes about 28-60 days from application to approval, per secondary sources.',
  processing_time_bn = 'সামগ্রিক নামজারি প্রক্রিয়ায় আবেদন থেকে অনুমোদন পর্যন্ত সাধারণত প্রায় ২৮-৬০ দিন সময় লাগে, বিভিন্ন সূত্র অনুযায়ী।'
WHERE service_id = 'land';

-- trade license: differs by local authority type
UPDATE fees SET
  processing_time_en = 'City Corporation: approx. 3-5 working days; Pourashova: approx. 1-4 working days, per SME Foundation process guide.',
  processing_time_bn = 'সিটি কর্পোরেশন: প্রায় ৩-৫ কর্মদিবস; পৌরসভা: প্রায় ১-৪ কর্মদিবস, এসএমই ফাউন্ডেশনের গাইড অনুযায়ী।'
WHERE service_id = 'trade';

-- TIN registration: fully online, fast, well-sourced
UPDATE fees SET
  processing_time_en = 'About 15-20 minutes, done entirely online.',
  processing_time_bn = 'সম্পূর্ণ অনলাইনে প্রায় ১৫-২০ মিনিট।'
WHERE service_id = 'taxtin';

-- export/import (ERC/IRC via CCI&E)
UPDATE fees SET
  processing_time_en = 'Typically 4-5 working days with complete documentation, per legal/consulting-firm sources.',
  processing_time_bn = 'সম্পূর্ণ কাগজপত্র থাকলে সাধারণত ৪-৫ কর্মদিবস, আইনি/পরামর্শক প্রতিষ্ঠানের সূত্র অনুযায়ী।'
WHERE service_id IN ('export', 'import');

-- NID: sources conflict significantly (7-15, 14-21, 7-30, 25-30 days regular;
-- 3-5 days urgent all reported) — shown with an explicit low-confidence
-- caveat rather than picking one number to present as fact.
UPDATE fees SET
  processing_time_en = 'Reported range 15-30 working days across sources (conflicting reports) for regular delivery — not independently confirmed.',
  processing_time_bn = 'সাধারণ ডেলিভারির জন্য বিভিন্ন সূত্রে ১৫-৩০ কর্মদিবসের কথা বলা হয়েছে (সূত্রভেদে ভিন্নতা আছে) — স্বতন্ত্রভাবে নিশ্চিত নয়।'
WHERE service_id = 'nid' AND fee_type IN ('duplicate_1st_regular', 'duplicate_2nd_regular', 'duplicate_3rd_plus_regular');

UPDATE fees SET
  processing_time_en = 'Reported approx. 3-5 working days for urgent processing — not independently confirmed.',
  processing_time_bn = 'জরুরি প্রক্রিয়াকরণের জন্য প্রায় ৩-৫ কর্মদিবস বলা হয়েছে — স্বতন্ত্রভাবে নিশ্চিত নয়।'
WHERE service_id = 'nid' AND fee_type IN ('duplicate_1st_urgent', 'duplicate_2nd_urgent', 'duplicate_3rd_plus_urgent');

UPDATE fees SET
  processing_time_en = 'Reported range 7-30 working days across sources depending on correction type (conflicting reports) — not independently confirmed.',
  processing_time_bn = 'সংশোধনের ধরন অনুযায়ী বিভিন্ন সূত্রে ৭-৩০ কর্মদিবসের কথা বলা হয়েছে (সূত্রভেদে ভিন্নতা আছে) — স্বতন্ত্রভাবে নিশ্চিত নয়।'
WHERE service_id = 'nid' AND fee_type IN ('other_info_correction', 'nid_info_correction', 'combined_info_correction');

-- brta, ssc, hsc: intentionally left NULL — no sourced total processing
-- time was found during research. The app should say "not confirmed"
-- rather than display a guessed figure for these.
