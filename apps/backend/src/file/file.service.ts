import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataCollection, File } from '@/database/entities';
import { DataSource, Repository } from 'typeorm';
import { ElasticsearchService } from '@nestjs/elasticsearch';
import { MetadataIndex } from '@/metadata-engine/metadata-index.enum';
import { FileMetadata } from '@/metadata-engine/schemas';

@Injectable()
export class FileService {
	constructor(
		@InjectRepository(File) private readonly repository: Repository<File>,
		private readonly elasticsearchService: ElasticsearchService,
		private readonly dataSource: DataSource
	) {}

	async createOne(values: Partial<File>, dataCollection: DataCollection) {
		const file = new File({ ...values, dataCollection: dataCollection });
		return this.repository.save(file);
	}

	async rollbackUpload(file: File) {
		return this.repository.delete(file.id);
	}

	async commitUpload(file: File) {
		const queryRunner = this.dataSource.createQueryRunner();

		await queryRunner.connect();
		await queryRunner.startTransaction();
		try {
			const result = await queryRunner.manager
				.createQueryBuilder()
				.update(File)
				.set(file)
				.where('id = :id', { id: file.id })
				.returning('*')
				.execute()
				.then((res) => res.raw[0]);
			await this.elasticsearchService.index({
				index: MetadataIndex.files,
				document: new FileMetadata(result),
			});

			await queryRunner.commitTransaction();
		} catch (error) {
			await queryRunner.rollbackTransaction();
			throw new InternalServerErrorException(error);
		} finally {
			await queryRunner.release();
		}
	}
}
