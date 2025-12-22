<script lang="ts">
	import ColorPicker from 'svelte-awesome-color-picker';
	import type { Colord } from 'colord';
	import type { RgbaColor, HsvaColor } from 'svelte-awesome-color-picker';

	let {
		hex = $bindable(),
		rgb = $bindable(),
		hsv = $bindable(),
		color = $bindable()
	}: { hex: string; rgb: RgbaColor; hsv: HsvaColor; color: Colord } = $props();
</script>

<div class="dark-color-picker">
	<ColorPicker label="" bind:hex bind:rgb bind:hsv bind:color position="responsive" />
</div>

<style>
	.dark-color-picker {
		--cp-bg-color: #333;
		--cp-border-color: white;
		--cp-text-color: white;
		--cp-input-color: #555;
		--cp-button-hover-color: #777;
	}
</style>
