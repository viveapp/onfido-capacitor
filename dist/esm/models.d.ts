export declare type OnfidoConfig = {
    sdkToken: string;
    workflowRunId?: string;
    flowSteps: OnfidoFlowSteps;
    hideLogo?: boolean;
    logoCoBrand?: boolean;
    enableNFC?: boolean;
    localisation?: {
        ios_strings_file_name?: string;
    };
};
export declare type OnfidoFlowSteps = {
    welcome?: boolean;
    captureDocument?: {
        countryCode?: string;
        alpha2CountryCode?: string;
        docType?: OnfidoDocumentType;
    };
    captureFace?: {
        type: OnfidoCaptureType;
    };
};
export declare type OnfidoResult = {
    document?: {
        front: {
            id: string;
        };
        back?: {
            id: string;
        };
        nfcMediaId?: {
            id: string;
        };
    };
    face?: {
        id: string;
        variant: OnfidoCaptureType;
    };
};
export interface OnfidoError extends Error {
    code?: string;
}
export declare enum OnfidoDocumentType {
    PASSPORT = "PASSPORT",
    DRIVING_LICENCE = "DRIVING_LICENCE",
    NATIONAL_IDENTITY_CARD = "NATIONAL_IDENTITY_CARD",
    RESIDENCE_PERMIT = "RESIDENCE_PERMIT",
    VISA = "VISA",
    WORK_PERMIT = "WORK_PERMIT",
    GENERIC = "GENERIC"
}
export declare enum OnfidoCaptureType {
    PHOTO = "PHOTO",
    VIDEO = "VIDEO",
    MOTION = "MOTION"
}
