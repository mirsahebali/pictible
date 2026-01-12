import type { PageLoad } from './$types';

import { getRoomData, getChatData } from '$lib/requests';
import { isDev } from '$lib/utils';

export const prerender = true;

export const load: PageLoad = async ({ params }) => {
	const roomData = await getRoomData(params.room_code);
	const roomChatData = await getChatData(params.room_code);

	if (!roomData) {
		if (!isDev()) window.location.href = '/';
		return {
			error: true
		};
	}

	return {
		error: false,
		room_code: params.room_code,
		roomData,
		roomChatData
	};
};
