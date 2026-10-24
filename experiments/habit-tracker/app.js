const storageKey = 'habit-tracker-items';
const form = document.querySelector('#habit-form');
const titleInput = document.querySelector('#habit-title');
const categoryInput = document.querySelector('#habit-category');
const goalInput = document.querySelector('#habit-goal');
const habitList = document.querySelector('#habit-list');
const emptyState = document.querySelector('#empty-state');
const message = document.querySelector('#message');
const editDialog = document.querySelector('#edit-dialog');
const editForm = document.querySelector('#edit-form');
const editTitle = document.querySelector('#edit-title');
const editCategory = document.querySelector('#edit-category');
const editGoal = document.querySelector('#edit-goal');
const importInput = document.querySelector('#import-input');

let activeFilter = 'all';
let editingId = null;

function localDay(offset = 0) {
  const date = new Date();
  date.setHours(12, 0, 0, 0);
  date.setDate(date.getDate() + offset);
  return date.toISOString().slice(0, 10);
}

function createId() {
  return globalThis.crypto?.randomUUID?.() ?? `${Date.now()}-${Math.random().toString(16).slice(2)}`;
}

function normaliseHabit(raw) {
  const history = raw?.history && typeof raw.history === 'object' ? raw.history : {};
  if (raw?.completed && Object.keys(history).length === 0) history[localDay()] = true;
  return {
    id: String(raw?.id ?? createId()),
    title: String(raw?.title ?? raw?.text ?? 'Neue Gewohnheit').trim().slice(0, 60) || 'Neue Gewohnheit',
    category: String(raw?.category ?? 'Alltag'),
    goal: [3, 5, 7].includes(Number(raw?.goal)) ? Number(raw.goal) : 5,
    history,
    createdAt: raw?.createdAt ?? new Date().toISOString(),
  };
}

function readHabits() {
  try {
    const parsed = JSON.parse(localStorage.getItem(storageKey) ?? '[]');
    return Array.isArray(parsed) ? parsed.map(normaliseHabit) : [];
  } catch {
    return [];
  }
}

let habits = readHabits();

function saveHabits() {
  localStorage.setItem(storageKey, JSON.stringify(habits));
}

function completedToday(habit) {
  return Boolean(habit.history[localDay()]);
}

function weekCount(habit) {
  return Array.from({ length: 7 }, (_, index) => localDay(-index)).filter((day) => habit.history[day]).length;
}

function currentStreak() {
  let streak = 0;
  for (let offset = 0; offset < 365; offset += 1) {
    const day = localDay(-offset);
    if (!habits.some((habit) => habit.history[day])) break;
    streak += 1;
  }
  return streak;
}

function showMessage(text) {
  message.textContent = text;
}

function button(text, action, habitId, extraClass = '') {
  const element = document.createElement('button');
  element.type = 'button';
  element.className = `text-button ${extraClass}`;
  element.textContent = text;
  element.dataset.action = action;
  element.dataset.id = habitId;
  return element;
}

function renderSummary() {
  const completed = habits.filter(completedToday).length;
  const total = habits.length;
  const percentage = total ? Math.round((completed / total) * 100) : 0;
  document.querySelector('#completed-count').textContent = completed;
  document.querySelector('#total-count').textContent = ` / ${total}`;
  document.querySelector('#daily-progress').style.width = `${percentage}%`;
  document.querySelector('#progress-label').textContent = total ? `${percentage}% deines Tagesziels geschafft.` : 'Starte mit deiner ersten Gewohnheit.';
  document.querySelector('#streak-count').textContent = currentStreak();
  document.querySelector('#week-count').textContent = habits.reduce((sum, habit) => sum + weekCount(habit), 0);
}

function renderHabits() {
  const visibleHabits = habits.filter((habit) => activeFilter === 'all' || (activeFilter === 'done' ? completedToday(habit) : !completedToday(habit)));
  habitList.replaceChildren();
  emptyState.hidden = visibleHabits.length !== 0;

  visibleHabits.forEach((habit) => {
    const isDone = completedToday(habit);
    const item = document.createElement('li');
    item.className = `habit-item${isDone ? ' done' : ''}`;
    item.dataset.id = habit.id;

    const check = document.createElement('button');
    check.type = 'button';
    check.className = 'check-button';
    check.dataset.action = 'toggle';
    check.dataset.id = habit.id;
    check.setAttribute('aria-label', `${habit.title} ${isDone ? 'als offen markieren' : 'als erledigt markieren'}`);
    check.textContent = '✓';

    const main = document.createElement('div');
    main.className = 'habit-main';
    const title = document.createElement('span');
    title.className = 'habit-title';
    title.textContent = habit.title;
    const meta = document.createElement('div');
    meta.className = 'habit-meta';
    const tag = document.createElement('span');
    tag.className = 'tag';
    tag.textContent = habit.category;
    const goal = document.createElement('span');
    goal.textContent = `Diese Woche ${weekCount(habit)}/${habit.goal}×`;
    meta.append(tag, goal);
    main.append(title, meta);

    const actions = document.createElement('div');
    actions.className = 'habit-actions';
    actions.append(button('Bearbeiten', 'edit', habit.id), button('Löschen', 'delete', habit.id, 'danger'));
    item.append(check, main, actions);
    habitList.appendChild(item);
  });
  renderSummary();
}

function renderDate() {
  const date = new Date();
  document.querySelector('#today-weekday').textContent = new Intl.DateTimeFormat('de-DE', { weekday: 'long' }).format(date);
  document.querySelector('#today-date').textContent = new Intl.DateTimeFormat('de-DE', { day: '2-digit', month: 'short' }).format(date);
}

form.addEventListener('submit', (event) => {
  event.preventDefault();
  const title = titleInput.value.trim();
  if (!title) return;
  habits.unshift(normaliseHabit({ id: createId(), title, category: categoryInput.value, goal: Number(goalInput.value), history: {}, createdAt: new Date().toISOString() }));
  saveHabits();
  renderHabits();
  form.reset();
  goalInput.value = '5';
  titleInput.focus();
  showMessage('Gewohnheit angelegt – dein erster Schritt ist getan.');
});

habitList.addEventListener('click', (event) => {
  const control = event.target.closest('button[data-action]');
  if (!control) return;
  const habit = habits.find((entry) => entry.id === control.dataset.id);
  if (!habit) return;
  if (control.dataset.action === 'toggle') {
    const today = localDay();
    if (habit.history[today]) delete habit.history[today]; else habit.history[today] = true;
    saveHabits(); renderHabits(); showMessage(habit.history[today] ? 'Erledigt – stark gemacht!' : 'Für heute wieder als offen markiert.');
  }
  if (control.dataset.action === 'delete') {
    if (!window.confirm(`„${habit.title}“ wirklich löschen?`)) return;
    habits = habits.filter((entry) => entry.id !== habit.id);
    saveHabits(); renderHabits(); showMessage('Gewohnheit gelöscht.');
  }
  if (control.dataset.action === 'edit') {
    editingId = habit.id;
    editTitle.value = habit.title;
    editCategory.value = habit.category;
    editGoal.value = String(habit.goal);
    editDialog.showModal();
    editTitle.focus();
  }
});

document.querySelectorAll('.filter').forEach((filter) => filter.addEventListener('click', () => {
  activeFilter = filter.dataset.filter;
  document.querySelectorAll('.filter').forEach((item) => item.classList.toggle('active', item === filter));
  renderHabits();
}));

editForm.addEventListener('submit', (event) => {
  event.preventDefault();
  if (event.submitter?.value === 'cancel') { editDialog.close(); return; }
  const habit = habits.find((entry) => entry.id === editingId);
  if (!habit || !editTitle.value.trim()) return;
  habit.title = editTitle.value.trim();
  habit.category = editCategory.value;
  habit.goal = Number(editGoal.value);
  saveHabits(); renderHabits(); editDialog.close(); showMessage('Gewohnheit gespeichert.');
});

document.querySelector('#export-button').addEventListener('click', () => {
  const content = JSON.stringify({ exportedAt: new Date().toISOString(), habits }, null, 2);
  const url = URL.createObjectURL(new Blob([content], { type: 'application/json' }));
  const link = document.createElement('a');
  link.href = url; link.download = `habit-flow-${localDay()}.json`; link.click();
  URL.revokeObjectURL(url);
  showMessage('Deine Gewohnheiten wurden exportiert.');
});

importInput.addEventListener('change', async () => {
  const [file] = importInput.files;
  if (!file) return;
  try {
    const data = JSON.parse(await file.text());
    const imported = Array.isArray(data) ? data : data.habits;
    if (!Array.isArray(imported)) throw new Error('Ungültiges Format');
    habits = imported.map(normaliseHabit);
    saveHabits(); renderHabits(); showMessage(`${habits.length} Gewohnheiten importiert.`);
  } catch {
    showMessage('Import nicht möglich: Bitte eine gültige Habit-Flow-JSON auswählen.');
  } finally { importInput.value = ''; }
});

renderDate();
renderHabits();
