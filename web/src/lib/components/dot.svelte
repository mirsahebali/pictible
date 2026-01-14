<script lang="ts">
	const { active }: { active: boolean } = $props();
</script>

{#if active}
	<span class="relative flex size-3">
		<span
			class="absolute inline-flex h-full w-full animate-ping rounded-full bg-green-400 opacity-75"
		></span> <span class="relative inline-flex size-3 rounded-full bg-green-500"></span></span
	>
{:else}
	<div class="size-3 rounded-full border bg-red-950"></div>
{/if}
