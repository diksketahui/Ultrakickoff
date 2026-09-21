let state={club:null,tactics:defaultTactics(),academy:[],inbox:[],target:'-'};
const $=s=>document.querySelector(s);
function avatar(n){return '['+n.split(' ').map(w=>w[0]).join('').slice(0,2).toUpperCase()+'] ';}
function init(){const sel=$('#clubSelect');ALL_TEAMS.forEach(t=>{const o=document.createElement('option');o.value=t.id;o.textContent=t.name+' ('+t.ovr+')';sel.appendChild(o);});
document.querySelectorAll('nav button').forEach(x=>x.onclick=()=>{document.querySelectorAll('main section').forEach(s=>s.hidden=true);$('#tab-'+x.dataset.tab).hidden=false;});
$('#startBtn').onclick=()=>{state.club=ALL_TEAMS.find(t=>t.id===sel.value);state.target=Manager.setTarget(state.club.division,2);$('#dashInfo').textContent='Karir: '+state.club.name+' | Target: '+state.target+' | Conf '+Manager.confidence;renderSquad();renderBoard();};
$('#saveTaktik').onclick=()=>{const t=state.tactics;t.formation=$('#t-form').value;t.line=+$('#t-line').value;t.press=+$('#t-press').value;t.tempo=+$('#t-tempo').value;t.build=$('#t-build').value;t.passLen=$('#t-passlen').value;t.passDir=$('#t-passdir').value;alert('Taktik: '+describeTactics(t));};
$('#simBtn').onclick=()=>{if(!state.club)return alert('Pilih klub');const opp=ALL_TEAMS.filter(t=>t.id!==state.club.id)[Math.floor(Math.random()*20)];const ref=Manager.refEvent($('#refBribe').checked?'sogok':'bersih');const r=simMatch({name:state.club.name,ovr:state.club.ovr,staminaAvg:75,moodAvg:70},{name:opp.name,ovr:opp.ovr,staminaAvg:72,moodAvg:68},state.tactics,defaultTactics(),{refBias:ref.bias});const res=r.hs>r.as?'win':(r.hs===r.as?'draw':'lose');$('#liveLog').textContent=r.log.join('\n')+'\nFT '+state.club.name+' '+r.hs+'-'+r.as+' '+opp.name+'\nWasit: '+ref.info+'\nBoard: '+Manager.boardTick(res)+' | Fans: '+Manager.fanTick(res)+ '\nSponsor: '+Manager.sponsorTick(res)+'\nStat: '+JSON.stringify(r.stats);state.inbox.unshift(Manager.rumor(opp.name));renderInbox();renderBoard();};
$('#intakeBtn').onclick=()=>{state.academy=Manager.academyIntake();$('#academyList').innerHTML=state.academy.map(p=>avatar(p.name)+p.name+' | '+p.age+'th OVR '+p.ovr+' POT '+p.pot+' S'+p.stam+' | '+p.type).join('<br>');};
$('#titipanBtn').onclick=()=>{const e=Manager.titipanEvent();state.inbox.unshift('TITIPAN: '+e.TITIPAN+' | '+e.efek);renderInbox();};
$('#pressBtn').onclick=()=>{state.inbox.unshift('Press: '+Manager.press($('#pressSel').value));renderInbox();renderBoard();};
}
function renderSquad(){let h='';for(let i=0;i<11;i++){const age=19+Math.floor(Math.random()*16);let ovr=Math.max(RATING_MIN,state.club.ovr-8+Math.floor(Math.random()*12));ovr=Manager.ageDecline(age,ovr);h+=avatar(state.club.name)+' P'+(i+1)+' '+age+'th OVR '+ovr+' S80 M70 puas '+Manager.satisfaction(60,50)+'<br>';}$('#squadList').innerHTML=h;}
function renderInbox(){$('#inboxList').innerHTML=state.inbox.map(m=>'<div class="card">'+m+'</div>').join('');}
function renderBoard(){$('#boardInfo').innerHTML='Target '+state.target+' | Conf '+Manager.confidence+' Fans '+Manager.fanMood+' Sponsor '+Manager.sponsor+' Kas '+Manager.cash+'<br>Stadion '+state.club.stadium+' | '+Manager.stadiumIncome(15000); }
init();
