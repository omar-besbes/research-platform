import Image from 'next/image';
import { CloudUploadIcon, FolderIcon } from '@/assets';
import { DataCollection } from '@/types/entities';
import Link from 'next/link';

function truncateText(text: string) {
	const truncated = text.substring(0, 70) + '...';
	return truncated;
}

export const DataCollectionCard = ({
	dataCollection,
}: {
	dataCollection: DataCollection;
}) => {
	return (
		<Link
			href={`/platform/data-collections/${dataCollection.id}`}
			className="bg-white shadow-lg rounded-lg w-72 h-52 m-3 flex flex-col"
		>
			<div className="relative">
				{/* Background div */}
				<div
					className="rounded-t-lg absolute inset-0 bg-cover bg-center"
					style={{
						backgroundImage: `url(${dataCollection.imageUrl})`,
						opacity: 0.5,
					}}
				></div>

				{/* Title div */}
				<div className="relative p-3 opacity-100 flex flex-row justify-between text-black text-md font-bold">
					<div>{dataCollection.name}</div>
				</div>

				{/* Dots of options */}
				<div className="absolute top-0 right-3 font-black">...</div>
			</div>

			<div className="mt-0 px-2 py-1 h-full flex flex-col justify-between">
				<p className="text-right" style={{ fontSize: '8px' }}>
					ID: {dataCollection.id}
				</p>
				<p className="p-2 text-sm h-full max-w-full">
					{truncateText(dataCollection.description)}
				</p>

				<div className="relative px-2 py-1 opacity-100 flex flex-row justify-between text-black text-md font-bold">
					<div className="flex items-center justify-center">
						<div className="flex items-center justify-center">
							{['/jeff.jpg', '/jeff.jpg', '/jeff.jpg'].map((url, index) => (
								<div
									key={index}
									className="w-8 h-8 -ml-2 rounded-full overflow-hidden border-2 border-white"
								>
									<Image
										src={url}
										height={50}
										width={50}
										className="w-full h-full object-cover"
										alt={'Member 1'}
									/>
								</div>
							))}
						</div>
					</div>
					<div className="flex flex-col">
						<div className="flex flex-row justify-end">
							{dataCollection.tags.slice(0, 3).map((tag, index) => (
								<div
									key={index}
									className="bg-gray-200 rounded-lg p-1 font-semibold text-sm m-1"
								>
									{tag}
								</div>
							))}
						</div>
						<div className="flex flex-row">
							<div
								className="p-1 flex flex-row justify-center items-center font-normal"
								style={{ fontSize: '12px' }}
							>
								<CloudUploadIcon className="h-4 w-4 mr-1" />
								3.5 GB
							</div>
							<div
								className="p-1 flex flex-row justify-center items-center font-normal"
								style={{ fontSize: '12px' }}
							>
								<FolderIcon className="h-3 w-3 mr-1" />
								{12} {' fichiers'}
							</div>
						</div>
					</div>
				</div>
			</div>
		</Link>
	);
};
