import { Inject, Module, OnModuleInit } from '@nestjs/common';
import { createWorkers } from '../workers/imputation.main';
import { ImputationJobQueue } from './queue/imputation.queue';
import { NatsModule } from '../nats/nats.module';
import { JobCompletedPublisher } from '../nats/publishers/job-completed-publisher';

@Module({
  imports: [NatsModule],
  providers: [ImputationJobQueue],
  exports: [ImputationJobQueue],
})
export class QueueModule implements OnModuleInit {
  @Inject(JobCompletedPublisher) jobCompletedPublisher: JobCompletedPublisher;
  async onModuleInit() {
    await createWorkers(this.jobCompletedPublisher);
  }
}
