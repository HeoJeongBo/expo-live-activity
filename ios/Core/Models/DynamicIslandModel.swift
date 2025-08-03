import Foundation

// MARK: - Dynamic Island Models

/// Dynamic Island 콘텐츠 구성
public struct DynamicIslandContent {
    let compactLeading: DynamicIslandElement?
    let compactTrailing: DynamicIslandElement?
    let minimal: DynamicIslandElement?
    let expanded: DynamicIslandExpandedContent?
    
    public init(
        compactLeading: DynamicIslandElement? = nil,
        compactTrailing: DynamicIslandElement? = nil,
        minimal: DynamicIslandElement? = nil,
        expanded: DynamicIslandExpandedContent? = nil
    ) {
        self.compactLeading = compactLeading
        self.compactTrailing = compactTrailing
        self.minimal = minimal
        self.expanded = expanded
    }
}

/// Dynamic Island 요소
public struct DynamicIslandElement {
    let type: ElementType
    let content: String
    let color: String?
    let font: FontStyle?
    
    public init(
        type: ElementType,
        content: String,
        color: String? = nil,
        font: FontStyle? = nil
    ) {
        self.type = type
        self.content = content
        self.color = color
        self.font = font
    }
    
    public enum ElementType {
        case text
        case icon
        case emoji
        case progress
    }
    
    public enum FontStyle {
        case caption
        case body
        case headline
        case title
    }
}

/// Dynamic Island 확장 콘텐츠
public struct DynamicIslandExpandedContent {
    let height: DynamicIslandHeight
    let content: ExpandedContentType
    
    public init(height: DynamicIslandHeight, content: ExpandedContentType) {
        self.height = height
        self.content = content
    }
    
    public enum DynamicIslandHeight {
        case compact
        case normal
        case large
        
        var pixelHeight: CGFloat {
            switch self {
            case .compact: return 84
            case .normal: return 160
            case .large: return 220
            }
        }
    }
    
    public enum ExpandedContentType {
        case custom(String) // SwiftUI View 이름
        case template(ExpandedTemplate)
    }
}

/// 확장 콘텐츠 템플릿
public struct ExpandedTemplate {
    let layout: LayoutType
    let elements: [ExpandedElement]
    
    public init(layout: LayoutType, elements: [ExpandedElement]) {
        self.layout = layout
        self.elements = elements
    }
    
    public enum LayoutType {
        case vertical
        case horizontal
        case grid(columns: Int)
    }
}

/// 확장 콘텐츠 요소
public struct ExpandedElement {
    let id: String
    let type: ElementType
    let content: String
    let position: ElementPosition?
    let style: ElementStyle?
    
    public init(
        id: String,
        type: ElementType,
        content: String,
        position: ElementPosition? = nil,
        style: ElementStyle? = nil
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.position = position
        self.style = style
    }
    
    public enum ElementType {
        case title
        case subtitle
        case body
        case progress
        case button
        case image
        case spacer
    }
    
    public struct ElementPosition {
        let x: Double
        let y: Double
        
        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }
    }
    
    public struct ElementStyle {
        let fontSize: Double?
        let fontWeight: FontWeight?
        let color: String?
        let backgroundColor: String?
        
        public init(
            fontSize: Double? = nil,
            fontWeight: FontWeight? = nil,
            color: String? = nil,
            backgroundColor: String? = nil
        ) {
            self.fontSize = fontSize
            self.fontWeight = fontWeight
            self.color = color
            self.backgroundColor = backgroundColor
        }
        
        public enum FontWeight {
            case regular
            case medium
            case semibold
            case bold
        }
    }
}

// MARK: - Dynamic Island Update Request

/// Dynamic Island 업데이트 요청
public struct DynamicIslandUpdateRequest {
    let activityId: String
    let content: DynamicIslandContent
    let animationType: AnimationType
    let timestamp: Date
    
    public init(
        activityId: String,
        content: DynamicIslandContent,
        animationType: AnimationType = .smooth,
        timestamp: Date = Date()
    ) {
        self.activityId = activityId
        self.content = content
        self.animationType = animationType
        self.timestamp = timestamp
    }
    
    public enum AnimationType {
        case none
        case smooth
        case bounce
        case fade
    }
}

// MARK: - Predefined Templates

/// 미리 정의된 Dynamic Island 템플릿
public enum DynamicIslandTemplate {
    case foodDelivery(status: String, time: String, restaurant: String)
    case rideshare(status: String, eta: String, driver: String)
    case workout(type: String, duration: String, calories: String)
    case timer(remaining: String, total: String)
    
    public var content: DynamicIslandContent {
        switch self {
        case .foodDelivery(let status, let time, let restaurant):
            return DynamicIslandContent(
                compactLeading: DynamicIslandElement(type: .emoji, content: "🍕"),
                compactTrailing: DynamicIslandElement(type: .text, content: time),
                minimal: DynamicIslandElement(type: .emoji, content: "🍕"),
                expanded: DynamicIslandExpandedContent(
                    height: .normal,
                    content: .template(ExpandedTemplate(
                        layout: .vertical,
                        elements: [
                            ExpandedElement(id: "restaurant", type: .title, content: restaurant),
                            ExpandedElement(id: "status", type: .subtitle, content: status),
                            ExpandedElement(id: "time", type: .body, content: "예상 시간: \(time)")
                        ]
                    ))
                )
            )
            
        case .rideshare(let status, let eta, let driver):
            return DynamicIslandContent(
                compactLeading: DynamicIslandElement(type: .emoji, content: "🚗"),
                compactTrailing: DynamicIslandElement(type: .text, content: eta),
                minimal: DynamicIslandElement(type: .emoji, content: "🚗"),
                expanded: DynamicIslandExpandedContent(
                    height: .normal,
                    content: .template(ExpandedTemplate(
                        layout: .vertical,
                        elements: [
                            ExpandedElement(id: "driver", type: .title, content: driver),
                            ExpandedElement(id: "status", type: .subtitle, content: status),
                            ExpandedElement(id: "eta", type: .body, content: "도착 예정: \(eta)")
                        ]
                    ))
                )
            )
            
        case .workout(let type, let duration, let calories):
            return DynamicIslandContent(
                compactLeading: DynamicIslandElement(type: .emoji, content: "💪"),
                compactTrailing: DynamicIslandElement(type: .text, content: duration),
                minimal: DynamicIslandElement(type: .emoji, content: "💪"),
                expanded: DynamicIslandExpandedContent(
                    height: .normal,
                    content: .template(ExpandedTemplate(
                        layout: .vertical,
                        elements: [
                            ExpandedElement(id: "type", type: .title, content: type),
                            ExpandedElement(id: "duration", type: .subtitle, content: "시간: \(duration)"),
                            ExpandedElement(id: "calories", type: .body, content: "칼로리: \(calories)")
                        ]
                    ))
                )
            )
            
        case .timer(let remaining, let total):
            return DynamicIslandContent(
                compactLeading: DynamicIslandElement(type: .emoji, content: "⏱️"),
                compactTrailing: DynamicIslandElement(type: .text, content: remaining),
                minimal: DynamicIslandElement(type: .text, content: remaining),
                expanded: DynamicIslandExpandedContent(
                    height: .compact,
                    content: .template(ExpandedTemplate(
                        layout: .vertical,
                        elements: [
                            ExpandedElement(id: "remaining", type: .title, content: remaining),
                            ExpandedElement(id: "total", type: .subtitle, content: "전체: \(total)")
                        ]
                    ))
                )
            )
        }
    }
}