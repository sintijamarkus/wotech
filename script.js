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


showQuestion();
