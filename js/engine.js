// Match engine per-menit: rating+taktik+stamina+mood+home+wasit
function clamp(v,a,b){return Math.max(a,Math.min(b,v));}
function teamStrength(x,t,home){const m=tacticsModifier(t);let s=x.ovr+m.att*10+(home?2:0);s+=(x.staminaAvg-70)*0.05+(x.moodAvg-70)*0.03;return{s,m};}
function simMinute(att,def,tA,tB,ctx){const A=teamStrength(att,tA,true),B=teamStrength(def,tB,false);
let pA=clamp(0.028+(A.s-70)*0.0012,0.004,0.09)*A.m.xg,pB=clamp(0.024+(B.s-70)*0.0012,0.004,0.08)*B.m.xg;
if(ctx.refBias==='home')pA*=1.15;if(ctx.refBias==='away')pB*=1.15;
if(ctx.parkBus==='home')pA*=0.85;if(ctx.parkBus==='away')pB*=0.85;
const r=Math.random();if(r<pA)return'home';if(r<pA+pB)return'away';return null;}
function simMatch(home,away,tH,tA,opts={}){let hs=0,as=0,log=[],chH=0,chA=0;for(let m=1;m<=90;m++){const g=simMinute(home,away,tH,tA,{home:true,refBias:opts.refBias,parkBus:opts.parkBus});if(Math.random()<0.09)chH++;if(Math.random()<0.08)chA++;if(g==='home'){hs++;log.push(m+"' GOL "+home.name);}if(g==='away'){as++;log.push(m+"' GOL "+away.name);}if(m===45||m===90)log.push(m+"' skor "+hs+"-"+as);}return{hs,as,log,stats:{chancesH:chH,chancesA:chA,tacticH:describeTactics(tH),tacticA:describeTactics(tA)}};}
