import {
  IsNumberString,
  IsString,
  MaxLength,
  MinLength,
  IsEnum,
  IsNotEmpty,
  IsEmail,
  IsOptional,
  IsBooleanString,
} from 'class-validator';

export class CreateJobDto {
  @IsString()
  @MinLength(5)
  @MaxLength(20)
  job_name: string;

  @IsEmail()
  @IsOptional()
  email: string;

  @IsBooleanString()
  useTest: string;

  @IsNumberString()
  marker_name: string;

  @IsNumberString()
  chr: string;

  @IsNumberString()
  pos: string;

  @IsNumberString()
  ref: string;

  @IsNumberString()
  alt: string;

  @IsNumberString()
  zscore: string;

  @IsNumberString()
  @IsOptional()
  af: string;

  @IsBooleanString()
  af_available: string;

  @IsOptional()
  @IsNumberString()
  ASW?: string;

  @IsOptional()
  @IsNumberString()
  CEU?: string;

  @IsOptional()
  @IsNumberString()
  CHB?: string;

  @IsOptional()
  @IsNumberString()
  CHS?: string;

  @IsOptional()
  @IsNumberString()
  CLM?: string;

  @IsOptional()
  @IsNumberString()
  FIN?: string;

  @IsOptional()
  @IsNumberString()
  GBR?: string;

  @IsOptional()
  @IsNumberString()
  IBS?: string;

  @IsOptional()
  @IsNumberString()
  JPT?: string;

  @IsOptional()
  @IsNumberString()
  LWK?: string;

  @IsOptional()
  @IsNumberString()
  MXL?: string;

  @IsOptional()
  @IsNumberString()
  PUR?: string;

  @IsOptional()
  @IsNumberString()
  TSI?: string;

  @IsOptional()
  @IsNumberString()
  YRI?: string;

  @IsString()
  chromosome: string;

  @IsNumberString()
  windowSize: string;

  @IsNumberString()
  wingSize: string;
}
