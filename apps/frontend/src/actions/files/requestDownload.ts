'use server';

import { endpoints } from '@/constants';
import { File } from '@/types/entities';
import { fetcher } from '@/utils/fetcher';

type RequestDownload = Pick<File, 'id'>;

export async function requestDownload(data: RequestDownload) {
	return fetcher<{ url: string; jwt: string; fileName: string }>(
		endpoints.files.requestDownload(data.id),
		{
			method: 'GET',
		}
	);
}
