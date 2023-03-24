import { registerPlugin } from '@capacitor/core';

import type { OnfidoCapacitorPlugin } from './definitions';

const OnfidoCapacitor = registerPlugin<OnfidoCapacitorPlugin>('OnfidoPlugin', {
  // web: () => import('./web').then(m => new m.OnfidoPluginWeb()),
});

export * from './definitions';
export { OnfidoCapacitorPlugin };
