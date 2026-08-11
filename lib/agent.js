import { deepseekChat } from './deepseek.js';
import { getToolSchemas, callTool } from './tools/index.js';
import { SYSTEM_PROMPT } from './systemPrompt.js';

// Each round is a full network round-trip to DeepSeek, which can be slow
// from Vercel's regions — keep this low so a chatty tool sequence can't
// burn through the whole function timeout before ever answering.
const MAX_TOOL_ROUNDS = 3;

// Runs the DeepSeek tool-calling loop and returns the model's final prose
// plus the raw result of each distinct tool called, keyed by tool name.
// api/chat.js builds the structured response contract from `toolResults`
// directly — never from the model's own restatement of those facts.
export async function runAgent({ apiKey, model, history, userMessage }) {
  const messages = [
    { role: 'system', content: SYSTEM_PROMPT },
    ...history,
    { role: 'user', content: userMessage },
  ];

  const tools = getToolSchemas();
  const toolResults = {};
  let webSearchCalls = 0;

  for (let round = 0; round < MAX_TOOL_ROUNDS; round++) {
    const completion = await deepseekChat({ apiKey, model, messages, tools });
    const message = completion.choices?.[0]?.message;
    if (!message) throw new Error('DeepSeek returned no message.');

    if (!message.tool_calls || message.tool_calls.length === 0) {
      return { answerText: message.content || '', toolResults };
    }

    messages.push({ role: 'assistant', content: message.content || null, tool_calls: message.tool_calls });

    for (const call of message.tool_calls) {
      const name = call.function?.name;
      let args = {};
      try {
        args = call.function?.arguments ? JSON.parse(call.function.arguments) : {};
      } catch {
        args = {};
      }

      let result;
      if (name === 'web_search' && webSearchCalls >= 1) {
        // Protects the shared free-tier Tavily quota: at most one live
        // search per chat turn, regardless of how many times the model asks.
        result = { error: 'web_search already used this turn — answer using the data already gathered.' };
      } else {
        try {
          result = await callTool(name, args);
          if (name === 'web_search') webSearchCalls += 1;
        } catch (err) {
          result = { error: err.message };
        }
      }

      // Tool errors (bad args, DB/network failure, etc.) don't throw past
      // this point — they're embedded in the tool result JSON so the model
      // can react to them. Log them server-side too, since otherwise the
      // only trace of a failed tool call is the model's own paraphrase of
      // it in the chat reply, which is exactly the kind of "explaining
      // something it doesn't actually know" this app is built to avoid.
      if (result?.error) {
        console.error(`tool ${name} failed: ${result.error} (args: ${JSON.stringify(args)})`);
      }

      toolResults[name] = result;
      messages.push({ role: 'tool', tool_call_id: call.id, content: JSON.stringify(result) });
    }
  }

  // Loop cap hit without a final answer — ask once more without tools so the
  // user still gets a reply instead of a timeout.
  const fallback = await deepseekChat({ apiKey, model, messages, tools: undefined });
  const fallbackMessage = fallback.choices?.[0]?.message;
  return {
    answerText: fallbackMessage?.content || 'Sorry, I could not complete that request. Please try rephrasing.',
    toolResults,
  };
}
