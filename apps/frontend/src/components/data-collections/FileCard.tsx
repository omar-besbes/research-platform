import Image from 'next/image';
import Link from 'next/link';

import { File } from '@/types/entities';

export const FileCard = ({ file }: { file: File }) => {
	// TODO: this check needs to be revised
	const isVideo = file.name.endsWith('.mp4');

	const Content = () => (
		<>
			<div className="text-lg text-center font-semibold m-2">{file.name}</div>

			<div className="w-full px-3 pt-2">
				<Image
					src="/welcome-image.png"
					height={100}
					width={100}
					className="w-full rounded-lg object-cover"
					alt={file.name}
				/>
			</div>
		</>
	);

	return isVideo ? (
		<Link
			className="bg-white shadow-lg rounded-lg w-42 h-32 m-3 flex flex-col"
			href={`/platform/video-operations/${file.id}`}
		>
			<Content />
		</Link>
	) : (
		<div className="bg-white shadow-lg rounded-lg w-42 h-32 m-3 flex flex-col">
			<Content />
		</div>
	);
};
