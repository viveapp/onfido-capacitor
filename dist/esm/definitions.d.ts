import { OnfidoConfig, OnfidoError, OnfidoResult } from './models';
export interface OnfidoCapacitorPlugin {
    start(options: OnfidoConfig): Promise<OnfidoResult | OnfidoError>;
}
