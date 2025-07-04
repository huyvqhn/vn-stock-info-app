import { Controller } from "@hotwired/stimulus";

// Usage: Add data-controller="sortable-table" to your <table> or container
// Add data-action="click->sortable-table#sort" to <th> or <div> in header
// Add data-sort-column and data-sort-type (optional: value/percent) to header elements

export default class extends Controller {
  static targets = ["tbody"];

  connect() {
    console.log("[sortable-table] Stimulus controller connected");
  }

  sort(event) {
    let header = event.currentTarget;
    let th = header.closest("th");
    if (!th) {
      console.warn("[sortable-table] Could not find <th> for clicked header", header);
      return;
    }
    let table = th.closest("table");
    if (!table) {
      console.warn("[sortable-table] Could not find <table> for header", th);
      return;
    }
    let tbody = table.tBodies[0];
    if (!tbody) {
      console.warn("[sortable-table] Could not find <tbody> in table", table);
      return;
    }
    let colIndex = parseInt(header.dataset.sortColumn, 10);
    if (isNaN(colIndex)) {
      console.warn("[sortable-table] Invalid or missing data-sort-column", header);
      return;
    }
    let sortType = header.dataset.sortType || "value";
    let asc = header.classList.toggle("asc");
    header.classList.add("sorted");
    // Remove sorted/asc from all other sort headers in this row
    th.parentNode.querySelectorAll('[data-action~="sortable-table#sort"]').forEach(el => {
      if (el !== header) {
        el.classList.remove("sorted", "asc");
      }
    });

    let rows = Array.from(tbody.rows);
    if (rows.length === 0) {
      console.warn("[sortable-table] No rows found in tbody", tbody);
      return;
    }
    console.log(`[sortable-table] Sorting column ${colIndex} (${sortType}), asc: ${asc}`);
    rows.sort((a, b) => {
      function extractValue(row, type) {
        let cell = row.cells[colIndex];
        if (!cell) return 0;
        let text = cell.innerText.replace(/,/g, "");
        if (type === "percent") {
          let percentDiv = cell.querySelector("div");
          if (percentDiv) {
            let percentMatch = percentDiv.innerText.match(/\(([-\d.]+)/);
            return percentMatch ? parseFloat(percentMatch[1]) : 0;
          }
          let percentInText = text.match(/\(([-\d.]+)/);
          return percentInText ? parseFloat(percentInText[1]) : 0;
        } else {
          // For value sorting, handle B (billions) suffix
          let valueText = text.split('(')[0].trim();
          let hasB = valueText.includes('B');
          let numberMatch = valueText.match(/-?[\d.]+/);
          if (!numberMatch) return 0;
          let value = parseFloat(numberMatch[0]);
          return hasB ? value * 1e9 : value;
        }
      }
      let aVal = extractValue(a, sortType);
      let bVal = extractValue(b, sortType);
      if (!isNaN(aVal) && !isNaN(bVal)) {
        return asc ? aVal - bVal : bVal - aVal;
      } else {
        let aText = a.cells[colIndex] ? a.cells[colIndex].innerText : "";
        let bText = b.cells[colIndex] ? b.cells[colIndex].innerText : "";
        return asc ? aText.localeCompare(bText) : bText.localeCompare(aText);
      }
    });
    rows.forEach(row => tbody.appendChild(row));
    console.log(`[sortable-table] Table sorted by column ${colIndex}`);
  }
}
