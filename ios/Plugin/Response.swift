//
//  Response.swift
//  Plugin
//
//  Created by Polo Swelsen on 28/03/2023.
//  Copyright © 2023 ilionx B.V. All rights reserved.
//

import Foundation
import Onfido

// 📝 Protocols are for testing purposes since SDK types are final
protocol CapacitorDocumentSideResult {
    var id: String { get }
}

protocol CapacitorDocumentResult {
    var capacitorFront: CapacitorDocumentSideResult { get }
    var capacitorBack: CapacitorDocumentSideResult? { get }
    var capacitorNfcMediaId: String? { get }
}

protocol CapacitorFaceResult {
    var id: String { get }
}

extension DocumentSideResult: CapacitorDocumentSideResult {}
extension DocumentResult: CapacitorDocumentResult {
    var capacitorFront: CapacitorDocumentSideResult { front }
    var capacitorBack: CapacitorDocumentSideResult? { back }
    var capacitorNfcMediaId: String? { nfcMediaId }
}

extension FaceResult: CapacitorFaceResult {}

func createResponse(_ results: [OnfidoResult], faceVariant: String?) -> [String: [String: Any]] {
    let document: DocumentResult? = results.compactMap { result in
        guard case let .document(documentResult) = result else { return nil }
        return documentResult
    }.first
    let face: FaceResult? = results.compactMap { result in
        guard case let .face(faceResult) = result else { return nil }
        return faceResult
    }.first
    return createResponse(document: document, face: face, faceVariant: faceVariant)
}

func createResponse(
    document: CapacitorDocumentResult? = nil,
    face: CapacitorFaceResult? = nil,
    faceVariant: String? = nil
) -> [String: [String: Any]] {
    var response = [String: [String: Any]]()

    if let documentResponse = document {
        response["document"] = ["front": ["id": documentResponse.capacitorFront.id]]
        if let backId = documentResponse.capacitorBack?.id,
           backId != documentResponse.capacitorFront.id
        {
            response["document"]?["back"] = ["id": documentResponse.capacitorBack?.id]
        }
        
        if let nfcId = documentResponse.capacitorNfcMediaId
        {
            response["document"]?["nfcMediaId"] = ["id": nfcId]
        }
    }

    if let faceResponse = face {
        var faceResponse = ["id": faceResponse.id]

        if let faceVariant = faceVariant {
            faceResponse["variant"] = faceVariant
        }

        response["face"] = faceResponse
    }

    return response
}
