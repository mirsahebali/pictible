import * as v from 'valibot';

export const CreateRoomSchema = v.object({
	username: v.pipe(v.string(), v.minLength(3), v.maxLength(10))
});

export type CreateRoomData = v.InferInput<typeof CreateRoomSchema>;

export const JoinRoomSchema = v.object({
	username: v.pipe(v.string(), v.minLength(3), v.maxLength(10)),
	room_code: v.pipe(v.string(), v.length(6))
});

export type JoinRoomData = v.InferInput<typeof JoinRoomSchema>;

export const JSONServerResponseSchema = v.object({
	data: v.union([v.string(), JoinRoomSchema, CreateRoomSchema, v.null()]),
	is_error: v.pipe(v.boolean()),
	message: v.string(),
	status_code: v.pipe(v.number(), v.maxValue(600), v.minValue(100))
});

export type JSONServerResponse = v.InferInput<typeof JSONServerResponseSchema>;
