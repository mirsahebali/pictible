<script lang="ts">
	import * as ButtonGroup from '$lib/components/ui/button-group';
	import { Input } from '$lib/components/ui/input';
	import { Button } from '$lib/components/ui/button';

	import MinusIcon from '@lucide/svelte/icons/minus';
	import PlusIcon from '@lucide/svelte/icons/plus';

	let { count = $bindable() }: { count: number } = $props();
</script>

<ButtonGroup.Root>
	<Input
		id=""
		bind:value={count}
		size={3}
		class="h-8 !w-14 font-mono"
		maxlength={3}
		oninput={() => {}}
		type="text"
		inputmode="numeric"
		pattern="[0-9]*"
	/>
	<Button
		onclick={() => {
			count -= 2;
		}}
		variant="outline"
		size="icon-sm"
		type="button"
		aria-label="Decrement"
		disabled={count <= 1}
	>
		<MinusIcon />
	</Button>
	<Button
		onclick={() => {
			count += 2;
		}}
		variant="outline"
		size="icon-sm"
		type="button"
		aria-label="Increment"
		disabled={count >= 99}
	>
		<PlusIcon />
	</Button>
</ButtonGroup.Root>
