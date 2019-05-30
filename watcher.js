if ('WebSocket' in window) {
	(() => {
		var protocol = window.location.protocol === 'http:' ? 'ws://' : 'wss://';
		var address = protocol + window.location.host + "/@WEBSOCKETPATH";
		var ws = new WebSocket(address);
		ws.onopen = () => {
			console.log("Connected to kemal-watcher");
		};
		ws.onmessage = (msg) => {
			if (msg.data == "reload") {
				window.location.reload();
			}
		};
		ws.onclose = () => {
			setTimeout(() => {
				window.location.reload();
			}, 2000);
		};
	})();
}
