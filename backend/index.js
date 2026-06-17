require("dotenv").config();
const express = require("express");
const cors = require("cors");
const OpenAI = require("openai");
const app = express();
const PORT = process.env.PORT || 3000;
app.use(cors());
app.use(express.json({limit:"1mb"}));
app.get("/",(r,s)=>s.json({name:"心镜AI云服务",status:"ok"}));
let openai; try { openai = new OpenAI({apiKey:process.env.API_KEY,baseURL:process.env.BASE_URL||"https://api.siliconflow.cn/v1"}); } catch(e) {}
app.post("/api/chat",async(r,s)=>{try{
  if(!r.body.messages) return s.status(400).json({error:"no messages"});
  const c=await openai.chat.completions.create({model:process.env.MODEL||"Qwen/Qwen2.5-7B-Instruct",messages:[{role:"system",content:"你是小镜温暖共情的AI陪伴者用中文回答不超过80字先共情再引导"},...r.body.messages.slice(-20)],max_tokens:300});
  s.json({reply:(c.choices[0]?.message?.content||"").trim()});
}catch(e){s.status(500).json({error:e.message})}});
app.listen(PORT,()=>console.log("⭐ 心镜云服务运行中"));
