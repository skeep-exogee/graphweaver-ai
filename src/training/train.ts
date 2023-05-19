import { trainPrompt } from "../services/bard.js";
import { conversationId, prompts } from "./postgres-data-entity.js";

await trainPrompt(conversationId, prompts);

process.exit();
