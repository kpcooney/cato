//
//  CloudKitService.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation
import CloudKit

protocol CloudKitServiceProtocol {
    func syncToCloud() async throws
    func fetchFromCloud() async throws
}

/// Provides a named interface to CloudKit operations.
///
/// In practice, SwiftData handles sync automatically via the ModelContainer
/// configured with `.cloudKitDatabase(.private("iCloud.com.cato.trainer"))` in CatoApp.
/// This class exists as an explicit protocol boundary so that:
///   1. Tests can inject a mock CloudKitService to avoid network calls.
///   2. Any future manual CloudKit operations (e.g. sharing, public DB queries) have
///      a natural home without touching the SwiftData layer.
///
/// For Phase 1–4, calling these methods is a no-op — SwiftData sync runs automatically
/// in the background. The protocol is here for architectural completeness.
class CloudKitService: CloudKitServiceProtocol {

    private let container: CKContainer

    init() {
        // Must match the CloudKit container identifier in Cato.entitlements
        // and the ModelConfiguration in CatoApp.swift.
        self.container = CKContainer(identifier: "iCloud.com.cato.trainer")
    }

    /// No-op: SwiftData + CloudKit integration handles sync automatically.
    func syncToCloud() async throws {}

    /// No-op: SwiftData + CloudKit integration handles fetch automatically.
    func fetchFromCloud() async throws {}
}
