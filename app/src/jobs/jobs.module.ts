import { Global, Module } from '@nestjs/common';
import { JobsImputationService } from './services/jobs.imputation.service';
import { JobsImputationController } from './controllers/jobs.imputation.controller';
import { QueueModule } from '../jobqueue/queue.module';
import { JobsImputationNoAuthController } from './controllers/jobs.imputation.noauth.controller';

@Global()
@Module({
  imports: [QueueModule],
  controllers: [JobsImputationController, JobsImputationNoAuthController],
  providers: [JobsImputationService],
  exports: [],
})
export class JobsModule {}
