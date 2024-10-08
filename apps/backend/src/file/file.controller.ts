import {
	Controller,
	Post,
	Body,
	ParseUUIDPipe,
	Get,
	Param,
	UseGuards,
	Query,
	DefaultValuePipe,
} from '@nestjs/common';
import { FileService } from './file.service';
import { CreateFileDto } from './dtos/create-file.dto';
import { DataCollection, User } from '@/database/entities';
import { RequirePermission } from '@/permission/require-permission.decorator';
import { JwtAuthGuard } from '@/auth/guards';
import { PermissionGuard } from '@/permission/permission.guard';
import { DataCollectionAction } from '@/data-collection/data-collection-action.enum';
import { ParsePathPipe } from '@/common/pipes/parse-path.pipe';
import { normalize } from 'path';
import { AuthenticatedUser } from '@/auth/decorators';

@Controller('files')
@UseGuards(JwtAuthGuard, PermissionGuard)
export class FileController {
	constructor(private readonly fileService: FileService) {}

	@Post('/create')
	async create(
		@Body() createFileDto: CreateFileDto,
		@Body('dataCollectionId', ParseUUIDPipe) dataCollectionId: string,
		@AuthenticatedUser() user: User
	) {
		const dataCollection = new DataCollection({ id: dataCollectionId });
		return this.fileService.createOne(createFileDto, dataCollection, user);
	}

	@Get(':id/request-download')
	@RequirePermission((req) => req.params.id, DataCollectionAction.read)
	async requestDownload(
		@Param('id', ParseUUIDPipe) id: string,
		@AuthenticatedUser() user: User
	) {
		return this.fileService.requestDownload(id, user);
	}

	@Get(':id')
	@RequirePermission((req) => req.params.id, DataCollectionAction.read)
	async findFilesByDataCollection(
		@Param('id', ParseUUIDPipe) dataCollectionId: string
	) {
		const dataCollection = new DataCollection({ id: dataCollectionId });
		return this.fileService.findFilesByDataCollection(dataCollection);
	}

	@Get(':id/direct-children')
	@RequirePermission((req) => req.params.id, DataCollectionAction.read)
	async findDirectFilesByDataCollection(
		@Param('id', ParseUUIDPipe) dataCollectionId: string,
		@Query('path', new DefaultValuePipe('/'), ParsePathPipe) path: string
	) {
		const dataCollection = new DataCollection({ id: dataCollectionId });
		return this.fileService.findDirectFilesByDataCollection(
			dataCollection,
			normalize(path.concat('/'))
		);
	}
}
