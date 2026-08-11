// Strips invisible Unicode characters (zero-width spaces, bidi control
// marks, BOM) and surrounding whitespace from API keys/tokens. A stray
// character like U+200E (left-to-right mark) -- a common copy-paste
// artifact when moving text between UIs -- breaks HTTP header encoding
// with an opaque "Cannot convert argument to a ByteString" error, so any
// key coming from outside our own code (Vercel env vars, a pasted
// DeepSeek key) is sanitized at the boundary before use.
const INVISIBLE_CHARS_RE = /[\u200B-\u200F\u202A-\u202E\u2060\uFEFF]/g;

export function sanitizeSecret(value) {
  if (typeof value !== 'string') return value;
  return value.replace(INVISIBLE_CHARS_RE, '').trim();
}
