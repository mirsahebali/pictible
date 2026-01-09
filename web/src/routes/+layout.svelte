<script lang="ts">
	import './layout.css';
	import favicon from '$lib/assets/favicon.png';
	import { ModeWatcher } from 'mode-watcher';
	import { Toaster } from 'svelte-sonner';
	import ThemeToggle from '$lib/components/theme-toggle.svelte';

	let { children } = $props();
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
</svelte:head>

<Toaster position="top-center" />
<ModeWatcher />

<main class="w-full">
	<header class="flex items-center justify-center gap-3">
		<h1 class="my-4 flex items-center gap-5 text-center text-4xl font-bold">
			<img src={favicon} width="64" class="rounded-full bg-white" alt="pictible-logo" />
			<span>Pictible</span>
			<ThemeToggle />
		</h1>
	</header>
	<div class="flex flex-col items-center justify-center">
		{@render children()}
	</div>
</main>
