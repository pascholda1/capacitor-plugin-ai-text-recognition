import {WebPlugin} from '@capacitor/core';

import type {
  CapacitorPluginAiTextRecognitionPlugin,
  DetectImageOptions,
  TextDetectionResult,
} from './definitions';

export class CapacitorPluginAiTextRecognitionWeb extends WebPlugin implements CapacitorPluginAiTextRecognitionPlugin {
  // @ts-ignore
  detectText(options: DetectImageOptions): Promise<TextDetectionResult> {
    return Promise.reject('Web Plugin Not implemented');
  }
}
