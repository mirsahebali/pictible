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
	strokeWidth: number;
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
	PlayerCurrentSelection,

	// Canvas events
	PlayerDrawing,
	PlayerErasing,
	PlayerCleared,

	// Word Events
	PlayerWordSelection,
	PlayersGuessing,

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

	dequeue = (): QueueData | null => this.eventQueue.pop() || null;

	peek = (): QueueData | null => this.eventQueue[this.eventQueue.length - 1];

	len = (): number => this.eventQueue.length;
}

export const mapFunction = <T>(queueData: QueueData, mapFunc: (data: EventData) => T) =>
	mapFunc(queueData[1]);
console.log(JSON.stringify(EventTypes.NilEvent));
