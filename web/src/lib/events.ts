export enum PlayerEvents {
	Drawing = 'drawing',
	Cleared = 'cleared',
	Erasing = 'erasing',
	Idle = 'idle'
}

export type DrawingData = {
	x: number;
	y: number;
	color: string;
};

export type ErasingData = {
	x: number;
	y: number;
};

export type EventData = {
	event: PlayerEvents;
	data: [number, number, string, number];
};
