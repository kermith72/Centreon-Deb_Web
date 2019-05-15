if (refresh_interval && refresh_interval != "" && refresh_interval != "0") {
    window.setInterval("reloadChart()", refresh_interval * 1000);
}

function reloadChart() {
    window.location.reload(true);
}
