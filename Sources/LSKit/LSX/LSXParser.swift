//
//  LSXParser.swift
//  LSKit
//
//  Created by David Walter on 21.07.24.
//

import Foundation

final class LSXParser: NSObject, XMLParserDelegate {
    enum Element {
        case save
        case version

        case region(LSXRegion)

        case node(LSXNode)

        case children([LSXNode])
        case attribute

        init?(elementName: String, id: String?) {
            switch elementName {
            case "save":
                self = .save
            case "version":
                self = .version
            case "region":
                guard let id else { return nil }
                self = .region(LSXRegion(id: id))
            case "node":
                guard let id else { return nil }
                self = .node(LSXNode(id: id, attributes: [], children: []))
            case "children":
                self = .children([])
            case "attribute":
                self = .attribute
            default:
                return nil
            }
        }
    }

    var result: LSX?

    private var path: [Element]

    private var version: LSXVersion
    private var regions: [LSXRegion]

    private var currentAttributes: [LSXAttribute] = []

    override init() {
        self.path = []

        self.version = .empty
        self.regions = []

        super.init()
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        result = LSX(version: version, regions: regions)
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        guard let element = Element(elementName: elementName, id: attributeDict["id"]) else {
            parser.abortParsing()
            return
        }

        self.parser(parser, didStartElement: element, namespaceURI: namespaceURI, qualifiedName: qName, attributes: attributeDict)
    }

    private func parser(_ parser: XMLParser, didStartElement element: Element, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        path.append(element)

        switch element {
        case .version:
            version = LSXVersion(attributes: attributeDict)
        case .attribute:
            if let attribute = LSXAttribute(attributes: attributeDict) {
                currentAttributes.append(attribute)
            }
        default:
            return
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard let element = path.popLast() else { return }

        switch element {
        case let .node(node):
            let updatedNode = LSXNode(id: node.id, attributes: currentAttributes.consume(), children: node.children)
            if let parent = path.popLast() {
                switch parent {
                case let .node(parent):
                    let children = parent.children + [updatedNode]
                    let updatedParent = LSXNode(id: parent.id, attributes: parent.attributes, children: children)
                    path.append(.node(updatedParent))
                case let .children(nodes):
                    let updatedParent = nodes + [updatedNode]
                    path.append(.children(updatedParent))
                case let .region(parent):
                    let updatedParent = LSXRegion(id: parent.id, nodes: parent.nodes + [updatedNode])
                    path.append(.region(updatedParent))
                default:
                    path.append(parent)
                }
            }
        case let .children(nodes):
            if let parent = path.popLast() {
                switch parent {
                case let .node(parent):
                    let updatedParent = LSXNode(id: parent.id, attributes: parent.attributes, children: nodes)
                    path.append(.node(updatedParent))
                default:
                    path.append(parent)
                }
            }
        case let .region(region):
            self.regions.append(region)
        default:
            return
        }
    }
}

private extension Array {
    func parent() -> Element? {
        self.dropLast().last
    }

    mutating func replaceLast(_ element: Element) {
        _ = popLast()
        append(element)
    }

    mutating func consume() -> Self {
        let copy = self
        self = []
        return copy
    }
}
