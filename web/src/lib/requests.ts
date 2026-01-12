import { to } from '$lib/utils';
import * as v from 'valibot';
import { JSONServerResponseSchema } from '$lib/schema';
import { toast } from 'svelte-sonner';

export const PlayerSchema = v.object({
	id: v.pipe(v.number()),
	username: v.pipe(v.string(), v.maxLength(15), v.minLength(3)),
	active: v.pipe(v.boolean()),
	inserted_at: v.pipe(
		v.string(),
		v.transform((input) => new Date(input))
	),
	updated_at: v.pipe(
		v.string(),
		v.transform((input) => new Date(input))
	)
});

type PlayerData = v.InferInput<typeof PlayerSchema>;

export const RoomSchema = v.object({
	id: v.pipe(v.number()),
	room_code: v.pipe(v.string(), v.length(6)),
	inserted_at: v.pipe(
		v.string(),
		v.transform((input) => new Date(input))
	),
	updated_at: v.pipe(
		v.string(),
		v.transform((input) => new Date(input))
	),
	players: v.optional(v.array(PlayerSchema))
});

type RoomData = v.InferInput<typeof RoomSchema>;

export const ChatSchema = v.object({
	id: v.pipe(v.number()),
	message: v.pipe(v.string()),
	username: v.pipe(v.string()),
	sent_at: v.pipe(
		v.string(),
		v.transform((input) => new Date(input))
	)
});

export const getRoomData = async (roomCode: string): RoomData | null => {
	let res;
	try {
		res = await fetch(to('/api/room/' + roomCode));
	} catch (error) {
		return null;
	}

	const result = await res.json();

	const data = v.safeParse(JSONServerResponseSchema, result);

	if (!data.success) {
		console.debug('Invalid data recieved: ');
		console.debug(result.issues);
		console.debug('result.ouput = ', result.output);
		console.debug('data = ', data);
		return null;
	}

	const output = data.output;

	if (output.is_error) {
		toast.error('Error recieved from the server');
		if (output.status_code === 404) toast.error('Room does not exists');
		console.debug(output.message);
		return null;
	}

	const roomData = v.safeParse(RoomSchema, JSON.parse(output.data));
	if (!roomData.success) {
		console.debug('Invalid room data');
		console.debug(roomData.issues);
		return null;
	}

	return roomData.output;
};

export const getChatData = async (room_code: string) => {
	const res = await fetch(to('/api/chats/' + room_code));

	const json = await res.json();

	const parsed = v.safeParse(JSONServerResponseSchema, json);

	if (!parsed.success) {
		toast.error('Error response');
		console.log(parsed.issues);
		return null;
	}

	const data = v.safeParse(v.array(ChatSchema), JSON.parse(parsed.output.data));

	if (!data.success) {
		toast.error('Invalid chat data');
		console.log(data.issues);
		return null;
	}

	return data.ouptut;
};
