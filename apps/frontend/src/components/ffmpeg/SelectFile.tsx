'use client';

import React from 'react';
import { observer } from 'mobx-react-lite';
import useDownloadFfmpeg from '@/hooks/download/useDownloadFfmpeg';

export const SelectFile = observer(({ id }: { id: string }) => {
	const { isPending, isError, error } = useDownloadFfmpeg({ id });
	const errorMessage = (error?.cause ?? 'Incorrect fileId') as string;

	return (
		<div className="step">
			{isPending && (
				<div className="animate-spin rounded-full h-5 w-5 border-t-2 border-b-2 border-white mr-2" />
			)}
			{isError && <div>{errorMessage}</div>}
		</div>
	);
});
