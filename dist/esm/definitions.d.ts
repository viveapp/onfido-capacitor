export interface OnfidoCapacitorPlugin {
    init(options: InitOptions): Promise<void>;
}
export interface InitOptions {
    SDKToken: string;
}
