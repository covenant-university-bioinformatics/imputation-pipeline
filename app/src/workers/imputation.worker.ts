import { SandboxedJob } from 'bullmq';
import * as fs from 'fs';
import {
  ImputationJobsModel,
  JobStatus,
} from '../jobs/models/imputation.jobs.model';
import {
  ImputationDoc,
  ImputationModel,
} from '../jobs/models/imputation.model';
import appConfig from '../config/app.config';
import { spawnSync } from 'child_process';
import connectDB, { closeDB } from '../mongoose';
import {
  deleteFileorFolder,
  fileOrPathExists,
  writeImputeFile,
} from '@cubrepgwas/pgwascommon';

function sleep(ms) {
  console.log('sleeping');
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function getJobParameters(parameters: ImputationDoc) {
  if (parameters.af_available) {
    return [
      String(parameters.af_available),
      String(parameters.chromosome),
      String(parameters.windowSize),
      String(parameters.wingSize),
    ];
  } else {
    return [
      String(parameters.af_available),
      String(parameters.ASW),
      String(parameters.CEU),
      String(parameters.CHB),
      String(parameters.CHS),
      String(parameters.CLM),
      String(parameters.FIN),
      String(parameters.GBR),
      String(parameters.IBS),
      String(parameters.JPT),
      String(parameters.LWK),
      String(parameters.MXL),
      String(parameters.PUR),
      String(parameters.TSI),
      String(parameters.YRI),
      String(parameters.chromosome),
      String(parameters.windowSize),
      String(parameters.wingSize),
    ];
  }
}

export default async (job: SandboxedJob) => {
  //executed for each job
  console.log(
    'Worker ' +
      ' processing job ' +
      JSON.stringify(job.data.jobId) +
      ' Job name: ' +
      JSON.stringify(job.data.jobName),
  );

  await connectDB();
  await sleep(2000);

  //fetch job parameters from database
  const parameters = await ImputationModel.findOne({
    job: job.data.jobId,
  }).exec();

  const jobParams = await ImputationJobsModel.findById(job.data.jobId).exec();

  //create input file and folder
  let filename;

  //extract file name
  const name = jobParams.inputFile.split(/(\\|\/)/g).pop();

  if (parameters.useTest === false) {
    filename = `/pv/analysis/${jobParams.jobUID}/input/${name}`;
  } else {
    filename = `/pv/analysis/${jobParams.jobUID}/input/test.txt`;
  }

  console.log(filename);
  console.log(name);

  //write the exact columns needed by the analysis
  writeImputeFile(jobParams.inputFile, filename, {
    marker_name: parameters.marker_name - 1,
    chr: parameters.chr - 1,
    pos: parameters.pos - 1,
    effect_allele: parameters.ref - 1,
    alternate_allele: parameters.alt - 1,
    zscore: parameters.zscore - 1,
    af: parameters.af ? parameters.af - 1 : null,
  });

  if (parameters.useTest === false) {
    deleteFileorFolder(jobParams.inputFile).then(() => {
      console.log('deleted');
    });
  }

  //assemble job parameters
  const pathToInputFile = filename;
  const pathToOutputDir = `/pv/analysis/${job.data.jobUID}/${appConfig.appName}/output`;
  const jobParameters = getJobParameters(parameters);
  jobParameters.unshift(pathToInputFile, pathToOutputDir);

  console.log(jobParameters);
  //make output directory
  fs.mkdirSync(pathToOutputDir, { recursive: true });

  // save in mongo database
  await ImputationJobsModel.findByIdAndUpdate(
    job.data.jobId,
    {
      status: JobStatus.RUNNING,
      inputFile: filename,
    },
    { new: true },
  );

  await sleep(3000);
  //spawn process
  const jobSpawn = spawnSync(
    // './pipeline_scripts/pascal.sh &>/dev/null',
    './pipeline_scripts/distmix_v1.sh',
    jobParameters,
    { maxBuffer: 1024 * 1024 * 1024 },
  );

  console.log('Spawn command log');
  console.log(jobSpawn?.stdout?.toString());
  console.log('=====================================');
  console.log('Spawn error log');
  const error_msg = jobSpawn?.stderr?.toString();
  console.log(error_msg);

  let imputationFile: boolean;
  let plotsFile: boolean;

  imputationFile = await fileOrPathExists(`${pathToOutputDir}/imputation.txt`);
  plotsFile = await fileOrPathExists(`${pathToOutputDir}/plot.png`);

  const answer = imputationFile && plotsFile;

  //close database connection
  closeDB();

  if (answer) {
    return true;
  } else {
    throw new Error(error_msg || 'Job failed to successfully complete');
  }

  return true;
};
