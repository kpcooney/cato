//
//  CloudKitService.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation
import CloudKit

protocol CloudKitServiceProtocol {
    func syncToCloud() async throws
    func fetchFromCloud() async throws
}

class CloudKitService: CloudKitServiceProtocol {

    private let container: CKContainer

    init() {
        self.container = CKContainer(identifier: "iCloud.com.cato.trainer")
    }

    func syncToCloud() async throws {
        // Stub: SwiftData + CloudKit automatic sync
    }

    func fetchFromCloud() async throws {
        // Stub: SwiftData + CloudKit automatic sync
    }
}
