const startButton = document.querySelector('#start-flow');
const status = document.querySelector('#flow-status');
const steps = [...document.querySelectorAll('.step')];
let timerIds = [];

function clearFlow() {
  timerIds.forEach((timerId) => window.clearTimeout(timerId));
  timerIds = [];
  steps.forEach((step) => step.classList.remove('is-active'));
}

function playFlow() {
  clearFlow();
  startButton.disabled = true;
  status.textContent = 'Ablauf läuft: Wir beginnen mit deinem Auftrag.';

  steps.forEach((step, index) => {
    const timerId = window.setTimeout(() => {
      steps.forEach((item) => item.classList.remove('is-active'));
      step.classList.add('is-active');
      status.textContent = `Schritt ${index + 1} von ${steps.length}: ${step.querySelector('h3').textContent}.`;

      if (index === steps.length - 1) {
        startButton.disabled = false;
        status.textContent = 'Fertig: Ergebnis geprüft und nachvollziehbar übergeben.';
      }
    }, index * 1100);
    timerIds.push(timerId);
  });
}

startButton.addEventListener('click', playFlow);
