<script lang="ts">
	import * as Table from '$lib/components/ui/table';
	import Dot from '$lib/components/dot.svelte';
	import type { PlayerData } from '$lib/schema';
	import ScrollArea from '$lib/components/ui/scroll-area/scroll-area.svelte';

	const { list, room_data }: { list: PlayerData[] } = $props();
</script>

<ScrollArea class="h-[20vh] sm:h-[30vh]">
	<Table.Root>
		<Table.Header>
			<Table.Row>
				<Table.Head>Username</Table.Head>
				<Table.Head>Active</Table.Head>
			</Table.Row>
		</Table.Header>
		<Table.Body>
			{#each list as player, index (index)}
				<Table.Row>
					<Table.Cell class="text-lg font-bold">{player.username}</Table.Cell>
					<Table.Cell class=" ">
						<div class="flex items-center justify-center">
							<Dot active={player.active} />
						</div>
					</Table.Cell>
				</Table.Row>
			{/each}
		</Table.Body>
	</Table.Root>
</ScrollArea>
