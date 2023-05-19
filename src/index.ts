import dotenv from "dotenv";
dotenv.config();

import { ask } from "./services/bard.js";
import { askPrompt, conversationId } from "./training/postgres-data-entity.js";
import { createOutput, writeFile } from "./services/file.js";
import { getTables } from "./datasources/postgres.js";

createOutput();
const tables = getTables();

for (const table of tables) {
  const response = await ask(conversationId, { input: askPrompt(table) });
  writeFile(response.fileName, response.fileBody);
  console.log(response);
  await new Promise((resolve) => setTimeout(resolve, 10000));
}

process.exit();
