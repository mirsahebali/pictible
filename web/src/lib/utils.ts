import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';
import { faker } from '@faker-js/faker';

export function cn(...inputs: ClassValue[]) {
	return twMerge(clsx(inputs));
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type WithoutChild<T> = T extends { child?: any } ? Omit<T, 'child'> : T;
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type WithoutChildren<T> = T extends { children?: any } ? Omit<T, 'children'> : T;
export type WithoutChildrenOrChild<T> = WithoutChildren<WithoutChild<T>>;
export type WithElementRef<T, U extends HTMLElement = HTMLElement> = T & { ref?: U | null };

export const isDev = () => import.meta.env.DEV;

export const to = (route: string) => (import.meta.env.DEV ? 'http://localhost:4069' : '') + route;

export const toWS = (route: string) => (import.meta.env.DEV ? 'ws://localhost:4069' : '') + route;

const _fakePlayer = () => {
	return { username: faker.internet.username() };
};

export const fakePlayers = (length: number) => {
	console.warn('Remove it on prod', fakePlayers);
	const players = [];

	for (let index = 0; index < length; index++) {
		players.push(_fakePlayer());
	}
	return players;
};

const _fakeChat = () => {
	return {
		username: faker.internet.username(),
		sent_at: new Date(),
		message: faker.word.noun()
	};
};

export const fakeChats = (length: number) => {
	console.warn('Remove it on prod', fakeChats);
	const chats = [];

	for (let index = 0; index < length; index++) {
		chats.push(_fakeChat());
	}

	return chats;
};

export const isMobile = () => window.innerWidth <= 500;
