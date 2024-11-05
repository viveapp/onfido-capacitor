package com.viveapp.onfido.capacitor

import com.getcapacitor.JSObject

public class Response(
    frontId: String?,
    backId: String?,
    nfcMediaId: String?,
    faceId: String?,
    faceVariant: String?
) {
    private var document: Document?
    private var face: Face?

    init {
        document = initDocument(frontId, backId, nfcMediaId)
        face = initFace(faceId, faceVariant)
    }

    private fun initDocument(frontId: String?, backId: String?, nfcMediaId: String?): Document? {
        if (frontId != null || backId != null || nfcMediaId != null) {
            val document = Document()
            frontId?.let {
                document.front = Identifiable(it)
            }
            backId?.let {
                document.back = Identifiable(it)
            }
            nfcMediaId?.let {
                document.nfcMediaId = Identifiable(it)
            }
            return document
        }
        return null
    }

    private fun initFace(faceId: String?, faceVariant: String?): Face? {
        if (faceId != null && faceVariant != null) {
            return Face(faceId, faceVariant)
        }
        return null
    }

    fun toJSObject(): JSObject {
        val obj = JSObject()
        document?.let {
            if (it.front != null || it.back != null || it.nfcMediaId != null) {
                val doc = JSObject()
                it.front?.let { frontId ->
                    doc.put("front", JSObject().put("id", frontId))
                }
                it.back?.let { backId ->
                    doc.put("back", JSObject().put("id", backId))
                }
                it.nfcMediaId?.let { nfcMediaId ->
                    doc.put("nfcMediaId", JSObject().put("id", nfcMediaId))
                }
                obj.put("document", doc)
            }
        }
        face?.let {
            val face = JSObject()
            face.put("id", it.id)
            face.put("variant", it.variant)
            obj.put("face", face)
        }
        return obj
    }
}

open class Identifiable(var id: String = "default")
class Document {
    var front: Identifiable? = null
    var back: Identifiable? = null
    var nfcMediaId: Identifiable? = null
}

class Face(id: String, var variant: String) : Identifiable(id)