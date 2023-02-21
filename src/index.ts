import {registerPlugin} from '@capacitor/core';

import type {CapacitorPluginAiTextRecognitionPlugin} from './definitions';

const CapacitorPluginAiTextRecognition = registerPlugin<CapacitorPluginAiTextRecognitionPlugin>(
    'CapacitorPluginAiTextRecognition', {
      web: () => import('./web')
          .then(m => new m.CapacitorPluginAiTextRecognitionWeb()),
    });

export * from './definitions';
export {CapacitorPluginAiTextRecognition};
