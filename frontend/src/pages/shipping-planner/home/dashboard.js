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

function renderBarChart(canvas, labels, values, color = "#4f46e5") {
  const ctx = canvas.getContext("2d");
  const w = canvas.width,
    h = canvas.height;
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
    ctx.fillStyle = color;
    ctx.fillRect(x, y, barWidth, barHeight);
    ctx.fillStyle = "#374151";
    ctx.font = "12px system-ui";
    ctx.fillText(String(labels[i]).slice(0, 6), x, h - paddingBottom + 16);
    ctx.fillStyle = "#111827";
    ctx.fillText(v, x, y - 4);
  });
}

function renderDualBarChart(canvas, labels, targetValues, actualValues) {
  const ctx = canvas.getContext("2d");
  const w = canvas.width,
    h = canvas.height;
  ctx.clearRect(0, 0, w, h);
  const paddingLeft = 50,
    paddingBottom = 30,
    paddingTop = 20;
  const maxVal = Math.max(...targetValues, ...actualValues, 1);
  const yTicks = 4,
    step = Math.ceil(maxVal / yTicks);
  const chartHeight = h - paddingBottom - paddingTop;
  const chartWidth = w - paddingLeft - 20;
  const groupWidth = labels.length ? chartWidth / labels.length - 12 : 20;
  const barWidth = Math.max(6, Math.floor(groupWidth / 2) - 2);
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
  labels.forEach((lab, i) => {
    const xBase = paddingLeft + i * (groupWidth + 12) + 6;
    const tVal = targetValues[i] || 0;
    const aVal = actualValues[i] || 0;
    const tH = Math.round((tVal / (yTicks * step)) * chartHeight);
    const aH = Math.round((aVal / (yTicks * step)) * chartHeight);
    const yT = h - paddingBottom - tH;
    const yA = h - paddingBottom - aH;
    ctx.fillStyle = "#4f46e5";
    ctx.fillRect(xBase, yT, barWidth, tH);
    ctx.fillStyle = "#10b981";
    ctx.fillRect(xBase + barWidth + 4, yA, barWidth, aH);
    ctx.fillStyle = "#374151";
    ctx.font = "12px system-ui";
    ctx.fillText(String(lab).slice(0, 8), xBase, h - paddingBottom + 16);
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
      .map(
        (e, i) =>
          `<div class="legend-item"><span class="legend-swatch" style="background:${
            colors[i % colors.length]
          }"></span>${e.label}</div>`
      )
      .join("");
  }
}

function renderGantt(container, items) {
  const minDate = items.reduce(
    (min, i) => Math.min(min, new Date(i.eta_date).getTime()),
    Infinity
  );
  const maxDate = items.reduce(
    (max, i) =>
      Math.max(max, new Date(i.latest_berthing || i.eta_date).getTime()),
    -Infinity
  );
  const range = Math.max(1, maxDate - minDate);
  container.innerHTML = items
    .map((i) => {
      const start = new Date(i.eta_date).getTime();
      const end = new Date(i.latest_berthing || i.eta_date).getTime();
      const leftPct = ((start - minDate) / range) * 100;
      const widthPct = Math.max(2, ((end - start) / range) * 100);
      const tone = widthPct < 10 ? "#fde68a" : "#4f46e5";
      return `<div class="d-flex align-items-center gap-2 mb-2">
      <div class="text-muted" style="width:180px">${i.vessel_name}</div>
      <div class="flex-grow-1" style="position:relative;height:24px;background:#f9fafb;border:1px solid #e5e7eb;border-radius:6px">
        <div style="position:absolute;left:${leftPct}%;width:${widthPct}%;height:100%;background:${tone};border-radius:6px"></div>
      </div>
      <div class="text-muted" style="width:160px">ETA: ${i.eta_date}</div>
      <div class="text-muted" style="width:160px">ETB: ${
        i.latest_berthing || "-"
      }</div>
    </div>`;
    })
    .join("");
}

async function loadWeatherCards() {
  try {
    const wx = await fetchJson("/shipping-dashboard/weather");
    const d = wx.data || {};
    document.getElementById("wxRainfall").textContent = d.rainfall_mm ?? 0;
    document.getElementById("wxWave").textContent = d.max_wave_m ?? 0;
    const port = d.port_status ?? "-";
    document.getElementById("wxPort").textContent = port;
    document.getElementById("wxHours").textContent =
      d.effective_working_hours ?? 0;
  } catch {}
}

async function initDashboard() {
  try {
    const kpi = await fetchJson("/shipping-dashboard/kpi");
    const d = kpi.data || {};
    document.getElementById("kpiUpcomingVessel").textContent =
      d.upcomingVessel ?? 0;
    document.getElementById("kpiWeeklyTarget").textContent = (
      d.weeklyTarget ?? 0
    ).toLocaleString("id-ID");
    document.getElementById("kpiPortStatus").textContent = d.portStatus ?? "-";
    document.getElementById("kpiWaveHeight").textContent = `${
      d.waveHeight ?? 0
    } m`;
  } catch {}

  try {
    const sch = await fetchJson("/shipping-dashboard/schedule");
    renderGantt(document.getElementById("ganttContainer"), sch.data || []);
  } catch {}

  try {
    const ta = await fetchJson("/shipping-dashboard/target-vs-actual");
    const rows = ta.data || [];
    const labels = rows.map((r) => r.vessel_name);
    const target = rows.map((r) => Number(r.target_load_tons || 0));
    const actual = rows.map((r) => Number(r.actual_tonnage || 0));
    const canvas = document.getElementById("targetActualChart");
    renderDualBarChart(canvas, labels, target, actual);
  } catch {}

  await loadWeatherCards();

  try {
    let week = null,
      year = null;
    const renderBlending = async () => {
      const url = `/shipping-dashboard/blending-plans${
        week && year ? `?week=${week}&year=${year}` : ""
      }`;
      const res = await fetchJson(url);
      const rows = res.data || [];
      const tbody = document.querySelector("#shippingBlendingTable tbody");
      if (tbody)
        tbody.innerHTML = rows
          .map(
            (p) => `
        <tr>
          <td>${p.plan_week}</td>
          <td>${p.plan_year}</td>
          <td>${p.target_tonnage_weekly}</td>
          <td>${p.target_calori}</td>
          <td>${p.initial_ash_draft}</td>
          <td>${p.final_ash_result ?? "-"}</td>
          <td><span class="badge ${
            Number(p.is_approved_mine) === 1 ? "ok" : "pending"
          }">${
              Number(p.is_approved_mine) === 1 ? "Approved" : "Pending"
            }</span></td>
          <td><span class="badge ${
            Number(p.is_approved_shipping) === 1 ? "ok" : "pending"
          }">${
              Number(p.is_approved_shipping) === 1 ? "Approved" : "Pending"
            }</span></td>
        </tr>`
          )
          .join("");
    };
    document.getElementById("applyFilter").addEventListener("click", () => {
      week = Number(document.getElementById("filterWeek").value) || null;
      year = Number(document.getElementById("filterYear").value) || null;
      renderBlending();
    });
    await renderBlending();
  } catch {}

  try {
    const logs = await fetchJson("/shipping-dashboard/optimization-logs");
    const rows = logs.data || [];
    const acc = document.getElementById("optimizationAccordion");
    if (acc)
      acc.innerHTML = rows
        .map((r, idx) => {
          const id = `opt${idx}`;
          const step = r.current_step || "-";
          const note = r.rejection_note ?? "-";
          return `<div class="accordion-item">
        <h2 class="accordion-header" id="h${id}">
          <button class="accordion-button ${
            note !== "-" ? "text-danger" : ""
          }" type="button" data-bs-toggle="collapse" data-bs-target="#c${id}" aria-expanded="false" aria-controls="c${id}">
            ${r.plan_id} • v${r.version} • ${step} • ${r.created_at}
          </button>
        </h2>
        <div id="c${id}" class="accordion-collapse collapse" aria-labelledby="h${id}">
          <div class="accordion-body">
            <div><strong>Step:</strong> ${step}</div>
            <div class="mt-2"><strong>Rejection Note:</strong> ${note}</div>
          </div>
        </div>
      </div>`;
        })
        .join("");
  } catch {}
}

document.addEventListener("DOMContentLoaded", initDashboard);
