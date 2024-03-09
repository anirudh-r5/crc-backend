export interface marshallOptions {
  convertEmptyValues?: boolean;
  removeUndefinedValues?: boolean;
  convertClassInstanceToMap?: boolean;
  convertTopLevelContainer?: boolean;
}

export interface unmarshallOptions {
  wrapNumbers?: boolean;
  convertWithoutMapWrapper?: boolean;
}
