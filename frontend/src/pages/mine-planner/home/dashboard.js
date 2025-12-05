import { BASE_URL } from "../../utils/config.js";
import { getAccessToken } from "../../utils/auth.js";

async function fetchJson(path) {
  const token = getAccessToken();
  const res = await fetch(`${BASE_URL}${path}`, {
    headers: token ? { Authorization: `Bearer ${token}` } : {},
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.message || `Request failed ${res.status}`);
  return data;
}

function renderBarChart(canvas, labels, values) {
  const ctx = canvas.getContext("2d");
  const w = canvas.width, h = canvas.height;
  ctx.clearRect(0, 0, w, h);
  const paddingLeft = 50;
  const paddingBottom = 30;
  const paddingTop = 20;
  const maxVal = Math.max(...values, 1);
  const yTicks = 4;
  const step = Math.ceil(maxVal / yTicks);
  const chartHeight = h - paddingBottom - paddingTop;
  const chartWidth = w - paddingLeft - 20;
  const barWidth = values.length ? chartWidth / values.length - 12 : 20;
  ctx.strokeStyle = "#e5e7eb";
  for (let t = 0; t <= yTicks; t++) {
    const y = h - paddingBottom - (t / yTicks) * chartHeight;
    ctx.beginPath();
    ctx.moveTo(paddingLeft, y);
    ctx.lineTo(w - 20, y);
    ctx.stroke();
    ctx.fillStyle = "#6b7280";
    ctx.font = "12px system-ui";
    ctx.fillText(String(t * step), 8, y + 4);
  }
  values.forEach((v, i) => {
    const x = paddingLeft + i * (barWidth + 12) + 6;
    const barHeight = Math.round((v / (yTicks * step)) * chartHeight);
    const y = h - paddingBottom - barHeight;
    ctx.fillStyle = "#4f46e5";
    ctx.fillRect(x, y, barWidth, barHeight);
    ctx.fillStyle = "#374151";
    ctx.font = "12px system-ui";
    ctx.fillText(String(labels[i]).slice(0, 6), x, h - paddingBottom + 16);
    ctx.fillStyle = "#111827";
    ctx.fillText(v, x, y - 4);
  });
}

function renderPieChart(canvas, entries, legendEl) {
  const total = entries.reduce((a, b) => a + b.value, 0) || 1;
  const ctx = canvas.getContext("2d");
  const cx = canvas.width / 2;
  const cy = canvas.height / 2;
  const r = Math.min(cx, cy) - 10;
  let start = -Math.PI / 2;
  const colors = ["#10b981", "#ef4444", "#f59e0b", "#3b82f6", "#6366f1"];
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  entries.forEach((e, i) => {
    const angle = (e.value / total) * Math.PI * 2;
    ctx.beginPath();
    ctx.moveTo(cx, cy);
    ctx.arc(cx, cy, r, start, start + angle);
    ctx.closePath();
    ctx.fillStyle = colors[i % colors.length];
    ctx.fill();
    start += angle;
  });
  if (legendEl) {
    legendEl.innerHTML = entries
      .map((e, i) => `<div class="legend-item"><span class="legend-swatch" style="background:${colors[i % colors.length]}"></span>${e.label}</div>`)
      .join("");
  }
}

async function loadWeather() {
  const card = document.getElementById("weatherCard");
  try {
    const lat = -6.2, lon = 106.8;
    const url = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,weather_code,wind_speed_10m&timezone=auto`;
    const res = await fetch(url);
    const wx = await res.json();
    const codeMap = {
      0: { t: "Cerah", e: "☀️" },
      1: { t: "Sebagian berawan", e: "🌤️" },
      2: { t: "Berawan", e: "☁️" },
      3: { t: "Mendung", e: "☁️" },
      45: { t: "Kabut", e: "🌫️" },
      48: { t: "Kabut beku", e: "🌫️" },
      51: { t: "Gerimis ringan", e: "🌦️" },
      53: { t: "Gerimis", e: "🌦️" },
      55: { t: "Gerimis deras", e: "🌧️" },
      61: { t: "Hujan ringan", e: "🌧️" },
      63: { t: "Hujan", e: "🌧️" },
      65: { t: "Hujan deras", e: "⛈️" },
      71: { t: "Salju ringan", e: "❄️" },
      73: { t: "Salju", e: "❄️" },
      75: { t: "Salju deras", e: "❄️" },
      80: { t: "Hujan lokal", e: "🌧️" },
      81: { t: "Hujan menyebar", e: "🌧️" },
      82: { t: "Hujan badai", e: "⛈️" },
      95: { t: "Badai guntur", e: "⛈️" },
    };
    const cur = wx.current || {};
    const meta = codeMap[cur.weather_code];
    const label = meta?.t || "Cuaca";
    const emoji = meta?.e || "🌤️";
    document.getElementById("weatherSummary").textContent = `${emoji} ${label} • ${cur.temperature_2m ?? "-"}°C`;
    document.getElementById("weatherMeta").textContent = `Angin: ${cur.wind_speed_10m ?? "-"} m/s • Zona: ${wx.timezone}`;
  } catch (e) {
    card.textContent = "Gagal memuat cuaca";
  }
}

async function initDashboard() {
  try {
    const blending = await fetchJson("/blending-plans");
    const plans = Array.isArray(blending.data) ? blending.data : [];
    const weeks = plans.map(p => p.plan_week);
    const tonnages = plans.map(p => Number(p.target_tonnage_weekly || 0));
    renderBarChart(document.getElementById("tonnageChart"), weeks.slice(-6), tonnages.slice(-6));
  } catch {}

  try {
    const eq = await fetchJson("/equipments");
    const list = Array.isArray(eq.data) ? eq.data : [];
    const available = list.filter(e => Number(e.is_available) === 1).length;
    const unavailable = list.length - available;
    renderPieChart(document.getElementById("availabilityChart"), [
      { label: "Ready", value: available },
      { label: "Down", value: unavailable },
    ], document.getElementById("availabilityLegend"));
  } catch {}

  try {
    const crews = await fetchJson("/crews");
    const data = Array.isArray(crews.data) ? crews.data : [];
    const hadir = data.filter(c => String(c.presence) === "Hadir").length;
    const absen = data.filter(c => String(c.presence) === "Absen").length;
    const sakit = data.filter(c => String(c.presence) === "Sakit").length;
    const cuti = data.filter(c => String(c.presence) === "Cuti").length;
    const el = document.getElementById("crewStats");
    if (el) {
      el.innerHTML = [
        { label: "Hadir", value: hadir },
        { label: "Absen", value: absen },
        { label: "Sakit", value: sakit },
        { label: "Cuti", value: cuti },
      ].map(s => `<div class="stat-chip" role="listitem"><span class="value">${s.value}</span><span class="label">${s.label}</span></div>`).join("");
    }
  } catch {}

  try {
    const blending = await fetchJson("/blending-plans");
    const plans = Array.isArray(blending.data) ? blending.data : [];
    const last = plans.slice(-6).reverse();
    const tbody = document.querySelector("#weeklyPlanTable tbody");
    if (tbody) {
      tbody.innerHTML = last.map(p => `
        <tr>
          <td>${p.plan_week}</td>
          <td>${p.plan_year}</td>
          <td>${p.target_tonnage_weekly}</td>
          <td>${p.target_calori}</td>
          <td>${p.target_ash_max}</td>
          <td><span class="badge ${Number(p.is_approved_mine)===1?'ok':'pending'}">${Number(p.is_approved_mine)===1?'Approved':'Pending'}</span></td>
          <td><span class="badge ${Number(p.is_approved_shipping)===1?'ok':'pending'}">${Number(p.is_approved_shipping)===1?'Approved':'Pending'}</span></td>
        </tr>
      `).join("");
    }
  } catch {}

  loadWeather();
}

document.addEventListener("DOMContentLoaded", initDashboard);
