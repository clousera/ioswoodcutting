
//  FeatureVoter.swift
//  Mutaclip
//
//  Created by Tyler Stillwater on 5/10/23.
//
// Custom voter implementation for: https://github.com/AvdLee/Roadmap
// Note: will not work until this PR is merged: https://github.com/AvdLee/Roadmap/pull/71


import Foundation
import Roadmap

struct RoadmapFeatureVotingCount: Codable {
  let value: Int?
}

enum JSONDataFetcher {
  enum Error: Swift.Error {
    case invalidURL
  }

  private static var urlSession: URLSession = .init(configuration: .ephemeral)

  static func loadJSON<T: Decodable>(url: URL) async throws -> T {
    let data = try await urlSession.data(from: url).0
    return try JSONDecoder().decode(T.self, from: data)
  }

  static func loadJSON<T: Decodable>(fromURLString urlString: String) async throws -> T {
    guard let url = URL(string: urlString) else {
      throw Error.invalidURL
    }
    return try await loadJSON(url: url)
  }
}

public struct FeatureVoterTallyAPI: FeatureVoter {
  let namespace = Bundle.main.bundleIdentifier!

  /// Fetches the current count for the given feature.
  /// - Returns: The current `count`, else `0` if unsuccessful.
  public func fetch(for feature: RoadmapFeature) async -> Int {
    do {
      let urlString = "https://tally.fly.dev/get/\(namespace)/feature\(feature.id)"
      let count: RoadmapFeatureVotingCount = try await JSONDataFetcher.loadJSON(fromURLString: urlString)
      return count.value ?? 0
    } catch {
      print(error)
      print("Fetching voting count failed with error: \(error.localizedDescription)")
      return 0
    }
  }

  /// Votes for the given feature.
  /// - Returns: The new `count` if successful.
  public func vote(for feature: RoadmapFeature) async -> Int? {
    return await delta(for: feature, delta: 1)
  }

  /// Removes a vote for the given feature.
  /// - Returns: The new `count` if successful.
  public func unvote(for feature: RoadmapFeature) async -> Int? {
    return await delta(for: feature, delta: -1)
  }

  internal func delta(for feature: RoadmapFeature, delta: Int) async -> Int? {
    do {
      let urlString = "https://tally.fly.dev/add/\(namespace)/feature\(feature.id)?delta=\(delta)"
      let count: RoadmapFeatureVotingCount = try await JSONDataFetcher.loadJSON(fromURLString: urlString)
      print("Successfully voted, count is now: \(count)")
      return count.value
    } catch {
      print("Voting failed: \(error.localizedDescription)")
      return nil
    }
  }
}
