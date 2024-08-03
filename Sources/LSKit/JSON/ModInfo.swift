//
//  ModInfo.swift
//  LSKit
//
//  Created by David Walter on 28.07.24.
//

import Foundation
import BinaryUtils

/// The `info.json` often found next to mods
public struct ModInfo: Hashable, Equatable, Codable, Sendable {
    /// The list of mods
    public let mods: [Mod]
    /// The MD5 hash of the mod
    public let md5: MD5
    
    public init(mods: [ModInfo.Mod], md5: MD5) {
        self.mods = mods
        self.md5 = md5
    }
    
    enum CodingKeys: String, CodingKey {
        case mods = "Mods"
        case md5 = "MD5"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.mods = try container.decode([ModInfo.Mod].self, forKey: .mods)
        self.md5 = try container.decode(MD5.self, forKey: .md5)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.mods, forKey: .mods)
        try container.encode(self.md5, forKey: .md5)
    }
}

extension ModInfo {
    /// A mod entry in ``ModInfo``
    public struct Mod: Hashable, Equatable, Codable, Sendable {
        /// The UUID of the mod
        public let uuid: UUID?
        /// The name of the mod
        public let name: String?
        /// The description of the mod
        public let description: String?
        /// The folder of the mod
        public let folder: String?
        /// The version of the mod
        public let version: String?
        /// The author of the mod
        public let author: String?
        /// The date the mod was created
        public let created: Date?
        /// The dependencies of the mod
        // public let dependencies: [Any]
        /// The UUID of the group of the mod
        public let group: UUID?
        
        public init(
            uuid: UUID? = nil,
            name: String? = nil,
            description: String? = nil,
            folder: String? = nil,
            version: String? = nil,
            author: String? = nil,
            created: Date? = nil,
            group: UUID? = nil
        ) {
            self.author = author
            self.name = name
            self.folder = folder
            self.version = version
            self.description = description
            self.uuid = uuid
            self.created = created
            self.group = group
        }
        
        enum CodingKeys: String, CodingKey {
            case author = "Author"
            case name = "Name"
            case folder = "Folder"
            case version = "Version"
            case description = "Description"
            case uuid = "UUID"
            case created = "Created"
            case group = "Group"
        }
        
        static let dateFormatStyle: Date.ISO8601FormatStyle = {
            Date.ISO8601FormatStyle(
                dateSeparator: .dash,
                dateTimeSeparator: .standard,
                timeSeparator: .colon,
                timeZoneSeparator: .colon,
                includingFractionalSeconds: true
            )
        }()
        
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.author = try container.decodeIfPresent(String.self, forKey: .author)
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
            self.folder = try container.decodeIfPresent(String.self, forKey: .folder)
            self.version = try container.decodeIfPresent(String.self, forKey: .version)
            self.description = try container.decodeIfPresent(String.self, forKey: .description)
            self.uuid = try container.decodeIfPresent(UUID.self, forKey: .uuid)
            if let created = try container.decodeIfPresent(String.self, forKey: .created) {
                self.created = try Date(created, strategy: Self.dateFormatStyle)
            } else {
                self.created = nil
            }
            self.group = try container.decodeIfPresent(UUID.self, forKey: .group)
        }
        
        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encodeIfPresent(self.author, forKey: .author)
            try container.encodeIfPresent(self.name, forKey: .name)
            try container.encodeIfPresent(self.folder, forKey: .folder)
            try container.encodeIfPresent(self.version, forKey: .version)
            try container.encodeIfPresent(self.description, forKey: .description)
            try container.encodeIfPresent(self.uuid, forKey: .uuid)
            let created = self.created?.formatted(Self.dateFormatStyle)
            try container.encodeIfPresent(created, forKey: .created)
            try container.encodeIfPresent(self.group, forKey: .group)
        }
    }
}
