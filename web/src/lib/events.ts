export enum PlayerEvents {
	Drawing = 'drawing',
	Cleared = 'cleared',
	Erasing = 'erasing',
	Idle = 'idle'
}

export type DrawingData = {
	pos: Vec2;
	color: string;
	stroke_width: number;
};

export type ErasingData = Omit<DrawingData, 'color'>;

export type PlayerData = {
	username: string;
	room_code: string;
};

export enum EventTypes {
	// Lobby Events
	PlayerJoined,
	PlayerLeft,
	PlayerInvited,
	PlayerSwitch,

	// Canvas events
	PlayerDrawing,
	PlayerErasing,
	PlayerCleared,
	PlayerIdle,

	PlayerSentChat,

	// Nil
	NilEvent
}

type EventData = DrawingData | ErasingData | PlayerData | Omit<PlayerData, 'room_code'>;

type QueueData = [EventTypes, EventData];

export interface IEventQueue {
	len(): number;
	eventQueue: QueueData[];
	peek(): QueueData | null;
	dequeue(): QueueData | null;
	enqueue(event: EventTypes, data: EventData): number;
	syncEvent(eventQueueData: QueueData[]): void;
}

export class EventQueue implements IEventQueue {
	eventQueue: QueueData[];

	constructor(eventQueue: QueueData[] = []) {
		this.eventQueue = eventQueue;
	}

	syncEvent(eventQueueData: QueueData[]): void {
		this.eventQueue = eventQueueData;
	}

	enqueue = (event: EventTypes, data: EventData): number => this.eventQueue.push([event, data]);

	dequeue = (): QueueData | null => this.eventQueue.shift() || null;

	dequeue_n = (length: number): QueueData[] => {
		const dequeue_data = [];
		if (length > this.length) {
			console.warn('Requested dequeue data is less than total data elements');
			length = this.length;
		}
		for (let index = 0; index < length; index++) {
			dequeue_data.push(this.dequeue());
		}

		return dequeue_data;
	};

	peek = (): QueueData | null => this.eventQueue[this.eventQueue.length - 1];

	len = (): number => this.eventQueue.length;
}

export const mapFunction = <T>(queueData: QueueData, mapFunc: (data: EventData) => T) =>
	mapFunc(queueData[1]);
console.log(JSON.stringify(EventTypes.NilEvent));

export enum CanvasModes {
	Drawing = 'draw',
	Erasing = 'erase',
	Clear = 'clear',
	Idle = 'idle'
}
