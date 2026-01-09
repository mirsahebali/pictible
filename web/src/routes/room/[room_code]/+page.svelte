<script lang="ts">
	import DrawingCanvas from '$lib/components/drawing-canvas.svelte';
	import ViewCanvas from '$lib/components/view-canvas.svelte';
	import * as Card from '$lib/components/ui/card';
	import * as InputGroup from '$lib/components/ui/input-group';
	import ScrollArea from '$lib/components/ui/scroll-area/scroll-area.svelte';
	import { Separator } from '$lib/components/ui/separator';
	import { Switch } from '$lib/components/ui/switch';
	import { Label } from '$lib/components/ui/label';
	import { fakeChats, fakePlayers } from '$lib/utils';
	import { SendHorizontal } from '@lucide/svelte';
	import { Button } from '$lib/components/ui/button';
	import { onMount, onDestroy } from 'svelte';
	import { toWS } from '$lib/utils';
	import { EventTypes, CanvasModes } from '$lib/events';
	import { safeSocketSend } from '$lib/socket';
	import { normalizePos } from '$lib/draw';
	import { toast } from 'svelte-sonner';
	import { getRoomData } from '$lib/requests';
	import { drawData } from '$lib/draw.svelte';

	let { data } = $props();

	let players = $state(data?.roomData?.players || []);

	// TODO: add real chats
	let chats = $state(fakeChats(40));
	// TODO: add real current player eval
	let isPlayerActive = $state(true);

	let roomCode = $state(data.room_code);

	let currentUsername = $state('');

	let socket = $state<WebSocket | null>(null);

	onMount(() => {
		if (data.error) {
			toast.error('Invalid request');
			return;
		}
		players = data.roomData.players;
		currentUsername = localStorage.getItem('pictible-username');
		isPlayerActive = players.find((p) => p.username === currentUsername).active;

		console.log(players);
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
				case EventTypes.PlayerWordSelection:
					break;

				case EventTypes.PlayerGuessed:
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

	onDestroy(() => {
		if (!socket) return;
		socket.close(1000, 'abc123');
	});
</script>

<div class="gap-2 not-lg:flex-col md:flex" id="main-container">
	<div id="players">
		<Card.Root>
			<Card.Content>
				<ScrollArea class="h-[20vh] lg:h-[40vh]">
					<ul>
						<li class="flex justify-between rounded-xl border px-3">
							<span> Me:</span> <span> {currentUsername}</span>
						</li>
						{#each players as player, index (index)}
							<li class={'my-1 ' + player.active ? 'scale-110 underline' : ''}>
								{player.username}
							</li>

							<Separator />
						{/each}
					</ul>
				</ScrollArea>
			</Card.Content>
		</Card.Root>
	</div>
	<div id="canvas">
		<div class={players.length <= 1 ? 'relative cursor-not-allowed border opacity-75' : ''}>
			{#if players.length <= 1}
				<div class="absolute h-full w-full border border-white bg-primary-foreground">
					<div class="pointer-events-none z-10 flex h-full w-full items-center justify-center">
						Waiting for other players to join....
					</div>
				</div>
			{/if}
			{#if isPlayerActive}
				<DrawingCanvas />
			{:else}
				<ViewCanvas />
			{/if}
		</div>
	</div>
	<div id="chat">
		<Card.Root>
			<Card.Header class="text-xl font-bold ">
				<div>Guesses</div>
			</Card.Header>
			<Card.Content>
				<ScrollArea class="h-[24vh] lg:h-[40vh]">
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
					<InputGroup.Input placeholder="type your guess" />
					<InputGroup.Addon align="inline-end">
						<InputGroup.Button variant="secondary"><SendHorizontal /></InputGroup.Button>
					</InputGroup.Addon>
				</InputGroup.Root>
			</Card.Footer>
		</Card.Root>
	</div>
</div>
