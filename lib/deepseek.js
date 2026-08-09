const DEEPSEEK_URL = 'https://api.deepseek.com/chat/completions';

export async function deepseekChat({ apiKey, model = 'deepseek-v4-flash', messages, tools }) {
  const res = await fetch(DEEPSEEK_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model,
      messages,
      ...(tools && tools.length ? { tools, tool_choice: 'auto' } : {}),
      max_tokens: 1500,
      temperature: 0.3,
    }),
  });

  const data = await res.json();
  if (!res.ok) {
    const message = data?.error?.message || data?.message || `DeepSeek API error (${res.status})`;
    throw new Error(message);
  }
  return data;
}
