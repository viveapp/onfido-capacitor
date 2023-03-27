import { registerPlugin } from '@capacitor/core';

import type { OnfidoCapacitorPlugin } from './definitions';

const OnfidoCapacitor = registerPlugin<OnfidoCapacitorPlugin>('OnfidoPlugin');

export * from './definitions';
export { OnfidoCapacitor };
