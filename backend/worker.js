export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") return new Response(null,{headers:{"Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"POST,GET","Access-Control-Allow-Headers":"Content-Type"}});
    const url = new URL(request.url);  
  // Rate limiting by IP
  const ip = request.headers.get('CF-Connecting-IP') || 'unknown';
  const rateKey = l:_ + ip;
    if (url.pathname === "/api/chat" && request.method === "POST") {
      try {
        const {messages} = await request.json();
        if (!messages?.length) return new Response(JSON.stringify({error:"no messages"}),{status:400,headers:{"Content-Type":"application/json","Access-Control-Allow-Origin":"*"}});
        const resp = await fetch("https://api.deepseek.com/chat/completions",{
          method:"POST",
          headers:{"Content-Type":"application/json","Authorization":"Bearer "+env.API_KEY},
          body:JSON.stringify({model:"deepseek-chat",messages:[{role:"system",content:"浣犳槸灏忛暅娓╂殩鍏辨儏鐨凙I闄即鑰呯敤涓枃鍥炵瓟涓嶈秴杩?0瀛楀厛鍏辨儏鍐嶅紩瀵?},...messages.slice(-10)],max_tokens:300,temperature:0.8})
        });
        const data = await resp.json();
        return new Response(JSON.stringify({reply:(data.choices?.[0]?.message?.content||"").trim()||"灏忛暅鏆傛椂鏃犳硶鍥炲簲~"}),{headers:{"Content-Type":"application/json","Access-Control-Allow-Origin":"*"}});
      } catch(e) {
        return new Response(JSON.stringify({error:e.message||"灏忛暅鏈夌偣鍗?}),{status:500,headers:{"Content-Type":"application/json","Access-Control-Allow-Origin":"*"}});
      }
    }
    return new Response(JSON.stringify({name:"蹇冮暅AI浜戞湇鍔?,status:"ok"}),{headers:{"Content-Type":"application/json","Access-Control-Allow-Origin":"*"}});
  }
};

