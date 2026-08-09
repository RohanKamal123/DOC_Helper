# Database setup

1. Create a free Supabase project at supabase.com.
2. Open the SQL Editor and run `schema.sql` once.
3. Run the seed files in `seed/` — `services.sql` first, then the rest in any order:
   `nid.sql`, `birth.sql`, `passport.sql`, `brta.sql`, `ssc.sql`, `hsc.sql`,
   `land.sql`, `trade.sql`, `taxtin.sql`, `police.sql`, `export.sql`, `import.sql`.
4. Run everything in `migrations/`, in filename order (currently just
   `001_add_processing_time.sql`). Migrations are safe to re-run.
5. Copy your project's URL and **service role key** (Settings > API) into
   `SUPABASE_URL` / `SUPABASE_SERVICE_ROLE_KEY` in `.env.local` (for `vercel dev`)
   and in your Vercel project's environment variables (for deployment).

## Data confidence

Every fact-bearing row (`offices`, `fees`, `required_documents`, `steps`, `forms`)
points at a `sources` row with a `last_verified_date` and, in `notes`, an honest
account of how confident that figure is — several official `.gov.bd` fee pages
render dynamically or blocked automated fetches during research, so some
figures are cross-referenced from secondary sources rather than confirmed
directly. Read the `notes` column before treating any seeded figure as final,
and re-verify against the primary source periodically — this is real guidance
shown to citizens.
