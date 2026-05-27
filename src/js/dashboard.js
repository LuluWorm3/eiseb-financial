// ================================================
// Dashboard Logic — Eiseb Financial System
// Uses localStorage to simulate a database
// Replace with real AJAX/J2EE calls in production
// ================================================

// --- Sample seed data (loaded on first visit) ---
const SEED_TRANSACTIONS = [
  { id: 1, type: "Income",  category: "Livestock Sale",   amount: 45000, date: "2026-04-10", desc: "Sold 3 cattle at auction" },
  { id: 2, type: "Expense", category: "Feed",             amount: 8500,  date: "2026-04-12", desc: "Monthly feed supply" },
  { id: 3, type: "Income",  category: "Auction Proceeds", amount: 32000, date: "2026-04-18", desc: "April auction" },
  { id: 4, type: "Expense", category: "Veterinary",       amount: 2200,  date: "2026-04-20", desc: "Vaccination round" },
  { id: 5, type: "Expense", category: "Transport",        amount: 3800,  date: "2026-04-22", desc: "Livestock transport to Windhoek" },
];

function getTransactions() {
  const stored = localStorage.getItem("eiseb_transactions");
  if (!stored) {
    localStorage.setItem("eiseb_transactions", JSON.stringify(SEED_TRANSACTIONS));
    return SEED_TRANSACTIONS;
  }
  return JSON.parse(stored);
}

function saveTransactions(txns) {
  localStorage.setItem("eiseb_transactions", JSON.stringify(txns));
}

function fmt(amount) {
  return "N$ " + Number(amount).toLocaleString("en-NA", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function renderSummary(txns) {
  const income  = txns.filter(t => t.type === "Income").reduce((s, t) => s + t.amount, 0);
  const expense = txns.filter(t => t.type === "Expense").reduce((s, t) => s + t.amount, 0);
  const net = income - expense;

  document.getElementById("totalIncome").textContent  = fmt(income);
  document.getElementById("totalExpense").textContent = fmt(expense);
  document.getElementById("netBalance").textContent   = fmt(net);
  document.getElementById("livestockValue").textContent = fmt(income * 1.4); // mock valuation

  const balEl = document.getElementById("netBalance");
  balEl.style.color = net >= 0 ? "var(--success)" : "var(--danger)";
}

function renderRecentTable(txns) {
  const tbody = document.getElementById("recentBody");
  const recent = [...txns].sort((a, b) => new Date(b.date) - new Date(a.date)).slice(0, 6);
  tbody.innerHTML = recent.map(t => `
    <tr>
      <td>${t.date}</td>
      <td>${t.category}</td>
      <td><span class="badge-${t.type.toLowerCase()}">${t.type}</span></td>
      <td>${fmt(t.amount)}</td>
    </tr>
  `).join("");
}

function addTransaction() {
  const type     = document.getElementById("txType").value;
  const category = document.getElementById("txCategory").value;
  const amount   = parseFloat(document.getElementById("txAmount").value);
  const date     = document.getElementById("txDate").value;
  const desc     = document.getElementById("txDesc").value;

  if (!amount || amount <= 0 || !date) {
    document.getElementById("formMsg").style.color = "var(--danger)";
    document.getElementById("formMsg").textContent = "Please enter a valid amount and date.";
    return;
  }

  const txns = getTransactions();
  const newId = txns.length ? Math.max(...txns.map(t => t.id)) + 1 : 1;
  txns.push({ id: newId, type, category, amount, date, desc });
  saveTransactions(txns);

  document.getElementById("formMsg").style.color = "var(--success)";
  document.getElementById("formMsg").textContent = "✔ Transaction saved!";
  document.getElementById("txAmount").value = "";
  document.getElementById("txDesc").value = "";

  renderSummary(txns);
  renderRecentTable(txns);

  setTimeout(() => document.getElementById("formMsg").textContent = "", 3000);
}

function setCurrentDate() {
  const now = new Date();
  document.getElementById("currentDate").textContent =
    now.toLocaleDateString("en-NA", { weekday: "long", year: "numeric", month: "long", day: "numeric" });
  document.getElementById("txDate").value = now.toISOString().split("T")[0];
}

// Init
document.addEventListener("DOMContentLoaded", () => {
  setCurrentDate();
  const txns = getTransactions();
  renderSummary(txns);
  renderRecentTable(txns);
});
