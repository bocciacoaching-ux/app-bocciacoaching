const {chromium}=require('playwright');
const [,,out,email,steps]=process.argv;
(async()=>{const b=await chromium.launch();const p=await b.newPage({viewport:{width:390,height:844}});
const logs=[];p.on('console',m=>{const t=m.text();if(t.includes('[DEMO]')||m.type()==='error')logs.push(t.slice(0,300))});
p.on('pageerror',e=>logs.push('PAGEERROR '+e.message.slice(0,300)));
await p.goto('http://localhost:8766/a/demo/index.html');await p.waitForTimeout(5000);
await p.evaluate(()=>{const e=document.querySelector('flt-semantics-placeholder');if(e)e.click()});await p.waitForTimeout(800);
await p.screenshot({path:out+'/d0.png'});
if(email){
 await p.mouse.click(195,389);await p.waitForTimeout(400);await p.keyboard.type(email,{delay:20});
 await p.mouse.click(195,502);await p.waitForTimeout(400);await p.keyboard.type('demo1234',{delay:20});
 await p.mouse.click(195,595);
 await p.waitForTimeout(5000);await p.screenshot({path:out+'/d1.png'});
}
console.log([...new Set(logs)].join('\n'));await b.close();})();
