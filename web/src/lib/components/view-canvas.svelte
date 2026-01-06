<script lang="ts">
	import { Slider } from '$lib/components/ui/slider';
	import * as ToggleGroup from '$lib/components/ui/toggle-group';
	import { Button } from '$lib/components/ui/button';
	import { PencilLine, Trash2, Eraser } from '@lucide/svelte';
	import ColorPicker from '$lib/components/color-picker.svelte';
	import { isMobile } from '$lib/utils';
	import { onMount } from 'svelte';
	import { CanvasModes } from '$lib/events';
	import { draw, erase, toCanvasPos } from '$lib/draw';
	import { drawData } from '$lib/draw.svelte.ts';

	let canvas = $state<HTMLCanvasElement | null>(null);
	let ctx = $state<CanvasRenderingContext2D>();

	let mousePos = $state({ x: 0, y: 0 });
	let offset = $state({ x: 0, y: 0 });
	let pos = $derived({ x: mousePos.x - offset.x, y: mousePos.y - offset.y });

	let canvasSelectMode = $state(CanvasModes.Drawing);
	let prevCanvasMode = $state(CanvasModes.Drawing);
	let canvasPos = $derived(canvas?.getBoundingClientRect());

	onMount(() => {
		if (!canvas) return;

		ctx = canvas.getContext('2d');

		canvas.width = !isMobile() ? 800 : window.innerWidth - window.innerWidth * 0.2;
		canvas.height = (canvas.width * 9) / 16;

		canvasPos = canvas.getBoundingClientRect();

		offset.x = canvasPos.left;
		offset.y = canvasPos.top;

		document.addEventListener('mousemove', (e) => {
			mousePos.x = e.clientX;
			mousePos.y = e.clientY;
		});
	});
	$effect(() => {
		switch (drawData.canvasMode) {
			case CanvasModes.Drawing:
				{
					const [canvasX, canvasY] = toCanvasPos(
						[drawData.x, drawData.y],
						[canvas.width, canvas.height]
					);
					draw(ctx, canvasX, canvasY, drawData.hex, drawData.drawStrokeWidth);
				}
				break;

			case CanvasModes.Erasing:
				{
					const [canvasX, canvasY] = toCanvasPos(
						[drawData.x, drawData.y],
						[canvas.width, canvas.height]
					);
					erase(ctx, canvasX, canvasY, drawData.eraseStrokeWidth);
				}
				break;
			case CanvasModes.Clear:
				ctx.clearRect(0, 0, canvas.width, canvas.height);
				break;
			case CanvasModes.Idle:
				ctx.beginPath();
				break;
		}
	});
</script>

<canvas bind:this={canvas} class="rounded-xl border"></canvas>
