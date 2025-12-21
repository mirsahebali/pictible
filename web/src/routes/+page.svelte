<script lang="ts">
	import ColorPicker from '$lib/components/color-picker.svelte';
	import { Button } from '$lib/components/ui/button';
	import * as ButtonGroup from '$lib/components/ui/button-group';
	import type { Colord } from 'colord';
	import { onMount } from 'svelte';
	import type { RgbaColor, HsvaColor } from 'svelte-awesome-color-picker';

	import { Slider } from '$lib/components/ui/slider/index';
	import ThemeToggle from '$lib/components/theme-toggle.svelte';
	import Counter from '$lib/components/counter.svelte';

	let rgb = $state({} as RgbaColor);
	let hsv = $state({} as HsvaColor);
	let color = $state({} as Colord);
	let hex = $state('#000000');
	let startX = $state(0);
	let startY = $state(0);

	let strokeWidth = $state(4);

	const canvasOffset = $state({ x: 0, y: 0 });

	let canvas: HTMLCanvasElement | null = null;
	let ctx: CanvasRenderingContext2D | null = null;

	let isDrawing = $state(false);

	onMount(() => {
		if (!canvas) return;

		ctx = canvas.getContext('2d');
		canvas.addEventListener('mousedown', (e) => {
			isDrawing = true;
			startX = e.clientX;
			startY = e.clientY;
		});

		canvas.addEventListener('mouseup', () => {
			isDrawing = false;
			if (!ctx) return;

			ctx.stroke();
			ctx.beginPath();
		});

		canvas.addEventListener('mouseleave', () => {
			isDrawing = false;
		});

		canvas.addEventListener('mouseout', () => {
			isDrawing = false;
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
	});

	const draw = (
		e: MouseEvent & {
			currentTarget: EventTarget & HTMLCanvasElement;
		}
	) => {
		if (!ctx) return;
		if (!isDrawing) return;

		ctx.lineWidth = strokeWidth;
		ctx.lineCap = 'round';

		const x = e.clientX - canvasOffset.x;
		const y = e.clientY - canvasOffset.y;

		console.log('x: %d, y: %d', x, y);

		ctx.lineTo(x, y);
		ctx.stroke();
	};
</script>

<main class="flex items-center justify-center">
	<div>
		<h1 class="my-10 text-center text-4xl font-bold">Pictible</h1>

		<section class="container flex flex-col items-center gap-10">
			<div id="toolbar" class="flex items-center gap-2">
				<h2 class="text-xl"></h2>

				<ButtonGroup.Root aria-label="control" orientation="horizontal" class="h-fit">
					<ColorPicker bind:rgb bind:hsv bind:color bind:hex />

					<Button
						variant="outline"
						onclick={() => {
							if (!ctx) return;
							if (!canvas) return;

							ctx.fillStyle = '#ffffff';
							ctx.clearRect(0, 0, canvas.width, canvas.height);
						}}>Clear</Button
					>
				</ButtonGroup.Root>

				<Slider type="single" bind:value={strokeWidth} class="w-50" max={100} min={2} step={2} />
				<Counter bind:count={strokeWidth} />
				<ThemeToggle />
			</div>

			<div class="bg-white">
				<canvas bind:this={canvas} id="drawing-board" class="border border-black" onmousemove={draw}
				></canvas>
			</div>
		</section>
	</div>
</main>
