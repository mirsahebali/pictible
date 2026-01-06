<script lang="ts">
	import './layout.css';
	import favicon from '$lib/assets/favicon.png';
	import { ModeWatcher } from 'mode-watcher';
	import { Toaster } from 'svelte-sonner';

	let { children } = $props();
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
</svelte:head>

<Toaster position="top-center" />
<ModeWatcher />

<main class="w-full">
	<div class="flex flex-col items-center justify-center">
		<h1 class="my-4 text-center text-4xl font-bold">Pictible</h1>
		{@render children()}
	</div>
</main>
