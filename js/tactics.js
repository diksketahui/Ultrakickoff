// Taktik bebas: tim + per-pemain (arah gerakan, naik-turun, garis, arah umpan)
function defaultTactics(){return{formation:'4-4-2',line:50,width:50,press:50,tempo:50,build:'tengah',passLen:'campuran',passDir:'maju',players:{}};}
function playerTactic(t,id){if(!t.players[id])t.players[id]={run:'support',vertical:50,drift:50,passDir:'maju',role:'default',marking:'zona',press:50};return t.players[id];}
function setFormation(t,f){t.formation=f;return t;}
function tacticsModifier(t){const m={att:(t.line-50)*0.004+(t.tempo-50)*0.003,def:(50-t.line)*0.004+(t.press-50)*0.002,xg:1+(t.tempo-50)*0.002};if(t.build==='kiri'||t.build==='kanan')m.att+=0.01;if(t.passLen==='panjang')m.xg+=0.03;if(t.passLen==='pendek')m.xg-=0.02;return m;}
function describeTactics(t){return t.formation+' | garis '+t.line+' | '+t.build+' | '+t.passLen+'/'+t.passDir;}
