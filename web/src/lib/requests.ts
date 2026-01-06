import { to } from '$lib/utils';

const getRoomData = async (roomCode: string) => {
	const res = await fetch(to('/api/room/' + roomCode));

	const data = await res.json();

	return data;
};
