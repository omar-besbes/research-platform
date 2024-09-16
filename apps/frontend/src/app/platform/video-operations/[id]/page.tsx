'use client';

import dynamic from 'next/dynamic';
import { PageProps } from '@/types/page-props';

const SelectFile = dynamic(
	() =>
		import('../../../../components/ffmpeg/SelectFile').then(
			(module) => module.SelectFile
		),
	{ ssr: false }
);
const Crop = dynamic(
	() =>
		import('../../../../components/ffmpeg/Crop').then((module) => module.Crop),
	{ ssr: false }
);
const Render = dynamic(
	() =>
		import('../../../../components/ffmpeg/Render').then(
			(module) => module.Render
		),
	{ ssr: false }
);

export default function VideoOperations({ params }: PageProps) {
	const fileId = Array.isArray(params?.id) ? params?.id.at(0) : params?.id;

	if (!fileId)
		return (
			<div className="flex flex-grow bg-[#ededed]">No fileId provided</div>
		);

	return (
		<div className="flex flex-col flex-grow bg-[#ededed]">
			<SelectFile id={fileId} />
			<Crop />
			<Render />
		</div>
	);
}
