import { sanitizeSecret } from './sanitizeSecret.js';

const TAVILY_URL = 'https://api.tavily.com/search';

export async function tavilySearch(query) {
  const apiKey = sanitizeSecret(process.env.TAVILY_API_KEY);
  if (!apiKey) throw new Error('TAVILY_API_KEY is not configured.');

  const res = await fetch(TAVILY_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      api_key: apiKey,
      query,
      search_depth: 'basic',
      max_results: 5,
      include_answer: false,
    }),
  });

  const data = await res.json();
  if (!res.ok) {
    const message = data?.error || data?.message || `Tavily API error (${res.status})`;
    throw new Error(message);
  }

  return (data.results || []).map((r) => ({ title: r.title, url: r.url, snippet: r.content }));
}
