package com.viveapp.onfido.capacitor

import android.content.Intent
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import com.onfido.android.sdk.capture.ExitCode
import com.onfido.android.sdk.capture.Onfido
import com.onfido.android.sdk.capture.OnfidoConfig
import com.onfido.android.sdk.capture.OnfidoFactory
import com.onfido.android.sdk.capture.errors.OnfidoException
import com.onfido.android.sdk.capture.upload.Captures


enum class Errors {
  SDKTokenEmpty,
}

@CapacitorPlugin(name = "OnfidoPlugin")
class OnfidoPlugin : Plugin() {
  companion object {
    private const val ONFIDO_FLOW_REQUEST_CODE = 100
  }

  @PluginMethod(returnType = PluginMethod.RETURN_PROMISE)
  fun init(call: PluginCall) {
    val sdkToken = call.getString("SDKToken")
    if (sdkToken.isNullOrBlank()) {
      call.reject("${Errors.SDKTokenEmpty}")
      return
    }

    val config = OnfidoConfig.Builder(context).withSDKToken(sdkToken)
    val helper = OnfidoHelper()

    val documentTypes = helper.documentTypes(call.getArray("allowedDocumentTypes"))
    if (documentTypes != null) {
      config.withAllowedDocumentTypes(documentTypes)
    }

    val onfido = OnfidoFactory.create(context).client

    onfido.startActivityForResult(this.activity, ONFIDO_FLOW_REQUEST_CODE, config.build())

    onfido.handleActivityResult(ONFIDO_FLOW_REQUEST_CODE, null, object : Onfido.OnfidoResultListener {
      override fun userCompleted(captures: Captures) {
        TODO("Not yet implemented")
      }

      override fun userExited(exitCode: ExitCode) {
        TODO("Not yet implemented")
      }

      override fun onError(exception: OnfidoException) {
        TODO("Not yet implemented")
      }
    })
  }


}