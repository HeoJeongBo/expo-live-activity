import SwiftUI
import WidgetKit
import ActivityKit

// MARK: - Activity Attributes
@available(iOS 16.1, *)
struct LiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var title: String
        var status: String
        var progress: Double
        var timestamp: Date
    }
    
    var name: String
}

// MARK: - Widget Entry View
@available(iOS 16.1, *)
struct LiveActivityWidgetEntryView: View {
    let context: ActivityViewContext<LiveActivityAttributes>
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(context.state.title)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(context.state.status)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("\(Int(context.state.progress * 100))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(context.state.timestamp, style: .relative)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                ProgressView(value: context.state.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .scaleEffect(y: 2)
            }
            .padding()
        }
        .frame(height: 80)
    }
}

// MARK: - Dynamic Island Views
@available(iOS 16.1, *)
struct LiveActivityDynamicIslandCompact: View {
    let context: ActivityViewContext<LiveActivityAttributes>
    
    var body: some View {
        HStack {
            Image(systemName: "clock.fill")
                .foregroundColor(.blue)
            
            Text(context.state.status)
                .font(.caption)
                .fontWeight(.medium)
            
            Spacer()
            
            Text("\(Int(context.state.progress * 100))%")
                .font(.caption)
                .fontWeight(.bold)
        }
    }
}

@available(iOS 16.1, *)
struct LiveActivityDynamicIslandExpanded: View {
    let context: ActivityViewContext<LiveActivityAttributes>
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(context.attributes.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(Int(context.state.progress * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            HStack {
                Text(context.state.status)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(context.state.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: context.state.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
        }
        .padding()
    }
}

// MARK: - Widget Configuration
@available(iOS 16.1, *)
struct LiveActivityWidget: Widget {
    let kind: String = "LiveActivityWidget"
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityAttributes.self) { context in
            LiveActivityWidgetEntryView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(Int(context.state.progress * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    LiveActivityDynamicIslandExpanded(context: context)
                }
            } compactLeading: {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
            } compactTrailing: {
                Text("\(Int(context.state.progress * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
            } minimal: {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - Widget Bundle
@available(iOS 16.1, *)
@main
struct LiveActivityWidgetBundle: WidgetBundle {
    var body: some Widget {
        LiveActivityWidget()
    }
}

#if DEBUG
@available(iOS 16.2, *)
struct LiveActivityWidget_Previews: PreviewProvider {
    static let attributes = LiveActivityAttributes(name: "Live Activity Example")
    static let contentState = LiveActivityAttributes.ContentState(
        title: "Task in Progress",
        status: "Processing...",
        progress: 0.65,
        timestamp: Date()
    )
    
    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
        
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Compact")
        
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Expanded")
    }
}
#endif