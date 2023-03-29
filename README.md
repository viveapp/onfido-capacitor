# Onfido Capacitor Plugin

A capacitor based wrapper for Onfido mobile SDKs

## API

<docgen-index>

- [`start(...)`](#start)
- [Interfaces](#interfaces)
- [Type Aliases](#type-aliases)
- [Enums](#enums)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### start(...)

```typescript
start(options: OnfidoConfig) => Promise<OnfidoResult | OnfidoError>
```

| Param         | Type                                                  |
| ------------- | ----------------------------------------------------- |
| **`options`** | <code><a href="#onfidoconfig">OnfidoConfig</a></code> |

**Returns:** <code>Promise&lt;<a href="#onfidoresult">OnfidoResult</a> | <a href="#onfidoerror">OnfidoError</a>&gt;</code>

---

### Interfaces

#### OnfidoError

| Prop       | Type                |
| ---------- | ------------------- |
| **`code`** | <code>string</code> |

### Type Aliases

#### OnfidoResult

<code>{ document?: { front: { id: string; }; back?: { id: string; }; nfcMediaId?: { id: string; }; }; face?: { id: string; variant: <a href="#onfidocapturetype">OnfidoCaptureType</a>; }; }</code>

#### OnfidoConfig

<code>{ sdkToken: string; workflowRunId?: string; flowSteps: <a href="#onfidoflowsteps">OnfidoFlowSteps</a>; hideLogo?: boolean; logoCoBrand?: boolean; enableNFC?: boolean; localisation?: { ios_strings_file_name?: string; }; }</code>

#### OnfidoFlowSteps

<code>{ welcome?: boolean; captureDocument?: { countryCode?: string; alpha2CountryCode?: string; docType?: <a href="#onfidodocumenttype">OnfidoDocumentType</a>; }; captureFace?: { type: <a href="#onfidocapturetype">OnfidoCaptureType</a>; }; }</code>

### Enums

#### OnfidoCaptureType

| Members      | Value                 |
| ------------ | --------------------- |
| **`PHOTO`**  | <code>'PHOTO'</code>  |
| **`VIDEO`**  | <code>'VIDEO'</code>  |
| **`MOTION`** | <code>'MOTION'</code> |

#### OnfidoDocumentType

| Members                      | Value                                 |
| ---------------------------- | ------------------------------------- |
| **`PASSPORT`**               | <code>'PASSPORT'</code>               |
| **`DRIVING_LICENCE`**        | <code>'DRIVING_LICENCE'</code>        |
| **`NATIONAL_IDENTITY_CARD`** | <code>'NATIONAL_IDENTITY_CARD'</code> |
| **`RESIDENCE_PERMIT`**       | <code>'RESIDENCE_PERMIT'</code>       |
| **`VISA`**                   | <code>'VISA'</code>                   |
| **`WORK_PERMIT`**            | <code>'WORK_PERMIT'</code>            |
| **`GENERIC`**                | <code>'GENERIC'</code>                |

</docgen-api>
