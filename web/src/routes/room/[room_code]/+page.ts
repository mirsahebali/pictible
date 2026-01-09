import type { PageLoad } from './$types';

import { getRoomData } from '$lib/requests';

export const prerender = true;

export const load: PageLoad = async ({ params }) => {
	const roomData = await getRoomData(params.room_code);
	if (!roomData) {
		return {
			error: true
		};
	}

	return {
		error: false,
		room_code: params.room_code,
		roomData
	};
};
