import dotenv from "dotenv";
dotenv.config();

import { Bard } from "googlebard";

const cookies = process.env.BARD_COOKIE;

if (!cookies) throw new Error("cookie not set");

const bot = new Bard(cookies, {
  inMemory: true,
});

const conversationId = "hello world"; // optional: to make it remember the conversation

const response = await bot.ask("Hello?", conversationId); // conversationId is optional
console.log(response);
