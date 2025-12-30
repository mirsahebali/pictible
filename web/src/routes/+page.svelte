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
	import {
		CreateRoomSchema,
		JoinRoomSchema,
		JSONServerResponseSchema,
		type JoinRoomData
	} from '$lib/schema';
	import { goto } from '$app/navigation';
	import { resolve } from '$app/paths';

	const createRoomForm = superForm(defaults(valibot(CreateRoomSchema)), {
		validators: valibot(CreateRoomSchema),
		SPA: true,
		async onUpdate({ form: f }) {
			if (f.valid) {
				let res: Response | null;
				try {
					res = await fetch(to('/api/create'), { method: 'POST', body: JSON.stringify(f.data) });

					const result = v.safeParse(JSONServerResponseSchema, await res.json());

					if (!result.success) {
						toast.error('Invalid data recieved');
						console.error(result.issues);
						console.log(result.output);
						return;
					}
					const data = result.output.data;
					if (!data) return;

					const move_to = `/room/[room_code]`;

					localStorage.setItem('pictible-username', (data as JoinRoomData).username);
					localStorage.setItem('pictible-room_code', (data as JoinRoomData).room_code);

					await goto(
						resolve(move_to, {
							room_code: (data as JoinRoomData).room_code
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

	const { form: createRoomData, enhance: createRoomEnhance } = createRoomForm;

	const joinRoomForm = superForm(defaults(valibot(JoinRoomSchema)), {
		validators: valibot(JoinRoomSchema),
		SPA: true,
		async onUpdate({ form: f }) {
			if (f.valid) {
				let res: Response | null;
				try {
					res = await fetch(to('/api/join'), { method: 'POST', body: JSON.stringify(f.data) });

					const result = await v.safeParseAsync(JSONServerResponseSchema, await res.json());

					if (!result.success) {
						toast.error('Invalid data recieved');
						console.error(result.issues);
						console.log(result.output);
						return;
					}

					const move_to = `/room/[room_code]`;

					localStorage.setItem('pictible-username', f.data.username);
					localStorage.setItem('pictible-room_code', f.data.room_code);

					await goto(
						resolve(move_to, {
							room_code: f.data.room_code
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
		<form method="POST" use:createRoomEnhance>
			<Form.Field form={createRoomForm} name="username">
				<Form.Control>
					{#snippet children({ props })}
						<Form.Label>Player Name</Form.Label>
						<Input {...props} bind:value={$createRoomData.username} />
					{/snippet}
				</Form.Control>
				<Form.Description>This is your public display name.</Form.Description>
				<Form.FieldErrors />
			</Form.Field>
			<Form.Button>Create Room</Form.Button>
		</form>

		<div class="flex items-center justify-center gap-4">
			<Separator />
			<span> OR</span>
			<Separator />
		</div>

		<form method="POST" use:joinRoomEnhance>
			<Form.Field form={joinRoomForm} name="username">
				<Form.Control>
					{#snippet children({ props })}
						<Form.Label>Player Name</Form.Label>
						<Input {...props} bind:value={$joinRoomData.username} />
					{/snippet}
				</Form.Control>
				<Form.Description>This is your public display name.</Form.Description>
				<Form.FieldErrors />
			</Form.Field>

			<Form.Field form={joinRoomForm} name="room_code">
				<Form.Control>
					{#snippet children({ props })}
						<Form.Label>Room Code</Form.Label>
						<Input
							{...props}
							type="text"
							bind:value={$joinRoomData.room_code}
							placeholder="Room Code"
						/>
					{/snippet}
				</Form.Control>
				<Form.FieldErrors />
			</Form.Field>
			<Form.Button>Join Room</Form.Button>
		</form>
	</Card.Content>
</Card.Root>
