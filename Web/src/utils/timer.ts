import { ref } from 'vue';

let timer = 0;
let timerIncrease: any;
const timerString = ref<string>("");

function timerStart(): boolean {
  if (timer !== 0) return false;
  timerIncrease = setInterval(() => {
    timer += 1;
    timerString.value = getTimer();
  }, 1000);
  return true;
}

function timerClear() {
  clearInterval(timerIncrease);
  timer = 0;
}

function getTimer() {
  const h = Math.floor(timer / 3600);
  const m = Math.floor(((timer / 60) % 60));
  const s = Math.floor((timer % 60));
  let result = `${s}`;
  if (s < 10) result = `0${s}`;
  result = `${m}:${result}`;
  if (m < 10) result = `0${result}`;
  if (h > 10) result = `${h}:${result}`;
  else if (h > 0) result = `0${h}:${result}`;
  return result;
}

export {
  timer,
  timerString,
  timerStart,
  timerClear
};
