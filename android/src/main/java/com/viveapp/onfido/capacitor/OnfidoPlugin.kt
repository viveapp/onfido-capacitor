package com.viveapp.onfido.capacitor

import android.content.Intent
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import com.onfido.android.sdk.capture.*
import com.onfido.android.sdk.capture.errors.EnterpriseFeatureNotEnabledException
import com.onfido.android.sdk.capture.errors.EnterpriseFeaturesInvalidLogoCobrandingException
import com.onfido.android.sdk.capture.errors.OnfidoException
import com.onfido.android.sdk.capture.ui.camera.face.stepbuilder.FaceCaptureStepBuilder
import com.onfido.android.sdk.capture.ui.options.CaptureScreenStep
import com.onfido.android.sdk.capture.ui.options.FlowStep
import com.onfido.android.sdk.capture.upload.Captures
import com.onfido.android.sdk.capture.utils.CountryCode
import com.onfido.workflow.OnfidoWorkflow
import com.onfido.workflow.WorkflowConfig

@CapacitorPlugin(
    name = "OnfidoPlugin",
    requestCodes = [OnfidoPlugin.CHECKS_ACTIVITY_CODE, OnfidoPlugin.WORKFLOW_ACTIVITY_CODE]
)
class OnfidoPlugin : Plugin() {
    private var currentCall: PluginCall? = null
    private var workflow: OnfidoWorkflow? = null

    private val client: Onfido = OnfidoFactory.create(context).client

    private fun setCall(call: PluginCall) {
        this.currentCall?.reject(
            "error", Exception("New activity was started before old promise was resolved.")
        )
        this.currentCall = call
    }

    @PluginMethod(returnType = PluginMethod.RETURN_PROMISE)
    fun start(call: PluginCall) {
        setCall(call)

        try {
            val sdkToken = call.getString("sdkToken")
            if (sdkToken.isNullOrBlank()) {
                return call.reject("sdkToken not provided")
            }

            try {
                val workflowRunId = call.getString("workflowRunId")
                if (workflowRunId.isNullOrBlank()) {
                    defaultSdkConfiguration(sdkToken, call.data)
                } else {
                    workflowSdkConfiguration(sdkToken, workflowRunId, call.data)
                }
            } catch (e: EnterpriseFeaturesInvalidLogoCobrandingException) {
                call.reject("error", EnterpriseFeaturesInvalidLogoCobrandingException())
                currentCall = null
            } catch (e: EnterpriseFeatureNotEnabledException) {
                call.reject("error", EnterpriseFeatureNotEnabledException("logoCobrand"))
                currentCall = null
            } catch (e: Exception) {
                call.reject("error", Exception(e.message, e))
                currentCall = null
            }
        } catch (e: Exception) {
            e.printStackTrace()
            call.reject("error", e)
            currentCall = null
        }
    }

    private fun defaultSdkConfiguration(sdkToken: String, config: JSObject) {
        val flowStepsWithOptions = getFlowStepsFromConfig(config)

        val onfidoConfigBuilder = OnfidoConfig.Builder(activity)
            .withSDKToken(sdkToken)
            .withCustomFlow(flowStepsWithOptions)

        val enterpriseFeaturesBuilder = getEnterpriseFeatures(config)
        enterpriseFeaturesBuilder?.let {
            onfidoConfigBuilder.withEnterpriseFeatures(it.build())
        }

        if (config.getBoolean("enableNFC")) {
            onfidoConfigBuilder.withNFCReadFeature()
        }

        client.startActivityForResult(activity, CHECKS_ACTIVITY_CODE, onfidoConfigBuilder.build())
    }

    private fun workflowSdkConfiguration(
        sdkToken: String, workflowRunId: String, config: JSObject
    ) {
        val flow = OnfidoWorkflow.create(activity)
        val onfidoConfigBuilder = WorkflowConfig.Builder(sdkToken, workflowRunId)
        val enterpriseFeaturesBuilder = getEnterpriseFeatures(config)

        enterpriseFeaturesBuilder?.let {
            onfidoConfigBuilder.withEnterpriseFeatures(it.build())
        }

        flow.startActivityForResult(activity, WORKFLOW_ACTIVITY_CODE, onfidoConfigBuilder.build())
    }

    private fun getEnterpriseFeatures(config: JSObject): EnterpriseFeatures.Builder? {
        val enterpriseFeaturesBuilder = EnterpriseFeatures.Builder()
        var hasSetEnterpriseFeatures = false

        if (config.getBoolean("hideLogo")) {
            enterpriseFeaturesBuilder.withHideOnfidoLogo((true))
            hasSetEnterpriseFeatures = true
        } else if (config.getBoolean("logoCobrand")) {
            val cobrandLogoLight = activity.applicationContext.resources.getIdentifier(
                "cobrand_logo_light", "drawable", activity.applicationContext.packageName
            )
            val cobrandLogoDark = activity.applicationContext.resources.getIdentifier(
                "cobrand_logo_dark", "drawable", activity.applicationContext.packageName
            )
            if (cobrandLogoLight == 0 || cobrandLogoDark == 0) {
                currentCall?.reject("Cobrand logos not found")
                currentCall = null
                return null
            }
            enterpriseFeaturesBuilder.withCobrandingLogo(cobrandLogoLight, cobrandLogoDark)
            hasSetEnterpriseFeatures = true
        }

        return if (hasSetEnterpriseFeatures) {
            enterpriseFeaturesBuilder
        } else {
            null
        }
    }

    @Deprecated("Deprecated in Java")
    override fun handleOnActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.handleOnActivityResult(requestCode, resultCode, data)

        when(requestCode) {
            CHECKS_ACTIVITY_CODE -> handleOnfidoChecks(resultCode, data)
            WORKFLOW_ACTIVITY_CODE -> handleOnfidoWorkflow(resultCode, data)
        }
    }

    private fun handleOnfidoChecks(resultCode: Int, data: Intent?) {
        client.handleActivityResult(resultCode, data, object : Onfido.OnfidoResultListener {
            override fun userCompleted(captures: Captures) {
                currentCall?.let {
                    var docFrontId: String? = null
                    var docBackId: String? = null
                    var nfcMediaUUID: String? = null
                    var faceId: String? = null
                    var faceVariant: String? = null

                    captures.document?.let { document ->
                        document.front?.let {
                            docFrontId = it.id
                        }
                        document.back?.let {
                            docBackId = it.id
                        }
                        document.nfcMediaUUID?.let {
                            nfcMediaUUID = it
                        }
                    }

                    captures.face?.let {
                        faceId = it.id
                        faceVariant = it.variant.toString()
                    }

                    val response = Response(docFrontId, docBackId, nfcMediaUUID, faceId, faceVariant)
                    currentCall = try {
                        val jsObject = response.toJSObject()
                        currentCall?.resolve(jsObject)
                        null
                    } catch (e: Exception) {
                        currentCall?.reject("error", "Error serializing response", e)
                        null
                    }
                }
            }

            override fun userExited(exitCode: ExitCode) {
                currentCall?.reject(exitCode.toString(), Exception("User exited manually"))
                currentCall = null
            }

            override fun onError(exception: OnfidoException) {
                currentCall?.reject("error", exception)
                currentCall = null
            }
        })
    }

    private fun handleOnfidoWorkflow(resultCode: Int, data: Intent?) {
        val localWorkflow = workflow
        if(localWorkflow == null) {
            currentCall?.reject("Received workflow result but workflow is null")
            currentCall = null
            return
        }
        localWorkflow.handleActivityResult(resultCode, data, object : OnfidoWorkflow.ResultListener {
            override fun onUserCompleted() {
                currentCall?.resolve()
                currentCall = null
            }

            override fun onUserExited(exitCode: ExitCode) {
                currentCall?.reject(exitCode.toString(), Exception("User exited manually"))
                currentCall = null
            }

            override fun onException(exception: OnfidoWorkflow.WorkflowException) {
                currentCall?.reject("error", exception)
                currentCall = null
            }
        })
    }

    companion object {
        const val WORKFLOW_ACTIVITY_CODE = 102030
        const val CHECKS_ACTIVITY_CODE = 102040

        fun getFlowStepsFromConfig(config: JSObject): Array<FlowStep> {
            try {
                val flowSteps =
                    config.getJSObject("flowSteps") ?: throw Exception("flowSteps not provided")

                val welcomePageIsIncluded = if (flowSteps.has("welcome")) {
                    flowSteps.getBoolean("welcome")
                } else {
                    false
                }

                val captureDocument = flowSteps.getJSObject("captureDocument")

                val flowStepList = mutableListOf<FlowStep>()
                if (welcomePageIsIncluded) {
                    flowStepList.add(FlowStep.WELCOME)
                }

                if (captureDocument != null) {
                    val docTypeExists = captureDocument.has("docType")
                    val countryCodeExists = captureDocument.has("alpha2CountryCode")
                    if (docTypeExists && countryCodeExists) {
                        val docTypeString = captureDocument.getString("docType")!!

                        val docTypeEnum = try {
                            DocumentType.valueOf(docTypeString)
                        } catch (e: IllegalArgumentException) {
                            System.err.println("Unexpected docType value: [$docTypeString]")
                            throw Exception("Unexpected docType value.")
                        }

                        val countryCodeString = captureDocument.getString("alpha2CountryCode")!!
                        val countryCodeEnum = findCountryCodeByAlpha2(countryCodeString)
                        if (countryCodeEnum == null) {
                            System.err.println("Unexpected countryCode value: [$countryCodeString]")
                            throw Exception("Unexpected countryCode value.")
                        }

                        flowStepList.add(CaptureScreenStep(docTypeEnum, countryCodeEnum))
                    } else if (!docTypeExists && !countryCodeExists) {
                        flowStepList.add(FlowStep.CAPTURE_DOCUMENT)
                    } else {
                        throw Exception("countryCode and docType must both be provided or both be omitted")
                    }
                }

                val captureFaceExists = flowSteps.has("captureFace")
                val captureFace = if (captureFaceExists) {
                    flowSteps.getJSObject("captureFace")
                } else {
                    null
                }

                captureFace?.let {
                    val captureFaceTypeExists = it.has("type")
                    if (captureFaceTypeExists) {
                        when (it.getString("type")!!) {
                            "PHOTO" -> flowStepList.add(FaceCaptureStepBuilder.forPhoto().build())
                            "VIDEO" -> flowStepList.add(FaceCaptureStepBuilder.forVideo().build())
                            "MOTION" -> flowStepList.add(FaceCaptureStepBuilder.forMotion().build())
                            else -> throw Exception("Invalid face capture type.  \"type\" must be VIDEO, PHOTO or MOTION.")
                        }
                    } else {
                        flowStepList.add(FaceCaptureStepBuilder.forPhoto().build())
                    }
                }

                return flowStepList.toTypedArray()
            } catch (e: Exception) {
                e.printStackTrace()
                throw Exception("Error parsing flowSteps", e)
            }
        }

        private fun findCountryCodeByAlpha2(countryCodeString: String): CountryCode? {
            return try {
                CountryCode.values().first { it.name == countryCodeString }
            } catch (e: NoSuchElementException) {
                null
            }
        }
    }
}