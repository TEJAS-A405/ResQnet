# ResQnet Emergency Communication Mesh - Architecture Plan

## Project Overview
ResQnet is a decentralized peer-to-peer communication platform for emergency situations, enabling communication without cellular or internet infrastructure through Wi-Fi mesh networking.

## Core Features
1. **Peer-to-Peer Messaging**: Text-based communication through mesh network
2. **SOS Alerts**: One-tap emergency broadcast system  
3. **Device Discovery**: Network topology visualization
4. **Offline GPS**: Location sharing with coordinate data
5. **Dark Theme UI**: Battery-optimized interface for emergency conditions

## Technical Architecture

### Data Models (`lib/models/`)
- `User`: Profile information and device identity
- `Message`: Text messages with metadata (sender, timestamp, location)
- `SosAlert`: Emergency alerts with enhanced priority and location
- `MeshNode`: Network peer representation with connection status
- `LocationData`: GPS coordinates and timestamp information

### Services (`lib/services/`)  
- `MeshNetworkService`: P2P connectivity and message routing
- `MessageService`: Text message handling and storage
- `SosService`: Emergency alert broadcasting and management
- `LocationService`: GPS coordinate capture and sharing
- `UserService`: Local user profile management
- `StorageService`: Local data persistence

### UI Architecture (`lib/screens/`)
- `HomePage`: Main dashboard with network status and quick actions
- `MessagesScreen`: Conversation interface with mesh routing status
- `NetworkMapScreen`: Visual representation of mesh network topology
- `SosScreen`: Emergency alert interface with large, accessible controls
- `SettingsScreen`: User profile and app configuration

### Core Components (`lib/widgets/`)
- `SosButton`: Large, high-contrast emergency button
- `NetworkStatusIndicator`: Visual network health display
- `MessageBubble`: Chat interface with delivery status
- `NodeCard`: Mesh peer information display
- `LocationIndicator`: GPS status and coordinate display

## Implementation Priority
1. ✅ Project setup and theme configuration
2. ✅ Data models and local storage structure
3. ✅ Basic UI screens with dark theme
4. ✅ Mock mesh networking service
5. ✅ Message interface with P2P routing simulation
6. ✅ SOS alert system with location integration
7. ✅ Network topology visualization
8. ✅ Testing and error handling

## Design System
- **Theme**: Dark mode optimized for battery conservation
- **Colors**: High-contrast emergency palette (orange/red on dark grey)
- **Typography**: Clear, accessible fonts for stress conditions
- **Layout**: Generous spacing, large touch targets
- **Accessibility**: High-contrast, simple navigation patterns

## Technical Notes
- Local storage for offline operation
- Mock mesh networking (real P2P would require platform-specific implementation)
- GPS integration for location sharing
- Battery-optimized UI design
- Simplified architecture suitable for emergency use cases