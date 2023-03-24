package com.viveapp.onfido.capacitor

import com.getcapacitor.JSArray
import com.onfido.android.sdk.capture.DocumentType

class OnfidoHelper {
  fun documentTypes(list: JSArray?): List<DocumentType>? {
    if (list == null) {
      return null
    }

    return emptyList()
  }
}