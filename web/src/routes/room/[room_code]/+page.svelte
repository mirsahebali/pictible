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
	import { onMount, tick } from 'svelte';
	import { toWS } from '$lib/utils';
	import { EventTypes, CanvasModes } from '$lib/events';
	import { safeSocketSend } from '$lib/socket';
	import { normalizePos } from '$lib/draw';
	import { toast } from 'svelte-sonner';

	// TODO: add real players
	let players = $state(fakePlayers(10));
	// TODO: add real chats
	let chats = $state(fakeChats(40));
	// TODO: add real current player eval
	let isCurrentPlayer = $state(true);

	import { drawData } from '$lib/draw.svelte';

	let currentUsername = $state('');

	let socket = $state<WebSocket | null>(null);
	let { data } = $props();

	onMount(() => {
		if (!socket) socket = new WebSocket(toWS('/room-ws/' + data.room_code));

		currentUsername = localStorage.getItem('pictible-username');

		socket.addEventListener('open', async () => {
			await socket.send(
				JSON.stringify({ event: EventTypes.PlayerJoined, data: { username: currentUsername } })
			);
		});

		socket.addEventListener('message', (message) => {
			const { event, data }: { event: EventTypes; data: EventData } = JSON.parse(message.data);

			switch (event) {
				case EventTypes.PlayerJoined:
					toast.info('Player Joined: ' + data.username);
					break;
				case EventTypes.PlayerLeft:
					break;
				case EventTypes.PlayerInvited:
					break;

				case EventTypes.PlayerCurrentSelection:
					break;
				case EventTypes.PlayerDrawing:
					{
						if (isCurrentPlayer) {
							break;
						}
						const [recvX, recvY, recvHex, recvStrokeWidth] = data;
						drawData.x = recvX;
						drawData.y = recvY;
						drawData.hex = recvHex;
						drawData.drawStrokeWidth = recvStrokeWidth;
						drawData.canvasMode = 'draw';
					}

					break;
				case EventTypes.PlayerErasing:
					{
						if (isCurrentPlayer) {
							break;
						}
						const [recvX, recvY, recvStrokeWidth] = data;
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
</script>

<div class="gap-2 not-lg:flex-col md:flex" id="main-container">
	<div id="players">
		<Card.Root>
			<Card.Content>
				<ScrollArea class="h-[20vh] lg:h-[40vh]">
					<ul>
						{#each players as player, index (index)}
							<li class="my-1">{player.username}</li>

							<Separator />
						{/each}
					</ul>
				</ScrollArea>

				<div class="flex items-center space-x-2">
					<Switch id="viewer-mode" bind:checked={isCurrentPlayer} />
					<Label for="viewer-mode">Viewer Mode</Label>
				</div>
			</Card.Content>
		</Card.Root>
	</div>
	<div id="canvas">
		<div>
			{#if isCurrentPlayer}
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
