export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return new Response(null, {headers:{'Access-Control-Allow-Origin':'*','Access-Control-Allow-Methods':'POST,GET','Access-Control-Allow-Headers':'Content-Type'}});
    }
    const url = new URL(request.url);
    if (url.pathname === '/api/chat' && request.method === 'POST') {
      try {
        const {messages} = await request.json();
        if (!messages?.length) {
          return new Response(JSON.stringify({error:'no messages'}),{status:400,headers:{'Content-Type':'application/json','Access-Control-Allow-Origin':'*'}});
        }
        const r = await env.AI.run('@cf/meta/llama-3.1-8b-instruct',{
          messages:[
            {role:'system',content:'你是"小镜"，温暖共情的AI陪伴者。用中文回答，每次不超过80字。先共情再引导，偶尔加温暖的表情符号。'},
            ...messages.slice(-10)
          ],
          max_tokens:300,
          temperature:0.8
        });
        return new Response(JSON.stringify({reply:r.response?.trim()||'小镜暂时无法回应~'}),{headers:{'Content-Type':'application/json','Access-Control-Allow-Origin':'*'}});
      } catch(e) {
        return new Response(JSON.stringify({error:'小镜有点卡 🙏'}),{status:500,headers:{'Content-Type':'application/json','Access-Control-Allow-Origin':'*'}});
      }
    }
    return new Response(JSON.stringify({name:'心镜AI云服务',status:'ok'}),{headers:{'Content-Type':'application/json','Access-Control-Allow-Origin':'*'}});
  }
};
