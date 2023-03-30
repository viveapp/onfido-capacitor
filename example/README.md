# Onfido Capacitor Plugin Example

## Install

### iOS

```bash
npm install
npm run build && npx cap sync
cd ios && pod install && cd ../
npx cap open ios
```

### Android

```bash
npm install
npm run build && npx cap sync
npx cap open android
```

as you can see, two capacitor plugin's are installed of which one the `onfido-capacitor` plugin.

## Prerequisites

1. You need to have at least an Onfido `API Token` with which you can create all necessary other tokens and ID's
2. As well as a `workflow ID` if you whish to use the workflows provided by [Onfido Studio](https://onfido.com/solutions/studio/)

We can summarize the steps needed as follows:

1. create an applicant
2. create a SDK token
3. create a workflow run ID (optional)

## Postman Scripts

Included in this example project is a [Postman Collection](./Onfido.postman_collection.json) which is configured to set and get the necessary variables dynamically. You only need to set the `API_TOKEN` and `WORKFLOW_ID_FULL_IDENTIFICATION` or `WORKFLOW_ID_DOCUMENT_IDENTIFICATION` collection variables. Then simply execute the three post requests in this order;

1. Create Applicant
2. Create SDK Token
3. Create Workflow Run

If you don't use Postman, use below scripts to retrieve the necessary data manually

---

## Manual scripts

### Create an applicant

```bash
curl -X POST https://api.eu.onfido.com/v3.6/applicants/ \
  -H 'Authorization: Token token=<YOUR_API_TOKEN>' \
  -H 'Content-Type: application/json' \
  -d '{
  "first_name": "Jane",
  "last_name": "Doe",
  "dob": "1990-01-31",
  "address": {
    "building_number": "100",
    "street": "Main Street",
    "town": "London",
    "postcode": "SW4 6EH",
    "country": "GBR"
  }
}'
```

### Create SDK token for applicant

With the retrieved `applicant_id` you can now generate a `SDK token`

```bash
curl -X POST https://api.eu.onfido.com/v3.6/sdk_token \
  -H 'Authorization: Token token=<YOUR_API_TOKEN>' \
  -H 'Content-Type: application/json' \
  -d '{
     "applicant_id": "<APPLICANT_ID>",
     "application_id": "<APPLICATION_ID>" `# use * if no specific application ID is necessary
   }'
```

This will generate a `sdkToken` restricted to the applicant that is provided and will last 90 minutes

### Create a workflow run ID (optional)

If you whish to make use of a workflow configured in Onfido Studio, it is neccesary to have a workflow ID to create a workflow run ID that is coupled to the applicatant.

```bash
$ curl -X POST https://api.eu.onfido.com/v3.6/workflow_runs \
  -H 'Authorization: Token token=<YOUR_API_TOKEN>' \
  -H 'Content-Type: application/json' \
  -d '{
  "workflow_id": "<WORKFLOW_ID>",
  "applicant_id": "<APPLICANT_ID>"
}'
```

### integrate token (and workflow run ID)

Now we have the required `SDK token` (and optionally the `workflow run ID`), we can integrate both in our application
