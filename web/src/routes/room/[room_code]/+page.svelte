<script module lang="ts">
</script>

<script lang="ts">
	import ColorPicker from '$lib/components/color-picker.svelte';
	import { Button } from '$lib/components/ui/button';
	import * as ButtonGroup from '$lib/components/ui/button-group';
	import type { Colord } from 'colord';
	import { onMount } from 'svelte';
	import type { RgbaColor, HsvaColor } from 'svelte-awesome-color-picker';
	import { Eraser, PencilLine } from '@lucide/svelte';

	import { Slider } from '$lib/components/ui/slider/index';
	import ThemeToggle from '$lib/components/theme-toggle.svelte';
	import Counter from '$lib/components/counter.svelte';
	import { EventQueue, PlayerEvents, type EventData } from '$lib/events';
	import { toWS } from '$lib/utils';

	import type { PageProps } from './$types';
	import { toast } from 'svelte-sonner';

	let rgb = $state({} as RgbaColor);
	let hsv = $state({} as HsvaColor);
	let color = $state({} as Colord);
	let hex = $state('#000000');

	let playerData = $state({ username: '', room_code: '' });
	let startX = $state(0);
	let startY = $state(0);

	let socket = $state<WebSocket | null>(null);

	let strokeWidth = $state(4);
	let mouseDown = $state(false);
	let eventQueue = $state(new EventQueue());

	let currPlayerEvent = $state(PlayerEvents.Idle);
	let prevPlayerEvent = $derived<PlayerEvents>(currPlayerEvent);

	const canvasOffset = $state({ x: 0, y: 0 });
	const pos = $state({ x: 0, y: 0 });

	let canvas: HTMLCanvasElement | null = null;
	let ctx: CanvasRenderingContext2D | null = null;

	let { data }: PageProps = $props();

	const drawOrErase = (
		e:
			| (MouseEvent & {
					currentTarget: EventTarget & HTMLCanvasElement;
			  })
			| MouseEvent
	) => {
		if (!ctx) return;

		const x = e.clientX - canvasOffset.x;
		const y = e.clientY - canvasOffset.y;

		pos.x = x;
		pos.y = y;

		drawOrEraseNetwork(x, y, hex, strokeWidth);
		// ctx.lineWidth = strokeWidth;
		// ctx.lineCap = 'round';
		//
		// console.log('x: %d, y: %d', startX, startY);
		//
		// if (currPlayerEvent == PlayerEvents.Drawing) {
		// 	ctx.lineTo(x, y);
		// 	ctx.stroke();
		// } else if (currPlayerEvent == PlayerEvents.Erasing) {
		// 	console.log('Erasing?');
		// 	ctx.clearRect(x, y, strokeWidth + 2, strokeWidth + 2);
		// } else {
		// 	return;
		// }
	};

	const drawOrEraseNetwork = (
		x: number,
		y: number,
		color: string,
		strokeWidth: number = 12,
		erasing: boolean = false
	) => {
		if (!ctx) return;

		hex = color;
		ctx.lineWidth = strokeWidth;
		ctx.lineCap = 'round';

		if (!erasing) {
			ctx.lineTo(x, y);
			ctx.stroke();
		} else {
			ctx.clearRect(x, y, strokeWidth + 2, strokeWidth + 2);
		}
	};

	const setDraw = () => {
		if (!ctx) return;
		currPlayerEvent = PlayerEvents.Drawing;
	};

	const setErase = () => {
		if (!ctx) return;
		currPlayerEvent = PlayerEvents.Erasing;
	};

	onMount(() => {
		if (!canvas) return;

		if (!socket) {
			socket = new WebSocket(toWS('/room-ws/' + data.room_code));
		}

		socket.addEventListener('open', (_ev) => {
			toast.info('Connected');
		});

		playerData.username = localStorage.getItem('pictible-username') || '';
		playerData.room_code = localStorage.getItem('pictible-room_code') || '';

		socket.addEventListener('message', (message) => {
			const data: string = message.data;

			let drawing_data: EventData = JSON.parse(data);
			let {
				event: playerEvent,
				data: [x, y, color, strokeWidth]
			} = drawing_data;
			currPlayerEvent = playerEvent;

			switch (currPlayerEvent) {
				case PlayerEvents.Drawing:
					drawOrEraseNetwork(x, y, color, strokeWidth);
					break;
				case PlayerEvents.Cleared:
					break;
				case PlayerEvents.Erasing:
					drawOrEraseNetwork(x, y, color, strokeWidth, true);
					break;
				case PlayerEvents.Idle:
					break;
			}
		});

		document.body.onmousedown = function () {
			mouseDown = true;
		};
		document.body.onmouseup = function () {
			mouseDown = false;
		};

		ctx = canvas.getContext('2d');
		canvas.addEventListener('mousedown', (e) => {
			startX = e.clientX;
			startY = e.clientY;
		});

		canvas.addEventListener('mouseup', () => {
			if (!ctx) return;
			ctx.stroke();
			ctx.beginPath();
		});

		canvas.addEventListener('mousemove', (e) => {
			if (mouseDown) drawOrErase(e);
		});

		canvas.width = 800;
		canvas.height = 400;

		canvasOffset.x = canvas.offsetLeft;
		canvasOffset.y = canvas.offsetTop;

		if (!ctx) return;
	});

	$effect(() => {
		if (!ctx) return;
		if (!canvas) return;
		if (!socket) return;

		if (mouseDown) currPlayerEvent = prevPlayerEvent;

		ctx.strokeStyle = hex;
		ctx.lineWidth = strokeWidth;

		if (currPlayerEvent == PlayerEvents.Drawing || currPlayerEvent == PlayerEvents.Erasing)
			canvas.style.cursor = 'crosshair';

		console.log('Current Event: ', currPlayerEvent);
		console.log('Hex', hex);
		switch (currPlayerEvent) {
			case PlayerEvents.Drawing:
				socket.send(JSON.stringify({ event: 'drawing', data: [pos.x, pos.y, hex, strokeWidth] }));
				break;
			case PlayerEvents.Cleared:
				break;
			case PlayerEvents.Erasing:
				break;
			case PlayerEvents.Idle:
				break;
		}
	});
</script>

<section class="container flex flex-col items-center gap-10">
	<div id="toolbar" class="flex items-center gap-2">
		<!-- TODO: Change this with [`ToggleGroup`] from component library -->
		<ButtonGroup.Root aria-label="control" orientation="horizontal" class="h-fit">
			<Button variant="outline">
				<ColorPicker bind:rgb bind:hsv bind:color bind:hex />
			</Button>
			<Button variant="outline" class="text-xl" onclick={setDraw}>
				<PencilLine />
			</Button>
			<Button variant="outline" class="text-xl" onclick={setErase}>
				<Eraser />
			</Button>

			<Button
				variant="outline"
				onclick={() => {
					if (!ctx) return;
					if (!canvas) return;

					ctx.clearRect(0, 0, canvas.width, canvas.height);
				}}>Clear</Button
			>
		</ButtonGroup.Root>

		<Slider type="single" bind:value={strokeWidth} class="w-50" max={100} min={2} step={2} />
		<Counter bind:count={strokeWidth} />
		<ThemeToggle />
	</div>

	<div>
		<div>Username: <br /> {playerData.username}</div>
	</div>
	<div class="border border-primary bg-white">
		<canvas bind:this={canvas}></canvas>
	</div>

	<div>
		<div>Room Code: <span>{playerData.room_code}</span></div>

		<div>
			Invite Link: <Button variant="link" href={window.location.href}>
				{window.location.href}</Button
			>
		</div>
	</div>
</section>
