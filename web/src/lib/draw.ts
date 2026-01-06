const NORMAL_PRECISION = 1000;

export type Vec2 = [number, number];

export const toCanvasPos = ([x, y]: Vec2, [width, height]: Vec2): Vec2 => [
	(x * width) / NORMAL_PRECISION,
	(y * height) / NORMAL_PRECISION
];

export const normalizePos = ([x, y]: Vec2, [width, height]: Vec2): Vec2 => [
	Math.floor((x / width) * NORMAL_PRECISION),
	Math.floor((y / height) * NORMAL_PRECISION)
];
export const draw = (
	ctx: CanvasRenderingContext2D,
	x: number,
	y: number,
	hex: string,
	drawStrokeWidth: number
) => {
	ctx.strokeStyle = hex;
	ctx.lineWidth = drawStrokeWidth < 2 ? 2 : drawStrokeWidth;
	ctx.lineCap = 'round';
	ctx.lineTo(x, y);
	ctx.stroke();
};

export const erase = (
	ctx: CanvasRenderingContext2D,
	x: number,
	y: number,
	eraseStrokeWidth: number
) => {
	ctx.strokeStyle = '#FFFFFF';
	ctx.lineWidth = eraseStrokeWidth < 2 ? 2 : eraseStrokeWidth;
	ctx.lineCap = 'round';
	ctx.lineTo(x, y);
	ctx.stroke();
};
