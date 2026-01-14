<script module lang="ts">
	const InviteRoomSchema = v.object({
		username: v.pipe(v.string(), v.maxLength(8), v.minLength(3))
	});
</script>

<script lang="ts">
	import { defaults, superForm } from 'sveltekit-superforms';
	import { valibot } from 'sveltekit-superforms/adapters';
	import * as v from 'valibot';
	import { toast } from 'svelte-sonner';
	import * as Form from '$lib/components/ui/form';
	import * as Card from '$lib/components/ui/card';
	import { Separator } from '$lib/components/ui/separator';
	import { Input } from '$lib/components/ui/input';

	import { to } from '$lib/utils';
	import { JSONServerResponseSchema } from '$lib/schema';
	import { goto } from '$app/navigation';
	import { resolve } from '$app/paths';

	const { data } = $props();

	const joinRoomForm = superForm(defaults(valibot(InviteRoomSchema)), {
		validators: valibot(InviteRoomSchema),
		SPA: true,
		async onUpdate({ form: f }) {
			if (f.valid) {
				let res: Response | null;
				try {
					res = await fetch(to('/api/join'), {
						method: 'POST',
						body: JSON.stringify({ username: f.data.username, room_code: data.room_code })
					});

					const result = await v.safeParseAsync(JSONServerResponseSchema, await res.json());

					if (!result.success) {
						toast.error('Invalid data recieved');
						console.error(result.issues);
						console.log(result.output);
						return;
					}

					const move_to = `/room/[room_code]`;

					localStorage.setItem('pictible-username', f.data.username);
					localStorage.setItem('pictible-room_code', data.room_code);

					await goto(
						resolve(move_to, {
							room_code: data.room_code
						})
					);
				} catch (error) {
					toast.error('error occoured');
					console.error(error);
				}
			} else {
				// report invalid
				toast.error('Invalid Form');
			}
		}
	});

	const { form: joinRoomData, enhance: joinRoomEnhance } = joinRoomForm;
</script>

<Card.Root class="">
	<Card.Content class="my-5 flex w-[80vw] flex-col items-center justify-center md:w-[50vw]">
		<div class="flex items-center justify-center gap-4">
			<form method="POST" use:joinRoomEnhance>
				<Form.Field form={joinRoomForm} name="username">
					<Form.Control>
						{#snippet children({ props })}
							<Form.Label>Player Name</Form.Label>
							<Input {...props} bind:value={$joinRoomData.username} />
						{/snippet}
					</Form.Control>
					<Form.Description>Input a username to enter the room</Form.Description>
					<Form.FieldErrors />
				</Form.Field>
				<Form.Button>Join Room</Form.Button>
			</form>
		</div>
	</Card.Content>
</Card.Root>
