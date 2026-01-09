<script lang="ts">
	import { Slider } from '$lib/components/ui/slider';
	import * as ToggleGroup from '$lib/components/ui/toggle-group';
	import { Button } from '$lib/components/ui/button';
	import { PencilLine, Trash2, Eraser } from '@lucide/svelte';
	import ColorPicker from '$lib/components/color-picker.svelte';
	import { isMobile } from '$lib/utils';
	import { onMount } from 'svelte';
	import { CanvasModes } from '$lib/events';
	import { draw, erase, normalizePos } from '$lib/draw';

	import { drawData } from '$lib/draw.svelte.ts';

	let canvas = $state<HTMLCanvasElement | null>(null);
	let ctx = $state<CanvasRenderingContext2D>();

	let mousePos = $state({ x: 0, y: 0 });
	let offset = $state({ x: 0, y: 0 });
	let pos = $derived({ x: mousePos.x - offset.x, y: mousePos.y - offset.y });

	let insideCanvas = $state(false);
	let mouseDown = $state(false);

	let canvasSelectMode = $state(CanvasModes.Drawing);
	let prevCanvasMode = $state(CanvasModes.Drawing);
	let canvasPos = $derived(canvas?.getBoundingClientRect());

	onMount(() => {
		if (!canvas) return;

		ctx = canvas.getContext('2d');

		canvas.width = !isMobile() ? 800 : window.innerWidth - window.innerWidth * 0.2;
		canvas.height = (canvas.width * 9) / 16;
		drawData.canvasWidth = canvas.width;
		drawData.canvasHeight = canvas.height;

		canvasPos = canvas.getBoundingClientRect();

		offset.x = canvasPos.left;
		offset.y = canvasPos.top;

		canvas.addEventListener('mouseover', (e) => {
			insideCanvas = true;
		});

		document.addEventListener('mousemove', (e) => {
			mousePos.x = e.clientX;
			mousePos.y = e.clientY;
		});

		canvas.addEventListener('mouseout', () => {
			insideCanvas = false;
		});

		canvas.addEventListener('mousedown', () => {
			mouseDown = true;
		});

		canvas.addEventListener('mouseup', () => {
			mouseDown = false;
			prevCanvasMode = drawData.canvasMode;
		});
	});

	$effect(() => {
		canvas.width = !isMobile() ? 800 : window.innerWidth - window.innerWidth * 0.2;
		canvas.height = (canvas.width * 9) / 16;
		drawData.canvasWidth = canvas.width;
		drawData.canvasHeight = canvas.height;

		canvasPos = canvas.getBoundingClientRect();
	});

	$effect(() => {
		if ((!mouseDown || !insideCanvas) && drawData.canvasMode !== CanvasModes.Clear) {
			drawData.canvasMode = CanvasModes.Idle;
		}

		if (mouseDown && insideCanvas) {
			switch (canvasSelectMode) {
				case 'draw':
					drawData.canvasMode = CanvasModes.Drawing;
					prevCanvasMode = drawData.canvasMode;
					break;
				case 'erase':
					drawData.canvasMode = CanvasModes.Erasing;
					prevCanvasMode = drawData.canvasMode;
					break;
				default:
					break;
			}
		}

		drawData.x = pos.x;
		drawData.y = pos.y;

		switch (drawData.canvasMode) {
			case CanvasModes.Drawing:
				draw(ctx, pos.x, pos.y, drawData.hex, drawData.drawStrokeWidth);
				break;
			case CanvasModes.Erasing:
				// TODO: change drawStrokeWidth
				erase(ctx, pos.x, pos.y, drawData.eraseStrokeWidth);
				break;
			case CanvasModes.Clear:
				ctx.clearRect(0, 0, canvas.width, canvas.height);
				drawData.canvasMode = prevCanvasMode;
				break;
			case CanvasModes.Idle:
				ctx.beginPath();
				break;
		}
	});
</script>

<canvas bind:this={canvas} class="rounded-xl border bg-white"></canvas>
<div id="toolbar" class="mt-5 flex items-center justify-between gap-10 rounded-2xl border p-4">
	<Button
		onclick={() => {
			drawData.canvasMode = CanvasModes.Clear;
		}}
	>
		<Trash2 class="size-4" />
	</Button>
	{#if canvasSelectMode === CanvasModes.Drawing}
		<div class="rounded-full border-2">
			<ColorPicker bind:hex={drawData.hex} />
		</div>
		<Slider type="single" bind:value={drawData.drawStrokeWidth} max={100} step={2} />
	{/if}
	<br />

	{#if canvasSelectMode === CanvasModes.Erasing}
		<Slider type="single" bind:value={drawData.eraseStrokeWidth} max={100} step={2} />
	{/if}

	<ToggleGroup.Root type="single" bind:value={canvasSelectMode}>
		<ToggleGroup.Item value="draw" aria-label="select draw">
			<PencilLine class="size-4" />
		</ToggleGroup.Item>
		<ToggleGroup.Item value="erase" aria-label="select erase">
			<Eraser class="size-4" />
		</ToggleGroup.Item>
	</ToggleGroup.Root>
</div>
