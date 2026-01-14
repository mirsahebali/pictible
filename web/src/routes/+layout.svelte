<script lang="ts">
	import './layout.css';
	import favicon from '$lib/assets/favicon.png';
	import { ModeWatcher } from 'mode-watcher';
	import { Toaster } from 'svelte-sonner';
	import ThemeToggle from '$lib/components/theme-toggle.svelte';
	import { Button } from '$lib/components/ui/button/index.js';
	import { Linkedin, Github, Gitlab } from '@lucide/svelte';

	let { children } = $props();
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
</svelte:head>

<Toaster position="top-center" />
<ModeWatcher />

<main class="flex w-full flex-col">
	<header class="flex items-center justify-center gap-3">
		<h1 class="my-4 flex items-center gap-5 text-center text-4xl font-bold">
			<img src={favicon} width="64" class="rounded-full bg-white" alt="pictible-logo" />
			<span>Pictible</span>
			<ThemeToggle />
		</h1>
	</header>
	<div class="mb-10 flex w-full flex-col items-center justify-center">
		{@render children()}
	</div>
	<footer class="bottom-0 left-0 w-full py-2 text-center accent-background">
		Made By:
		<div>
			<Button
				class="text-lg font-bold text-accent-foreground"
				variant="link"
				href="https://www.linkedin.com/in/mir-saheb-ali/">Mir Saheb Ali</Button
			>

			<Button
				variant="link"
				href="https://www.linkedin.com/in/mir-saheb-ali/"
				class="scale-130 font-bold"
			>
				<Linkedin />
			</Button>

			<Button
				variant="link"
				href="https://github.com/mirsahebali"
				class="scale-130 font-bold text-foreground"
			>
				<Github />
			</Button>

			<Button
				variant="link"
				href="https://gitlab.com/mirsahebali"
				class="scale-130 font-bold text-orange-400"
			>
				<Gitlab />
			</Button>
		</div>
	</footer>
</main>
