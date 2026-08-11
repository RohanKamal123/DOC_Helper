import { tavilySearch } from '../tavily.js';

export const schema = {
  type: 'function',
  function: {
    name: 'web_search',
    description:
      "Search the live web for information not covered by get_service_info — e.g. a very recent fee change, news, or a holiday office closure. Limited to one call per conversation turn; use it only when the curated database can't answer the question.",
    parameters: {
      type: 'object',
      properties: {
        query: { type: 'string', description: 'The search query.' },
      },
      required: ['query'],
    },
  },
};

export async function handler({ query } = {}) {
  if (!query) return { error: 'query is required.' };
  try {
    const results = await tavilySearch(query);
    return { results };
  } catch (err) {
    return { error: err.message };
  }
}
