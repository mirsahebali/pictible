<script module lang="ts">
	function sendMessage(socket: WebSocket, username: string, message: string) {
		safeSocketSend(socket, { event: EventTypes.PlayerSentChat, data: { username, message } });
	}
</script>

<script lang="ts">
	import DrawingCanvas from '$lib/components/drawing-canvas.svelte';
	import ViewCanvas from '$lib/components/view-canvas.svelte';
	import * as Card from '$lib/components/ui/card';
	import * as InputGroup from '$lib/components/ui/input-group';
	import ScrollArea from '$lib/components/ui/scroll-area/scroll-area.svelte';
	import { Separator } from '$lib/components/ui/separator';
	import { Switch } from '$lib/components/ui/switch';
	import { Label } from '$lib/components/ui/label';
	import { AspectRatio } from '$lib/components/ui/aspect-ratio';
	import { fakeChats, fakePlayers } from '$lib/utils';
	import { SendHorizontal } from '@lucide/svelte';
	import { Button } from '$lib/components/ui/button';
	import { onMount } from 'svelte';
	import { toWS } from '$lib/utils';
	import { EventTypes, CanvasModes } from '$lib/events';
	import { safeSocketSend } from '$lib/socket';
	import { normalizePos } from '$lib/draw';
	import { toast } from 'svelte-sonner';
	import { getRoomData } from '$lib/requests';
	import { drawData } from '$lib/draw.svelte';
	import { goto, refreshAll } from '$app/navigation';
	import Players from '$lib/components/players.svelte';
	import * as ButtonGroup from '$lib/components/ui/button-group';
	import { Clipboard } from '@lucide/svelte';

	let { data } = $props();

	let players = $state(data?.roomData?.players || []);

	let chats = $state(data?.roomChatData || []);
	let isPlayerActive = $state(false);

	let roomCode = $state(data.room_code);
	let message = $state('');

	let currentUsername = $state('');

	let socket = $state<WebSocket | null>(null);

	onMount(() => {
		if (data.error) {
			toast.error('Invalid request');
			localStorage.removeItem('pictible-username');
			localStorage.removeItem('pictible-room_code');
			window.location.href = '/';
			return;
		}
		players = data.roomData.players;
		currentUsername = localStorage.getItem('pictible-username');
		isPlayerActive = players.find((p) => p.username === currentUsername).active;

		$inspect(players);
		if (!socket) socket = new WebSocket(toWS('/room-ws/' + data.room_code + '/' + currentUsername));

		socket.addEventListener('open', async () => {
			await socket.send(
				JSON.stringify({ event: EventTypes.PlayerJoined, data: { username: currentUsername } })
			);
		});

		socket.addEventListener('message', async (message) => {
			const { event, data: eventData }: { event: EventTypes; data: EventData } = JSON.parse(
				message.data
			);

			switch (event) {
				case EventTypes.PlayerJoined:
					toast.info('Player Joined: ' + eventData.username);
					data.roomData = await getRoomData(roomCode);
					if (data.roomData) players = data.roomData.players;
					break;
				case EventTypes.PlayerLeft:
					toast.info('Player Left' + eventData);
					data.roomData = await getRoomData(roomCode);
					if (data.roomData) players = data.roomData.players;
					break;
				case EventTypes.PlayerInvited:
					break;

				case EventTypes.PlayerCurrentSelection:
					break;
				case EventTypes.PlayerDrawing:
					{
						if (isPlayerActive) {
							break;
						}
						const [recvX, recvY, recvHex, recvStrokeWidth] = eventData;
						drawData.x = recvX;
						drawData.y = recvY;
						drawData.hex = recvHex;
						drawData.drawStrokeWidth = recvStrokeWidth;
						drawData.canvasMode = 'draw';
					}

					break;
				case EventTypes.PlayerErasing:
					{
						if (isPlayerActive) {
							break;
						}
						const [recvX, recvY, recvStrokeWidth] = eventData;
						drawData.x = recvX;
						drawData.y = recvY;
						drawData.eraseStrokeWidth = recvStrokeWidth;
						drawData.canvasMode = 'erase';
					}
					break;
				case EventTypes.PlayerCleared:
					break;

				case EventTypes.PlayerIdle:
					drawData.canvasMode = 'idle';
					break;
				case EventTypes.PlayerSentChat:
					{
						const { username, message } = eventData;

						chats.push({
							id: parseInt(Math.random() * 100),
							message,
							sent_at: new Date(),
							username: username
						});
					}
					break;

				case EventTypes.NilEvent:
					break;

				default:
					console.warn('Invalid Event');
					break;
			}
		});
	});

	$effect(() => {
		switch (drawData.canvasMode) {
			case CanvasModes.Drawing:
				{
					const [nX, nY] = normalizePos(
						[drawData.x, drawData.y],
						[drawData.canvasWidth, drawData.canvasHeight]
					);
					safeSocketSend(socket, {
						event: EventTypes.PlayerDrawing,
						data: [nX, nY, drawData.hex, drawData.drawStrokeWidth]
					});
				}
				break;
			case CanvasModes.Erasing:
				{
					const [nX, nY] = normalizePos(
						[drawData.x, drawData.y],
						[drawData.canvasWidth, drawData.canvasHeight]
					);
					safeSocketSend(socket, {
						event: EventTypes.PlayerErasing,
						data: [nX, nY, drawData.eraseStrokeWidth]
					});
				}
				break;
			case CanvasModes.Cleared:
				break;
			case CanvasModes.Idle:
				safeSocketSend(socket, {
					event: EventTypes.PlayerIdle,
					data: null
				});
				break;
		}
	});

	function sendMessageHandler() {
		sendMessage(socket, currentUsername, message);
		chats.push({
			id: parseInt(Math.random() * 100),
			message,
			sent_at: new Date(),
			username: currentUsername
		});
		message = '';
		console.log('sent');
	}
</script>

<div
	class="flex w-full flex-col flex-wrap items-center justify-center gap-2 sm:flex-row md:items-center"
	id="main-container"
>
	<div>
		<div id="players">
			<Card.Root>
				<Card.Content>
					<Players list={players} />
				</Card.Content>
				<Card.Footer>
					<ButtonGroup.Root
						onclick={async () => {
							toast.info('copied invite link');
							await navigator.clipboard.writeText(
								`${window.location.protocol}//${window.location.host}/invite/${data.room_code}`
							);
						}}
					>
						<Button variant="outline" size="sm"
							>{`${window.location.protocol}//${window.location.host}/invite/${data.room_code}`}</Button
						>
						<Button variant="outline" size="sm"><Clipboard /></Button>
					</ButtonGroup.Root>
				</Card.Footer>
			</Card.Root>
		</div>

		<div id="chat">
			<Card.Root>
				<Card.Content>
					<ScrollArea class="h-[20vh] sm:h-[30vh]">
						<ul>
							{#each chats as chat, index (index)}
								<li class="my-1">
									<span class="text-xs">{chat.username}: </span>
									<span>{chat.message}</span>
								</li>
								<Separator />
							{/each}
						</ul>
					</ScrollArea>
				</Card.Content>

				<Card.Footer>
					<InputGroup.Root>
						<InputGroup.Input
							placeholder="type your guess"
							bind:value={message}
							onkeydown={(e) => {
								if (event.key === 'Enter') sendMessageHandler();
							}}
						/>
						<InputGroup.Addon align="inline-end">
							<InputGroup.Button
								variant="secondary"
								onclick={() => {
									sendMessage(socket, currentUsername, message);
									chats.push({
										id: parseInt(Math.random() * 100),
										message,
										sent_at: new Date(),
										username: currentUsername
									});
									message = '';
									console.log('sent');
								}}><SendHorizontal /></InputGroup.Button
							>
						</InputGroup.Addon>
					</InputGroup.Root>
				</Card.Footer>
			</Card.Root>
		</div>
	</div>
	<div id="canvas">
		{#if players.length <= 1}
			<div class="">Waiting for other players to join....</div>
		{/if}
		{#if isPlayerActive && players.length > 1}
			<DrawingCanvas />
		{:else}
			<ViewCanvas />
		{/if}
	</div>
</div>
