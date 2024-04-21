import { Column, Entity, Index, ManyToOne, RelationId } from 'typeorm';
import { Base } from '@common/base.entity';
import { User } from '@user/user.entity';

@Entity()
@Index(['user', 'subjectId', 'action'], { unique: true })
export class Permission extends Base {
  @Column({ type: 'varchar' })
  action: string;

  @Column({ type: 'uuid' })
  subjectId: string;

  @Index()
  @ManyToOne(() => User, { nullable: false })
  user: User;

  @RelationId((permission: Permission) => permission.user)
  userId: string;
}
