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
	import { PlayerEvents } from './events';

	let rgb = $state({} as RgbaColor);
	let hsv = $state({} as HsvaColor);
	let color = $state({} as Colord);
	let hex = $state('#000000');
	let startX = $state(0);
	let startY = $state(0);

	let strokeWidth = $state(4);
	let mouseDown = $state(false);

	let currPlayerEvent = $state(PlayerEvents.Idle);
	let prevPlayerEvent = $derived<PlayerEvents>(currPlayerEvent);

	const canvasOffset = $state({ x: 0, y: 0 });

	let canvas: HTMLCanvasElement | null = null;
	let ctx: CanvasRenderingContext2D | null = null;

	onMount(() => {
		if (!canvas) return;

		document.body.onmousedown = function () {
			mouseDown = true;
		};
		document.body.onmouseup = function () {
			mouseDown = false;
		};

		ctx = canvas.getContext('2d');
		canvas.addEventListener('mousedown', (e) => {
			currPlayerEvent = prevPlayerEvent;
			startX = e.clientX;
			startY = e.clientY;
		});

		canvas.addEventListener('mouseup', () => {
			prevPlayerEvent = currPlayerEvent;
			currPlayerEvent = PlayerEvents.Idle;
			if (!ctx) return;

			ctx.stroke();
			ctx.beginPath();
		});

		canvas.addEventListener('mouseleave', () => {
			currPlayerEvent = PlayerEvents.Idle;
		});

		canvas.addEventListener('mouseout', () => {
			currPlayerEvent = PlayerEvents.Idle;
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

		ctx.strokeStyle = hex;
		ctx.lineWidth = strokeWidth;

		if (currPlayerEvent == PlayerEvents.Drawing || currPlayerEvent == PlayerEvents.Erasing)
			canvas.style.cursor = 'crosshair';
	});

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

		ctx.lineWidth = strokeWidth;
		ctx.lineCap = 'round';

		console.log('x: %d, y: %d', x, y);

		if (currPlayerEvent == PlayerEvents.Drawing) {
			ctx.lineTo(x, y);
			ctx.stroke();
		} else if (currPlayerEvent == PlayerEvents.Erasing) {
			console.log('Erasing?');
			ctx.clearRect(x, y, strokeWidth + 2, strokeWidth + 2);
		} else {
			return;
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
</script>

<main class="flex items-center justify-center">
	<div>
		<h1 class="my-10 text-center text-4xl font-bold">Pictible</h1>

		<section class="container flex flex-col items-center gap-10">
			<div id="toolbar" class="flex items-center gap-2">
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

			<div class="border border-primary bg-white">
				<canvas bind:this={canvas}></canvas>
			</div>
		</section>
	</div>
</main>
