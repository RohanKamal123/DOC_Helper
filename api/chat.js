import { runAgent } from '../lib/agent.js';
import { sanitizeSecret } from '../lib/sanitizeSecret.js';

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  const { message, history, model, district, upazila } = req.body || {};
  // A key pasted by a user into the browser can pick up the same invisible
  // Unicode artifacts a copy-paste into an env var can — sanitize it too.
  const deepseekApiKey = sanitizeSecret(req.body?.deepseekApiKey);

  if (!deepseekApiKey || typeof deepseekApiKey !== 'string') {
    res.status(400).json({ error: 'Missing DeepSeek API key.' });
    return;
  }
  if (!message || typeof message !== 'string' || !message.trim()) {
    res.status(400).json({ error: 'Missing message.' });
    return;
  }

  const safeHistory = Array.isArray(history)
    ? history
        .filter((m) => m && (m.role === 'user' || m.role === 'assistant') && typeof m.content === 'string')
        .slice(-20)
    : [];

  let userMessage = message.trim();
  if (district) {
    userMessage += `\n\n[User location context — district: ${district}${upazila ? `, upazila: ${upazila}` : ''}]`;
  }

  try {
    const { answerText, toolResults } = await runAgent({
      apiKey: deepseekApiKey,
      model: model || 'deepseek-v4-flash',
      history: safeHistory,
      userMessage,
    });

    const serviceInfo = toolResults.get_service_info || null;
    const nearestOffice = toolResults.find_nearest_office?.office || null;
    const searchResult = toolResults.web_search || null;

    res.status(200).json({
      answer_text: answerText,
      service: serviceInfo?.service || null,
      offices: nearestOffice ? [nearestOffice] : serviceInfo?.offices || [],
      fees: serviceInfo?.fees || [],
      documents: serviceInfo?.documents || [],
      steps: serviceInfo?.steps || [],
      forms: serviceInfo?.forms || [],
      online_portals: serviceInfo?.online_portals || [],
      sources: serviceInfo?.sources || [],
      web_search_used: Boolean(searchResult && !searchResult.error),
      search_results: searchResult?.results || [],
    });
  } catch (err) {
    // Never log deepseekApiKey or any request body field that could carry it.
    console.error('api/chat error:', err.message);
    res.status(500).json({ error: 'Something went wrong processing your request. Please try again.' });
  }
}
