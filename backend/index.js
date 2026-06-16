const express = require("express");
const cors = require("cors");
const OpenAI = require("openai");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json({ limit: "1mb" }));

const openai = new OpenAI({
  apiKey: process.env.API_KEY,
  baseURL: process.env.BASE_URL || "https://api.siliconflow.cn/v1",
});

const SYSTEM_PROMPT =
  "你是小镜，一个温暖共情的AI陪伴者。用中文回答，不超过80字，先共情再引导。";

app.get("/", (_req, res) => {
  res.json({ name: "心镜AI云服务", status: "ok" });
});

app.post("/api/chat", async (req, res) => {
  try {
    const { messages } = req.body;
    if (!messages?.length) {
      return res.status(400).json({ error: "no messages" });
    }

    const recentMessages = messages.slice(-20);
    const completion = await openai.chat.completions.create({
      model: process.env.MODEL || "Qwen/Qwen2.5-7B-Instruct",
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        ...recentMessages,
      ],
      max_tokens: 300,
    });

    const reply = (completion.choices[0]?.message?.content || "").trim();
    res.json({ reply });
  } catch (err) {
    console.error("[心镜] API error:", err.message);
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => console.log("⭐ 心镜云服务运行中"));
