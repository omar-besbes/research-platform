import { getHref } from '@/utils/getHref';
import { join } from 'path';

export const files = {
	getChildren: (dataCollectionId: string) =>
		getHref(join('files', dataCollectionId), {}),
	getDirectChildrenAt: (
		dataCollectionId: string,
		searchParams: { path?: string }
	) =>
		getHref(join('files', dataCollectionId, 'direct-children'), searchParams),
	createFile: () => '/files/create',
	requestDownload: (fileId: string) =>
		getHref(join('files', fileId, 'request-download'), {}),
};
