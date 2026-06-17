export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") return new Response(null,{headers:{"Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"POST,GET","Access-Control-Allow-Headers":"Content-Type"}});
    const url = new URL(request.url);
    if (url.pathname === "/api/chat" && request.method === "POST") {
      try {
        const {messages} = await request.json();
        if (!messages?.length) return new Response(JSON.stringify({error:"no messages"}),{status:400,headers:{"Content-Type":"application/json","Access-Control-Allow-Origin":"*"}});
        const resp = await fetch("https://api.deepseek.com/chat/completions",{
          method:"POST",
          headers:{"Content-Type":"application/json","Authorization":"Bearer "+env.API_KEY},
          body:JSON.stringify({model:"deepseek-chat",messages:[{role:"system",content:"你是小镜温暖共情的AI陪伴者用中文回答不超过80字先共情再引导"},...messages.slice(-10)],max_tokens:300,temperature:0.8})
        });
        const data = await resp.json();
        return new Response(JSON.stringify({reply:(data.choices?.[0]?.message?.content||"").trim()||"小镜暂时无法回应~"}),{headers:{"Content-Type":"application/json","Access-Control-Allow-Origin":"*"}});
      } catch(e) {
        return new Response(JSON.stringify({error:e.message||"小镜有点卡"}),{status:500,headers:{"Content-Type":"application/json","Access-Control-Allow-Origin":"*"}});
      }
    }
    return new Response(JSON.stringify({name:"心镜AI云服务",status:"ok"}),{headers:{"Content-Type":"application/json","Access-Control-Allow-Origin":"*"}});
  }
};
