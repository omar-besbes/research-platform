import Link from "next/link";
import Image from "next/image";
import { CloudUploadIcon, FolderIcon } from "@/assets";

export const ProjectCard = ({ project }: { project: Project }) => {
	return (
		<div className="bg-white shadow-lg rounded-lg w-72 h-52 m-3 flex flex-col">
			<div className="relative">
				{/* Background div */}
				<div
					className="rounded-t-lg absolute inset-0 bg-cover bg-center"
					style={{
						backgroundImage: `url(${project.image})`,
						opacity: 0.5,
					}}
				></div>

				{/* Title div */}
				<div className="relative p-3 opacity-100 flex flex-row justify-between text-black text-md font-bold">
					<div>{project.name}</div>
					<div className="font-black">...</div>
				</div>
			</div>

			<div className="mt-0 px-2 py-1 h-full flex flex-col justify-between">
				<p className="text-right" style={{ fontSize: "8px" }}>
					ID: {project.id}
				</p>
				<p className="p-2 text-sm">{project.description}</p>

				<div className="relative px-2 py-1 opacity-100 flex flex-row justify-between text-black text-md font-bold">
					<div className="flex items-center justify-center">
						<div className="flex items-center justify-center">
							{project.usersImages.map((url, index) => (
								<div
									key={index}
									className="w-8 h-8 -ml-2 rounded-full overflow-hidden border-2 border-white"
								>
									<Image
										src={url}
										height={50}
										width={50}
										className="w-full h-full object-cover"
										alt={"Member 1"}
									/>
								</div>
							))}
						</div>
					</div>
					<div className="flex flex-col">
						<div className="flex flex-row justify-end">
							{project.tags.slice(0, 3).map((tag) => (
								<div className="bg-gray-200 rounded-lg p-1 font-semibold text-sm m-1">
									{tag}
								</div>
							))}
						</div>
						<div className="flex flex-row">
							<div className="p-1 flex flex-row justify-center items-center font-normal" style={{ fontSize: "12px" }}>
								<CloudUploadIcon className="h-4 w-4 mr-1" />
								{project.size}
							</div>
							<div className="p-1 flex flex-row justify-center items-center font-normal" style={{ fontSize: "12px" }}>
								<FolderIcon className="h-3 w-3 mr-1" />
								{project.numFolders} {" fichiers"}
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	);
};

export interface Project {
	id: number;
	name: string;
	description: string;
	image: string;
	tags: string[];
	usersImages: string[];
	size: string;
	numFolders: number;
}
