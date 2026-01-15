<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<title>Schweizer Auto-Theorie Profi-App</title>
<style>
body { font-family: Arial, sans-serif; background:#f9f9f9; margin:0; padding:0; }
.container { max-width:900px; margin:20px auto; background:#fff; padding:20px; border-radius:10px; box-shadow:0 0 15px rgba(0,0,0,0.1); }
h1 { text-align:center; color:#333; }
.question { margin-bottom:20px; padding:10px; border-radius:5px; background:#f1f1f1;}
.options label { display:block; margin:5px 0; cursor:pointer; }
button { padding:10px 20px; font-size:16px; margin-top:20px; cursor:pointer; border:none; border-radius:5px; background:#007bff; color:#fff; }
button:hover { background:#0056b3; }
.result { font-size:20px; margin-top:20px; text-align:center; }
img { max-width:100%; margin:10px 0; }
.correct { color:green; font-weight:bold; }
.wrong { color:red; font-weight:bold; }
#timer { font-size:18px; text-align:right; margin-bottom:10px; color:#333; }
.progress { font-size:16px; margin-bottom:10px; }
</style>
</head>
<body>
<div class="container">
<h1>Schweizer Auto-Theorie Profi-App</h1>
<div id="timer">45:00</div>
<div class="progress" id="progress">Frage 1 von 30</div>
<div id="quiz"></div>
<button id="next">Nächste Frage</button>
<div class="result" id="result"></div>
<button id="export" style="display:none;">Ergebnis exportieren</button>
</div>

<script>
const totalTime = 45*60; // 45 Minuten in Sekunden
let timeLeft = totalTime;
const timerEl = document.getElementById('timer');
let timerInterval = setInterval(()=>{
    let min = Math.floor(timeLeft/60);
    let sec = timeLeft%60;
    timerEl.textContent = `${min.toString().padStart(2,'0')}:${sec.toString().padStart(2,'0')}`;
    if(timeLeft <=0){
        clearInterval(timerInterval);
        alert('Zeit ist abgelaufen! Die Prüfung wird beendet.');
        showResult();
    }
    timeLeft--;
},1000);

let currentIndex = 0;
let userAnswers = [];
const quizData = [
  {question:"1. Achtung Bahnübergang ohne Schranken", img:"https://upload.wikimedia.org/wikipedia/commons/7/7f/CH_Warnschild_Bahnübergang.svg", options:{a:"Achtung Bahnübergang ohne Schranken", b:"Bahnübergang mit Schranken", c:"Nur Strassenbahnverkehr", d:"Verbot für Schienenfahrzeuge"}, answer:"a"},
  {question:"2. Blaues Rondell-Symbol", img:"https://upload.wikimedia.org/wikipedia/commons/e/e5/CH_Kreisel.svg", options:{a:"Vortritt im Kreisverkehr", b:"Verbot der Einfahrt", c:"Richtungsweisung im Kreisverkehr", d:"Ende Zone 30"}, answer:"c"},
  {question:"3. Gelb blinkende Ampel", img:"https://upload.wikimedia.org/wikipedia/commons/4/42/CH_Ampel_gelb_blinkend.svg", options:{a:"Langsam weiterfahren und achten", b:"Gleich schnell weiterfahren", c:"Anhalten, Vortritt gewähren", d:"Sofort losfahren"}, answer:"a"},
  {question:"4. Blauer Kreis{question:"1. Achtung Bahnübergang ohne Schranken", img:"", options:{a:"Achtung Bahnübergang ohne Schranken", b:"Bahnübergang mit Schranken", c:"Nur Strassenbahnverkehr", d:"Verbot für Schienenfahrzeuge"}, answer:"a"},
  {question:"2. Blaues Rondell-Symbol", img:"", options:{a:"Vortritt im Kreisverkehr", b:"Verbot der Einfahrt", c:"Richtungsweisung im Kreisverkehr", d:"Ende Zone 30"}, answer:"c"},
  {question:"3. Gelb blinkende Ampel", img:"", options:{a:"Langsam weiterfahren und achten", b:"Gleich schnell weiterfahren", c:"Anhalten, Vortritt gewähren", d:"Sofort losfahren"}, answer:"a"},
  {question:"4. Blauer Kreis mit Pfeil + Fahrrad", img:"", options:{a:"Fahrräder müssen rechts fahren", b:"Rechtsabbiegen für alle vorgeschrieben", c:"Nur Fahrradverkehr erlaubt", d:"Radfahrer auf der Strasse"}, answer:"a"},
  {question:"5. Schulbus hält, Kinder steigen aus", img:"", options:{a:"Ja, wenn kein Gegenverkehr", b:"Nein, anhalten und warten", c:"Nur wenn Bus blinkt", d:"Nur rechts vorbeifahren"}, answer:"b"},
  {question:"6. Fussgängerstreifen", img:"", options:{a:"Anhalten und Vortritt gewähren", b:"Langsam durchfahren", c:"Nur bremsen wenn er schon auf Zebrastreifen", d:"Hupen, damit er wartet"}, answer:"a"},
  {question:"7. Nebel Sicht <50m", img:"", options:{a:"Nebelscheinwerfer + Abblendlicht einschalten", b:"Fernlicht einschalten", c:"Nur Standlicht", d:"Weiterfahren wie gewohnt"}, answer:"a"},
  {question:"8. Stopp-Schild + Rechtsvortritt", img:"", options:{a:"Anhalten, Vortritt gewähren", b:"Weiterfahren wenn frei", c:"Nur verlangsamen", d:"Nur Rechtsabbieger warten lassen"}, answer:"a"},
  {question:"9. Autobahn, falsche Einordnung", img:"", options:{a:"Rückwärts fahren", b:"Weiter bis nächste Ausfahrt", c:"Links überholen", d:"Sofort rechts stoppen"}, answer:"b"},
  {question:"10. Abbiegen – wer beachten?", img:"", options:{a:"Velofahrer und Fussgänger", b:"Nur Autos", c:"Nur Motorradfahrer", d:"Nur Trams"}, answer:"a"},
  {question:"11. Kreuzung unbeschildert, wer fährt zuerst?", img:"", options:{a:"Fahrzeug von rechts", b:"Fahrzeug mit grösserer Masse", c:"Fahrzeug von links", d:"Fahrzeug mit grösserem Motor"}, answer:"a"},
  {question:"12. Linksabbieger, Gegenverkehr auch links", img:"", options:{a:"Linkskreuzen", b:"Rechtskreuzen", c:"Einer wartet", d:"Hupen und fahren"}, answer:"c"},
  {question:"13. Rettungswagen mit Blaulicht", img:"", options:{a:"Rechts ranfahren und halten", b:"Weiterfahren", c:"Links überholen", d:"Sofort anhalten"}, answer:"a"},
  {question:"14. Unbeschilderte T-Kreuzung", img:"", options:{a:"Rechtsvortritt", b:"Hauptstrasse hat Vortritt", c:"Linksabbieger warten", d:"Kein Vortritt"}, answer:"a"},
  {question:"15. Bahnübergang rotes Licht", img:"", options:{a:"Anhalten", b:"Langsam drüber fahren", c:"Nur hupen", d:"Direkt anhalten und Fenster öffnen"}, answer:"a"},
  {question:"16. Mindestabstand bei 120km/h", img:"", options:{a:"~60 m", b:"~30 m", c:"~120 m", d:"~15 m"}, answer:"a"},
  {question:"17. Nebelschlusslicht", img:"", options:{a:"Nur bei Sicht <50m", b:"Immer nachts", c:"Bei Regen", d:"Nur im Tunnel"}, answer:"a"},
  {question:"18. Überholen Landstrasse", img:"", options:{a:"Nur überholen, wenn freie Sicht", b:"Immer überholen", c:"Ohne Blinker überholen", d:"Nur links rückwärts überholen"}, answer:"a"},
  {question:"19. Zone 30", img:"", options:{a:"Fussgänger haben oft Vortritt", b:"Immer gleich schnell wie woanders", c:"Nur Velos haben Vortritt", d:"Autos dürfen schneller fahren"}, answer:"a"},
  {question:"20. Bergab, Fahrzeug bremst", img:"", options:{a:"Abstand vergrössern & motorbremsen", b:"Sofort Vollbremsung", c:"Hupen", d:"Rechts überholen"}, answer:"a"},
  {question:"21. Linksabbiegen bei Gegenverkehr", img:"", options:{a:"Immer zuerst fahren", b:"Linkskreuzen", c:"Vortritt gewähren", d:"Hupen"}, answer:"c"},
  {question:"22. Ampel rot+Grünpfeil rechts", img:"", options:{a:"Nur bei frei rechts abbiegen", b:"Immer abbiegen", c:"Nur geradeaus", d:"Verbot für Rechtsabbieger"}, answer:"a"},
  {question:"23. Parkieren auf Gehweg", img:"", options:{a:"Erlaubt", b:"Verboten", c:"Nur mit Parkscheibe", d:"Nur Kurzparkzone"}, answer:"b"},
  {question:"24. Geschwindigkeit innerorts", img:"", options:{a:"50 km/h", b:"30 km/h", c:"80 km/h", d:"60 km/h"}, answer:"a"},
  {question:"25. Geschwindigkeitsbegrenzung auf Landstrasse", img:"", options:{a:"100 km/h", b:"80 km/h", c:"120 km/h", d:"90 km/h"}, answer:"a"},
  {question:"26. Spurwechsel Autobahn", img:"", options:{a:"Mit Blinker & Rückspiegel", b:"Nur Blinker", c:"Ohne Blinker", d:"Nur Spur beobachten"}, answer:"a"},
  {question:"27. Kreisverkehr Einfahrt mit rotem Schild", img:"", options:{a:"Nicht einfahren", b:"Langsam fahren", c:"Immer einfahren", d:"Nur links einfahren"}, answer:"a"},
  {question:"28. Rechtsvortritt bei Strassenverengung", img:"", options:{a:"Rechts hat Vortritt", b:"Links hat Vortritt", c:"Grösseres Fahrzeug", d:"Schnelleres Fahrzeug"}, answer:"a"},
  {question:"29. Bahnübergang mit Schranken", img:"", options:{a:"Warten bis Schranke hoch", b:"Direkt fahren", c:"Nur hupen", d:"Überholen erlaubt"}, answer:"a"},
  {question:"30. Autobahn Regen & Aquaplaning", img:"", options:{a:"Geschwindigkeit reduzieren", b:"Schneller fahren", c:"Blinken", d:"Abstand verkleinern"}, answer:"a"} mit Pfeil + Fahrrad", img:"https://upload.wikimedia.org/wikipedia/commons/c/c4/CH_Fahrverbot_Fahrrad.svg", options:{a:"Fahrräder müssen rechts fahren", b:"Rechtsabbiegen für alle vorgeschrieben", c:"Nur Fahrradverkehr erlaubt", d:"Radfahrer auf der Strasse"}, answer:"a"},
  {question:"31. Schulbus hält, Kinder steigen aus", img:"https://upload.wikimedia.org/wikipedia/commons/6/64/CH_Schulbus_Halt.svg", options:{a:"Ja, wenn kein Gegenverkehr", b:"Nein, anhalten und warten", c:"Nur wenn Bus blinkt", d:"Nur rechts vorbeifahren"}, answer:"b"},
  // hier die restlichen 25 Fragen hinzufügen...
];

// Zufällige Reihenfolge
function shuffle(array){for(let i=array.length-1;i>0;i--){let j=Math.floor(Math.random()*(i+1));[array[i],array[j]]=[array[j],array[i]];} return array;}
shuffle(quizData);

const quizEl = document.getElementById('quiz');
const progressEl = document.getElementById('progress');
const nextBtn = document.getElementById('next');
const resultEl = document.getElementById('result');
const exportBtn = document.getElementById('export');

function showQuestion(){
    quizEl.innerHTML = '';
    const q = quizData[currentIndex];
    const questionEl = document.createElement('div');
    questionEl.classList.add('question');
    let optionsHtml = '';
    for(const key in q.options){
        optionsHtml += `<label><input type="radio" name="q" value="${key}"> ${q.options[key]}</label>`;
    }
    questionEl.innerHTML = `<p><strong>${q.question}</strong></p>${q.img?'<img src="'+q.img+'">':''}<div class="options">${optionsHtml}</div>`;
    quizEl.appendChild(questionEl);
    progressEl.textContent = `Frage ${currentIndex+1} von ${quizData.length}`;
}

nextBtn.addEventListener('click',()=>{
    const selected = document.querySelector('input[name="q"]:checked');
    if(!selected){alert('Bitte eine Antwort auswählen!'); return;}
    userAnswers[currentIndex] = selected.value;
    currentIndex++;
    if(currentIndex < quizData.length){ showQuestion(); } else { showResult(); }
});

function showResult(){
    clearInterval(timerInterval);
    quizEl.innerHTML='';
    nextBtn.style.display='none';
    let score=0;
    let html = '';
    quizData.forEach((q,i)=>{
        const userAns = userAnswers[i];
        if(userAns===q.answer){score++; html+=`<p>${i+1}. ${q.question} ✅ richtig</p>`;}
        else{html+=`<p>${i+1}. ${q.question} ❌ falsch (Deine Antwort: ${userAns}, richtig: ${q.answer})</p>`;}
    });
    resultEl.innerHTML = `Du hast ${score} von ${quizData.length} richtig (${Math.round(score/quizData.length*100)}%)<br>`+(score>=Math.ceil(quizData.length*0.85)?'<span class="correct">Bestanden ✅</span>':'<span class="wrong">Nicht bestanden ❌</span>')+'<hr>'+html;
    exportBtn.style.display='inline';
}

exportBtn.addEventListener('click',()=>{
    const blob = new Blob([resultEl.innerText],{type:'text/plain'});
    const url = URL.createObjectURL(blob);
    const a=document.createElement('a'); a.href=url; a.download='Ergebnis.txt'; a.click(); URL.revokeObjectURL(url);
});

showQuestion();
</script>
</body>
</html>
