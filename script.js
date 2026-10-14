// 0 = horse
// 1 = jeep
// 2 = volvo
// 3 = lada
// 4 = porsche
// 5 = cyber

let scores = [0, 0, 0, 0, 0];

const form = document.getElementById("quiz-form");
const radios = document.querySelectorAll(".options-list input[type='radio']");
const questions = document.querySelectorAll(".quiz-container");

let current = 0;


function showQuestion() {
    questions.forEach(function (question, index) {
        if (index === current) {
            question.classList.remove("hidden");
        } else {
            question.classList.add("hidden");
        }
    });
}


// kad izvēlas atbildi, ejam uz nākamo jautājumu
radios.forEach(function (radio) {
    radio.addEventListener("change", function () {
        current++;

        showQuestion();
    });
});


form.addEventListener("submit", function (event) {

    // neļaujam formai pārlādēt lapu
    event.preventDefault();

    scores = [0, 0, 0, 0, 0];

    // savācam visas izvēlētās atbildes no formas
    const formData = new FormData(form);

    formData.forEach(function (answer) {

        let values = answer.split(",");

        values.forEach(function (value) {
            scores[Number(value)]++;
        });
    });


    let highestScore = Math.max(...scores);

    let winners = [];

    scores.forEach(function (score, index) {
        if (score === highestScore) {
            winners.push(index);
        }
    });


    let result;

    if (winners.length > 1) {
        result = 5;
    } else {
        result = winners[0];
    }


    questions.forEach(function (question) {
        question.classList.add("hidden");
    });

    document.querySelector(".results").classList.remove("hidden");

    document.getElementById("result-" + result).classList.remove("hidden");
});


// READY SET GO
const intro = document.getElementById("intro");
const countdown = document.getElementById("countdown");
const start = document.getElementById("start");

const words = ["READY", "SET", "GO!"];
let wordIndex = 0;

function showNextWord() {
    if (wordIndex < words.length) {
        countdown.textContent = words[wordIndex];

        // restartējam animāciju katram vārdam
        countdown.classList.remove("pop");
        void countdown.offsetWidth;
        countdown.classList.add("pop");

        wordIndex++;
        setTimeout(showNextWord, 1000);
    } else {
        countdown.classList.add("hidden");
        start.classList.remove("hidden");
    }
}

start.addEventListener("click", function () {
    intro.classList.add("hidden");
    form.classList.remove("hidden");

    showQuestion();
});


showNextWord();
