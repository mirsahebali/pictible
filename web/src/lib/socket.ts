export const safeSocketSend = (socket: WebSocket, data: object) => {
	if (socket.readyState !== 1) return;
	socket.send(JSON.stringify(data));
};
