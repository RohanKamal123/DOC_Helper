// Single source of truth for valid service ids, shared by tool schemas
// (as a JSON-schema enum, so the model can't hand get_service_info /
// find_nearest_office a guessed id that doesn't exist) and anywhere else
// that needs to validate one.
export const SERVICE_IDS = [
  'nid', 'birth', 'passport', 'brta', 'ssc', 'hsc',
  'land', 'trade', 'export', 'import', 'taxtin', 'police',
];
