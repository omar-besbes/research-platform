import { useQuery } from '@tanstack/react-query';
import { ffmpegStore } from '../../actions/ffmpeg/ffmpegStore';
import { endpoints } from '@/constants';
import { requestDownload } from '@/actions/files/requestDownload';
import { File as _File } from '@/types/entities';

export default function useDownloadFfmpeg(file: Pick<_File, 'id'>) {
	return useQuery({
		queryKey: ['file', 'download', file.id],
		queryFn: async () => {
			const {
				url: base,
				jwt,
				fileName,
			} = await requestDownload(file).then((res) => res.data);
			const url = new URL(endpoints.minioWrapper.download(), base).href;

			const socket = new WebSocket(url);

			return new Promise<null>((res, rej) => {
				socket.onopen = () => {
					socket.send(JSON.stringify({ token: jwt }));
				};

				socket.onmessage = async (event) => {
					const fileData = event.data;
					const file = new File([fileData], fileName, { type: 'video/mp4' });
					await ffmpegStore.loadVideo(file);
					res(null);
				};

				socket.onerror = (error) => {
					socket.close();
					rej(new Error('WebSocket error', { cause: error }));
				};

				socket.onclose = (event) => {
					rej(new Error('Connection closed', { cause: event.reason }));
				};
			});
		},
	});
}
