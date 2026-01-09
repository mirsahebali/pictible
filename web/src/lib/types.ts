type Player = {
	username: string;
	joined_at: string;
};

type Chat = {
	sent_by: string;
	sent_at: string;
	message: string;
};

type RoomData = {
	players: Player[];
	chat: Chat[];
};
