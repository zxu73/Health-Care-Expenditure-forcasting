// ForecastChart — Chart.js hook for Phoenix LiveView
// Renders historical actuals + Holt-Winters forecast with 95% CI band.

let chartInstance = null;

function buildLabels(data) {
  const hist = data.historical_years || [];
  const fore = data.forecast_years   || [];
  return [...hist, ...fore];
}

function buildDatasets(data) {
  const hist      = data.historical  || [];
  const fore      = data.forecast    || [];
  const ciLower   = data.ci_lower    || [];
  const ciUpper   = data.ci_upper    || [];
  const histLen   = (data.historical_years || []).length;
  const foreLen   = (data.forecast_years   || []).length;

  // Pad arrays to align on the combined labels axis
  const histPadded  = [...hist,    ...Array(foreLen).fill(null)];
  const forePadded  = [...Array(histLen).fill(null), ...fore];
  const upperPadded = [...Array(histLen).fill(null), ...ciUpper];
  const lowerPadded = [...Array(histLen).fill(null), ...ciLower];

  return [
    // CI Upper (invisible boundary; fill '-1' will shade down to CI Lower)
    {
      label: "CI Upper",
      data: upperPadded,
      borderColor: "transparent",
      backgroundColor: "rgba(251,146,60,0.15)",
      pointRadius: 0,
      fill: "+1",        // fill toward the next dataset (CI Lower)
      tension: 0.3,
      hidden: false,
    },
    // CI Lower (invisible boundary)
    {
      label: "CI Lower",
      data: lowerPadded,
      borderColor: "transparent",
      backgroundColor: "rgba(251,146,60,0.15)",
      pointRadius: 0,
      fill: false,
      tension: 0.3,
    },
    // Historical actuals — solid blue
    {
      label: "Historical (actual)",
      data: histPadded,
      borderColor: "#3b82f6",
      backgroundColor: "#3b82f6",
      borderWidth: 2.5,
      pointRadius: 4,
      pointHoverRadius: 6,
      fill: false,
      tension: 0.2,
      spanGaps: false,
    },
    // Forecast — dashed orange
    {
      label: "Forecast (Holt-Winters)",
      data: forePadded,
      borderColor: "#f97316",
      backgroundColor: "#f97316",
      borderWidth: 2.5,
      borderDash: [6, 4],
      pointRadius: 4,
      pointHoverRadius: 6,
      fill: false,
      tension: 0.2,
      spanGaps: false,
    },
  ];
}

function buildConfig(data) {
  const labels   = buildLabels(data);
  const datasets = buildDatasets(data);
  const histLen  = (data.historical_years || []).length;

  return {
    type: "line",
    data: { labels, datasets },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      interaction: { mode: "index", intersect: false },
      plugins: {
        legend: {
          labels: {
            filter: (item) => !["CI Upper", "CI Lower"].includes(item.text),
            boxWidth: 24,
            font: { size: 12 },
          },
        },
        tooltip: {
          callbacks: {
            label: (ctx) => {
              if (["CI Upper", "CI Lower"].includes(ctx.dataset.label)) return null;
              const v = ctx.parsed.y;
              return v != null ? `${ctx.dataset.label}: $${v.toFixed(2)}B` : null;
            },
          },
        },
        annotation: {
          annotations: {
            divider: {
              type: "line",
              xMin: histLen - 0.5,
              xMax: histLen - 0.5,
              borderColor: "#9ca3af",
              borderWidth: 1.5,
              borderDash: [6, 4],
              label: {
                display: true,
                content: "Forecast →",
                position: "start",
                color: "#9ca3af",
                font: { size: 11 },
              },
            },
          },
        },
      },
      scales: {
        x: {
          grid: { color: "#f3f4f6" },
          ticks: { font: { size: 11 }, maxRotation: 45 },
        },
        y: {
          grid: { color: "#f3f4f6" },
          ticks: {
            font: { size: 11 },
            callback: (v) => `$${v.toFixed(0)}B`,
          },
          title: { display: true, text: "Expenditures ($Billions)", font: { size: 11 } },
        },
      },
    },
  };
}

const ForecastChart = {
  mounted() {
    const data = JSON.parse(this.el.dataset.chart || "{}");
    chartInstance = new Chart(this.el, buildConfig(data));

    this.handleEvent("update_chart", (newData) => {
      if (chartInstance) {
        chartInstance.destroy();
      }
      chartInstance = new Chart(this.el, buildConfig(newData));
    });
  },

  destroyed() {
    if (chartInstance) {
      chartInstance.destroy();
      chartInstance = null;
    }
  },
};

export default ForecastChart;
