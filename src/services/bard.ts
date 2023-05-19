import dotenv from "dotenv";
dotenv.config();

import { Bard } from "googlebard";
import { Prompt } from "../training/postgres-data-entity.js";

const cookies = process.env.BARD_COOKIE;

if (!cookies) throw new Error("cookie not set");

export const trainPrompt = async (
  conversationId: string,
  prompts: Prompt[]
) => {
  const bot = new Bard(cookies, {
    inMemory: false,
    savePath: `./src/conversations/${conversationId}.json`,
  });

  bot.resetConversation(conversationId);

  for (const prompt of prompts) {
    console.log(`--------`);
    console.log(`Me: ${prompt.input}`);
    const response = await bot.ask(prompt.input, conversationId);
    await new Promise((resolve) => setTimeout(resolve, 30000));
    console.log(`Bard: ${response}`);
    console.log(`--------`);
  }
};

const parse = (input: string) => {
  console.log(input);

  // Pick out the json

  let json: string | undefined;
  let searchString = "```json";

  if (input.search(searchString)) {
    json = input.substring(
      input.indexOf("```json") + 7,
      input.lastIndexOf("```")
    );
  } else {
    json = input.substring(input.indexOf("```") + 3, input.lastIndexOf("```"));
  }

  // Remove the file template
  const body = json.substring(json.indexOf("`") + 1, json.lastIndexOf("`"));

  // Remove the body key and parse
  const cleaned = JSON.parse(json.replaceAll(body, '""').replaceAll("`", ""));

  // Then add the body back
  return {
    ...cleaned,
    fileBody: body,
  };
};

type File = {
  fileName: string;
  fileBody: string;
};

export const ask = async (
  conversationId: string,
  prompt: Prompt
): Promise<File> => {
  const bot = new Bard(cookies, {
    inMemory: false,
    savePath: `./src/conversations/${conversationId}.json`,
  });

  try {
    console.log("asking...", prompt.input);
    const response = await bot.ask(prompt.input, conversationId);
    return parse(response);
  } catch {
    // do nothing
  }

  return {
    fileName: "dummy.txt",
    fileBody: "",
  };
};
