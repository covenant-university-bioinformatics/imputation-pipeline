import * as mongoose from 'mongoose';

//Interface that describe the properties that are required to create a new job
interface ImputationAttrs {
  job: string;
  useTest: string;
  marker_name: string;
  chr: string;
  pos: string;
  ref: string;
  alt: string;
  zscore: string;
  af?: string;
  af_available: string;
  ASW?: string;
  CEU?: string;
  CHB?: string;
  CHS?: string;
  CLM?: string;
  FIN?: string;
  GBR?: string;
  IBS?: string;
  JPT?: string;
  LWK?: string;
  MXL?: string;
  PUR?: string;
  TSI?: string;
  YRI?: string;
  chromosome: string;
  windowSize: string;
  wingSize: string;
}

// An interface that describes the extra properties that a imputation model has
//collection level methods
interface ImputationModel extends mongoose.Model<ImputationDoc> {
  build(attrs: ImputationAttrs): ImputationDoc;
}

//An interface that describes a properties that a document has
export interface ImputationDoc extends mongoose.Document {
  id: string;
  version: number;
  useTest: boolean;
  marker_name: number;
  chr: number;
  pos: number;
  ref: number;
  alt: number;
  zscore: number;
  af?: number;
  af_available: boolean;
  ASW?: number;
  CEU?: number;
  CHB?: number;
  CHS?: number;
  CLM?: number;
  FIN?: number;
  GBR?: number;
  IBS?: number;
  JPT?: number;
  LWK?: number;
  MXL?: number;
  PUR?: number;
  TSI?: number;
  YRI?: number;
  chromosome: string;
  windowSize: number;
  wingSize: number;
}

const ImputationSchema = new mongoose.Schema<ImputationDoc, ImputationModel>(
  {
    useTest: {
      type: Boolean,
      trim: true,
    },
    marker_name: {
      type: Number,
      trim: true,
    },
    chr: {
      type: Number,
      trim: true,
      default: null,
    },
    pos: {
      type: Number,
      trim: true,
      default: null,
    },
    ref: {
      type: Number,
      trim: true,
    },
    alt: {
      type: Number,
      trim: true,
    },
    zscore: {
      type: Number,
      trim: true,
    },
    af: {
      type: Number,
      trim: true,
    },
    af_available: {
      type: Boolean,
      trim: true,
    },
    ASW: {
      type: Number,
      trim: true,
    },
    CEU: {
      type: Number,
      trim: true,
    },
    CHB: {
      type: Number,
      trim: true,
    },

    CHS: {
      type: Number,
      trim: true,
    },

    CLM: {
      type: Number,
      trim: true,
    },

    FIN: {
      type: Number,
      trim: true,
    },

    GBR: {
      type: Number,
      trim: true,
    },

    IBS: {
      type: Number,
      trim: true,
    },

    JPT: {
      type: Number,
      trim: true,
    },
    LWK: {
      type: Number,
      trim: true,
    },
    MXL: {
      type: Number,
      trim: true,
    },
    PUR: {
      type: Number,
      trim: true,
    },
    TSI: {
      type: Number,
      trim: true,
    },
    YRI: {
      type: Number,
      trim: true,
    },
    chromosome: {
      type: String,
      trim: true,
    },
    windowSize: {
      type: Number,
      trim: true,
    },
    wingSize: {
      type: Number,
      trim: true,
    },

    job: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'ImputationJob',
      required: true,
    },
    version: {
      type: Number,
    },
  },
  {
    timestamps: true,
    versionKey: 'version',
    toJSON: {
      transform(doc, ret) {
        ret.id = ret._id;
        // delete ret._id;
        // delete ret.__v;
      },
    },
  },
);

//increments version when document updates
ImputationSchema.set('versionKey', 'version');

//collection level methods
ImputationSchema.statics.build = (attrs: ImputationAttrs) => {
  return new ImputationModel(attrs);
};

//create mongoose model
const ImputationModel = mongoose.model<ImputationDoc, ImputationModel>(
  'Imputation',
  ImputationSchema,
  'imputations',
);

export { ImputationModel };
