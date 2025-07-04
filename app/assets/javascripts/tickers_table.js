// JavaScript for advanced stock tickers table (sorting, tooltips, etc.)
// This file should be included in the asset pipeline or imported in your layout.

function sortTable(header, tableId, colIndex, sortType = 'value') {
  var table = header.closest('table');
  var tbody = table.tBodies[0];
  var rows = Array.from(tbody.rows);
  var asc = header.asc = !header.asc;

  rows.sort(function(a, b) {
    function extractValue(element, type) {
      var cell = element.cells[colIndex];
      var text = cell.innerText.replace(/,/g, '');
      if (colIndex === 1) { // Group column: always string sort
        return text.trim();
      }
      if (type === 'percent') {
        var percentDiv = cell.querySelector('div');
        if (percentDiv) {
          var percentMatch = percentDiv.innerText.match(/\(([-\d.]+)/);
          return percentMatch ? parseFloat(percentMatch[1]) : 0;
        }
        var percentInText = text.match(/\(([-\d.]+)/);
        return percentInText ? parseFloat(percentInText[1]) : 0;
      } else if (type === 'abs_billion') {
        var sellDiv = cell.querySelector('div:last-child');
        var valueText = sellDiv ? sellDiv.innerText : text;
        var hasB = valueText.includes('B');
        var numberMatch = valueText.match(/-?[\d.]+/);
        if (!numberMatch) return 0;
        var value = parseFloat(numberMatch[0]);
        value = Math.abs(value);
        return hasB ? value * 1e9 : value;
      } else if (type === 'billion') {
        var buyDiv = cell.querySelector('div:first-child');
        var valueText = buyDiv ? buyDiv.innerText : text;
        var hasB = valueText.includes('B');
        var numberMatch = valueText.match(/-?[\d.]+/);
        if (!numberMatch) return 0;
        var value = parseFloat(numberMatch[0]);
        return hasB ? value * 1e9 : value;
      } else if (type === 'value') {
        // Remove commas and extract the first number with optional B suffix before any parenthesis or percent
        var valueText = text.replace(/,/g, '').split('(')[0].trim();
        var match = valueText.match(/(-?[\d.]+)\s*(B)?$/i);
        if (!match) return 0;
        var value = parseFloat(match[1]);
        var hasB = !!match[2];
        return hasB ? value * 1e9 : value * 1;
      } else if (type === 'foreign_own_sub') {
        // Extract the sub-percentage from the second line in the cell (in parentheses, as percentage)
        var divs = cell.querySelectorAll('div');
        if (divs.length > 1) {
          var match = divs[1].innerText.match(/([\-\d.]+)%/);
          if (match) return parseFloat(match[1]);
        } else if (divs.length > 0) {
          var match = divs[0].innerText.match(/([\-\d.]+)%/);
          if (match) return parseFloat(match[1]);
        }
        // fallback: try to find any percentage in the cell
        var match = text.match(/([\-\d.]+)%/);
        return match ? parseFloat(match[1]) : 0;
      } else {
        var valueText = text.split('(')[0].trim();
        var hasB = valueText.includes('B');
        var numberMatch = valueText.match(/-?[\d.]+/);
        if (!numberMatch) return 0;
        var value = parseFloat(numberMatch[0]);
        return hasB ? value * 1e9 : value;
      }
    }
    var aVal = extractValue(a, sortType);
    var bVal = extractValue(b, sortType);
    if (colIndex === 1) {
      return asc ? aVal.localeCompare(bVal) : bVal.localeCompare(aVal);
    }
    if (!isNaN(aVal) && !isNaN(bVal)) {
      if (sortType === 'abs_billion') {
        return asc ? aVal - bVal : bVal - aVal;
      }
      return asc ? aVal - bVal : bVal - aVal;
    } else {
      var aText = a.cells[colIndex].innerText;
      var bText = b.cells[colIndex].innerText;
      return asc ? aText.localeCompare(bText) : bText.localeCompare(aText);
    }
  });
  rows.forEach(function(row) { tbody.appendChild(row); });
  var headerDiv = sortType === 'percent' ? header.querySelector('div:last-child') : header;
  if (headerDiv) {
    table.querySelectorAll('th div').forEach(div => {
      div.classList.remove('sorted', 'asc');
    });
    headerDiv.classList.add('sorted');
    headerDiv.classList.toggle('asc', asc);
  }
}

window.sortTable = sortTable;

document.addEventListener('DOMContentLoaded', function() {
  document.querySelectorAll('.symbol-tooltip-trigger').forEach(function(el) {
    el.addEventListener('mouseenter', function() {
      var tooltip = el.nextElementSibling;
      if (tooltip) {
        tooltip.style.display = 'block';
        tooltip.style.left = '';
        tooltip.style.right = '';
        tooltip.style.top = '';
        tooltip.style.bottom = '';
        setTimeout(function() {
          var rect = tooltip.getBoundingClientRect();
          var parentRect = el.parentElement.getBoundingClientRect();
          var winHeight = window.innerHeight || document.documentElement.clientHeight;
          var winWidth = window.innerWidth || document.documentElement.clientWidth;
          var tableContainer = el.closest('.table-responsive');
          var containerRect = tableContainer.getBoundingClientRect();
          var row = el.closest('tr');
          var table = row.closest('table');
          var rows = Array.from(table.querySelectorAll('tbody tr'));
          var visibleRows = rows.filter(function(r) {
            var rowRect = r.getBoundingClientRect();
            return rowRect.top < containerRect.bottom && rowRect.bottom > containerRect.top;
          });
          var rowIndex = visibleRows.indexOf(row);
          var isLastThreeRows = rowIndex >= visibleRows.length - 3;
          if (rect.right > winWidth) {
            tooltip.style.left = 'auto';
            tooltip.style.right = '100%';
          } else {
            tooltip.style.left = '100%';
            tooltip.style.right = 'auto';
          }
          if (isLastThreeRows) {
            tooltip.style.top = 'auto';
            tooltip.style.bottom = '100%';
            var tooltipRect = tooltip.getBoundingClientRect();
            if (tooltipRect.top < containerRect.top) {
              tooltip.style.bottom = 'auto';
              tooltip.style.top = '-50%';
            }
          } else {
            tooltip.style.top = '0';
            tooltip.style.bottom = 'auto';
            var tooltipRect = tooltip.getBoundingClientRect();
            if (tooltipRect.bottom > containerRect.bottom) {
              tooltip.style.top = 'auto';
              tooltip.style.bottom = '0';
            }
          }
          var updatedRect = tooltip.getBoundingClientRect();
          if (updatedRect.bottom > containerRect.bottom) {
            var adjustment = updatedRect.bottom - containerRect.bottom + 10;
            tooltip.style.top = (tooltip.offsetTop - adjustment) + 'px';
          }
          if (updatedRect.top < containerRect.top) {
            tooltip.style.top = (containerRect.top - parentRect.top + 5) + 'px';
          }
        }, 0);
      }
    });
    el.addEventListener('mouseleave', function() {
      var tooltip = el.nextElementSibling;
      if (tooltip) { tooltip.style.display = 'none'; }
    });
    el.parentElement.addEventListener('mouseleave', function() {
      var tooltip = el.nextElementSibling;
      if (tooltip) { tooltip.style.display = 'none'; }
    });
  });
});
