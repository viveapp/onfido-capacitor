import { SplashScreen } from '@capacitor/splash-screen';
import 'onfido-capacitor';
import { OnfidoCapacitor } from 'onfido-capacitor';

// See readme for generation of both variables below
const SDK_TOKEN =
  'eyJhbGciOiJFUzUxMiJ9.eyJleHAiOjE2ODAxODQ4OTgsInBheWxvYWQiOnsiYXBwIjoiMDg2NDVkMmYtZjNmMS00M2Y0LWFhNTItYmEyOTk0OGI1ZWIxIiwiYXBwbGljYXRpb25faWQiOiIqIiwiY2xpZW50X3V1aWQiOiJmYTc2NTk0My0zNDZjLTQ0YzctYWY0OC00MmJkMTVlY2I1NzMiLCJpc19zYW5kYm94Ijp0cnVlLCJpc19zZWxmX3NlcnZpY2VfdHJpYWwiOmZhbHNlLCJpc190cmlhbCI6ZmFsc2UsInNhcmRpbmVfc2Vzc2lvbiI6IjIyMDU4YzAyLTA3ODUtNGU3MS05NWQ3LTVhNjcxZjM0ZmY2ZiJ9LCJ1dWlkIjoicGxhdGZvcm1fc3RhdGljX2FwaV90b2tlbl91dWlkIiwidXJscyI6eyJkZXRlY3RfZG9jdW1lbnRfdXJsIjoiaHR0cHM6Ly9zZGsub25maWRvLmNvbSIsInN5bmNfdXJsIjoiaHR0cHM6Ly9zeW5jLm9uZmlkby5jb20iLCJob3N0ZWRfc2RrX3VybCI6Imh0dHBzOi8vaWQub25maWRvLmNvbSIsImF1dGhfdXJsIjoiaHR0cHM6Ly9hcGkub25maWRvLmNvbSIsIm9uZmlkb19hcGlfdXJsIjoiaHR0cHM6Ly9hcGkub25maWRvLmNvbSIsInRlbGVwaG9ueV91cmwiOiJodHRwczovL2FwaS5vbmZpZG8uY29tIn19.MIGHAkIApxPnpAa_ly-UC_Espq86ASyCyHOKL5kpS2S5eqIBpPTtTFRRKAXnhaQYYNdAwoilWV1gVYBcK5CxxMnANZaewscCQX74XXA-KWRlKMyk-G5lCfHBXyTfZd3LfPxecO1mzYeS2Ny2P39BOWtVN10JB2y_PnMg_q4CW-EcpQH-2cm6MiL4';
const WORKFLOW_RUN_ID = 'd040cf0e-4869-48aa-926c-82935789879b';

window.customElements.define(
  'capacitor-welcome',
  class extends HTMLElement {
    constructor() {
      super();

      SplashScreen.hide();

      const root = this.attachShadow({ mode: 'open' });

      root.innerHTML = `
    <style>
      :host {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
        display: block;
        width: 100%;
        height: 100%;
      }
      h1, h2, h3, h4, h5 {
        text-transform: uppercase;
      }
      .button {
        display: inline-block;
        padding: 10px;
        background-color: #73B5F6;
        color: #fff;
        font-size: 0.9em;
        border: 0;
        border-radius: 3px;
        text-decoration: none;
        cursor: pointer;
      }
      main {
        padding: 15px;
      }
      main hr { height: 1px; background-color: #eee; border: 0; }
      main h1 {
        font-size: 1.4em;
        text-transform: uppercase;
        letter-spacing: 1px;
      }
      main h2 {
        font-size: 1.1em;
      }
      main h3 {
        font-size: 0.9em;
      }
      main p {
        color: #333;
      }
      main pre {
        white-space: pre-line;
      }
    </style>
    <div>
      <capacitor-welcome-titlebar>
        <h1>Capacitor</h1>
      </capacitor-welcome-titlebar>
      <main>
        <h2>Tiny Demo</h2>
        <p>
          This demo shows how to call the Onfido Capacitor plugin.
        </p>
        <p>
          <button class="button" id="take-photo">Start verification</button>
        </p>
        <p>
          <img id="image" style="max-width: 100%">
        </p>
      </main>
    </div>
    `;
    }

    connectedCallback() {
      const self = this;

      self.shadowRoot.querySelector('#take-photo').addEventListener('click', async function (e) {
        let onfidoConfig = {
          sdkToken: SDK_TOKEN,
          workflowRunId: WORKFLOW_RUN_ID,
        };
        try {
          OnfidoCapacitor.start(onfidoConfig);
        } catch (e) {
          console.warn('User cancelled', e);
        }
      });
    }
  }
);

window.customElements.define(
  'capacitor-welcome-titlebar',
  class extends HTMLElement {
    constructor() {
      super();
      const root = this.attachShadow({ mode: 'open' });
      root.innerHTML = `
    <style>
      :host {
        position: relative;
        display: block;
        padding: 15px 15px 15px 15px;
        text-align: center;
        background-color: #73B5F6;
      }
      ::slotted(h1) {
        margin: 0;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
        font-size: 0.9em;
        font-weight: 600;
        color: #fff;
      }
    </style>
    <slot></slot>
    `;
    }
  }
);
