import type { PageLoad } from './$types';

export const ssr = false;
export const prerender = true;

export const load: PageLoad = ({ params }) => {
	return {
		room_code: params.room_code
	};
};
