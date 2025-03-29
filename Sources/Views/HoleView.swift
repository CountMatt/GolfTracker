import SwiftUI
import CoreLocation

// Location Manager for getting GPS coordinates
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastError: String?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        // Check authorization status
        let status = locationManager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            lastError = "Location access denied. Please enable in Settings."
        case .notDetermined:
            requestLocationPermission()
        @unknown default:
            lastError = "Unknown location authorization status"
        }
    }
    
    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        lastError = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lastError = "Location error: \(error.localizedDescription)"
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
}

// Simple wind display view
struct WindIndicatorView: View {
    let speed: Double
    let direction: Int
    
    var body: some View {
        HStack(spacing: 4) {
            // Wind direction arrow
            Image(systemName: "arrow.up")
                .rotationEffect(.degrees(Double(direction)))
                .frame(width: 20, height: 20)
            
            // Wind speed
            Text("\(Int(speed)) m/s")
                .font(.system(size: 14))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(speed > 0 ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}

struct HoleView: View {
    @Binding var hole: Hole
    @FocusState private var isApproachDistanceFocused: Bool
    @FocusState private var isFirstPuttDistanceFocused: Bool
    
    @StateObject private var locationManager = LocationManager()
    @State private var isLoadingWeather = false
    @State private var weatherError: String? = nil
    @State private var showWindSettings = false
    
    // Limited club selections for tee and approach shots
    private let teeClubOptions = [
        Club(type: .driver, name: "Driver"),
        Club(type: .wood, name: "7W"),
        Club(type: .iron, name: "4i"),
        Club(type: .iron, name: "5i"),
        Club(type: .iron, name: "6i")
    ]
    
    private let approachClubOptions = [
        Club(type: .wood, name: "7W"),
        Club(type: .iron, name: "4i"),
        Club(type: .iron, name: "5i"),
        Club(type: .iron, name: "6i"),
        Club(type: .iron, name: "7i"),
        Club(type: .iron, name: "8i"),
        Club(type: .iron, name: "9i"),
        Club(type: .wedge, name: "PW"),
        Club(type: .wedge, name: "50°"),
        Club(type: .wedge, name: "54°"),
        Club(type: .wedge, name: "58°")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Hole header with par selection
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hole \(hole.number)")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("Par:")
                            .font(.headline)
                        
                        ForEach([3, 4, 5], id: \.self) { parValue in
                            Button(action: {
                                hole.par = parValue
                                // Auto-set the initial score to match par
                                hole.score = parValue
                            }) {
                                Text("\(parValue)")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(hole.par == parValue ? Color.green : Color.gray.opacity(0.2))
                                    .foregroundColor(hole.par == parValue ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Wind section
                    HStack {
                        Text("Wind:")
                            .font(.subheadline)
                        
                        Button(action: {
                            showWindSettings = true
                        }) {
                            WindIndicatorView(speed: hole.windSpeed, direction: hole.windDirection)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            updateWindFromWeatherData()
                        }) {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("Current")
                            }
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                        }
                        .disabled(isLoadingWeather)
                        
                        if isLoadingWeather {
                            ProgressView()
                                .scaleEffect(0.7)
                        }
                    }
                    
                    if let error = weatherError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    // Show wind impact if approach distance is set
                    if let distance = hole.approachDistance {
                        let impact = hole.calculateWindImpact(distance: distance)
                        if abs(impact) > 0 {
                            HStack {
                                Image(systemName: impact > 0 ? "arrow.up" : "arrow.down")
                                    .foregroundColor(impact > 0 ? .green : .red)
                                
                                Text("Wind \(impact > 0 ? "helps" : "hurts") \(abs(impact)) meters")
                                    .font(.caption)
                                    .foregroundColor(impact > 0 ? .green : .red)
                                
                                Spacer()
                                
                                Text("Effective: \(distance + impact)m")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .padding(6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                }
                
                Divider()
                
                // Tee shot section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tee Shot")
                        .font(.headline)
                    
                    // Club dropdown selector
                    HStack {
                        Text("Club:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Menu {
                            ForEach(teeClubOptions) { club in
                                Button(club.name) {
                                    hole.teeClub = club
                                }
                            }
                        } label: {
                            HStack {
                                Text(hole.teeClub?.name ?? "Select Club")
                                Image(systemName: "chevron.down")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    if !hole.isPar3 {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Fairway:")
                                .font(.subheadline)
                            
                            HStack(spacing: 8) {
                                Button(action: {
                                    hole.fairwayHit = false
                                    hole.fairwayMissDirection = .left
                                }) {
                                    Text("Left")
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(hole.fairwayHit == false && hole.fairwayMissDirection == .left ?
                                                    Color.red.opacity(0.7) : Color.gray.opacity(0.2))
                                        .foregroundColor(hole.fairwayHit == false && hole.fairwayMissDirection == .left ?
                                                         .white : .primary)
                                        .cornerRadius(8)
                                }
                                
                                Button(action: {
                                    hole.fairwayHit = true
                                }) {
                                    Text("Hit")
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(hole.fairwayHit == true ? Color.green : Color.gray.opacity(0.2))
                                        .foregroundColor(hole.fairwayHit == true ? .white : .primary)
                                        .cornerRadius(8)
                                }
                                
                                Button(action: {
                                    hole.fairwayHit = false
                                    hole.fairwayMissDirection = .right
                                }) {
                                    Text("Right")
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(hole.fairwayHit == false && hole.fairwayMissDirection == .right ?
                                                    Color.red.opacity(0.7) : Color.gray.opacity(0.2))
                                        .foregroundColor(hole.fairwayHit == false && hole.fairwayMissDirection == .right ?
                                                         .white : .primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                // Approach shot section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Approach Shot")
                        .font(.headline)
                    
                    HStack {
                        Text("Distance:")
                            .font(.subheadline)
                        
                        ZStack(alignment: .trailing) {
                            TextField("Meters", value: $hole.approachDistance, format: .number)
                                .keyboardType(.numberPad)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .focused($isApproachDistanceFocused)
                            
                            if isApproachDistanceFocused {
                                Button("Done") {
                                    isApproachDistanceFocused = false
                                }
                                .padding(.trailing, 8)
                                .foregroundColor(.blue)
                            }
                        }
                        .frame(width: 120)
                    }
                    
                    // Approach club dropdown
                    HStack {
                        Text("Club:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Menu {
                            ForEach(approachClubOptions) { club in
                                Button(club.name) {
                                    hole.approachClub = club
                                }
                            }
                        } label: {
                            HStack {
                                Text(hole.approachClub?.name ?? "Select Club")
                                Image(systemName: "chevron.down")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Green hit location and putts in same row
                    HStack(alignment: .top, spacing: 16) {
                        // Green target view
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Green Hit Location:")
                                .font(.subheadline)
                            
                            ImprovedGreenTargetView(selectedLocation: $hole.greenHitLocation)
                                .frame(width: 180, height: 180)
                        }
                        
                        // Putts section next to green
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Putts:")
                                .font(.subheadline)
                            
                            VStack(spacing: 8) {
                                // Putts selector
                                HStack {
                                    ForEach(1...4, id: \.self) { putts in
                                        Button(action: {
                                            hole.putts = putts
                                        }) {
                                            Text("\(putts)")
                                                .frame(width: 30)
                                                .padding(.vertical, 8)
                                                .background(hole.putts == putts ? Color.blue : Color.gray.opacity(0.2))
                                                .foregroundColor(hole.putts == putts ? .white : .primary)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                
                                // First putt distance
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("First Putt:")
                                        .font(.caption)
                                    
                                    ZStack(alignment: .trailing) {
                                        TextField("Feet", value: $hole.firstPuttDistance, format: .number)
                                            .keyboardType(.numberPad)
                                            .padding(8)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                            .focused($isFirstPuttDistanceFocused)
                                        
                                        if isFirstPuttDistanceFocused {
                                            Button("Done") {
                                                isFirstPuttDistanceFocused = false
                                            }
                                            .padding(.trailing, 8)
                                            .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                // Score section at the end
                VStack(alignment: .leading, spacing: 8) {
                    Text("Score:")
                        .font(.headline)
                    
                    // Dynamic score buttons based on par
                    let scoreOptions = getScoreOptions(for: hole.par)
                    
                    HStack(spacing: 6) {
                        ForEach(scoreOptions, id: \.self) { score in
                            Button(action: {
                                hole.score = score
                            }) {
                                Text(scoreString(for: score, par: hole.par))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(hole.score == score ?
                                                scoreColor(for: score, par: hole.par) :
                                                    Color.gray.opacity(0.2))
                                    .foregroundColor(hole.score == score ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding()
            .onAppear {
                // Initialize score to par value when view appears
                if hole.score == 0 {
                    hole.score = hole.par
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isApproachDistanceFocused = false
                        isFirstPuttDistanceFocused = false
                    }
                }
            }
            .onDisappear {
                // Make sure data is saved when leaving the view
                saveHoleData()
            }
            .sheet(isPresented: $showWindSettings) {
                WindSettingsView(
                    windSpeed: $hole.windSpeed,
                    windDirection: $hole.windDirection,
                    approachDistance: hole.approachDistance
                )
                .presentationDetents([.medium])
            }
        }
    }
    
    // Helper function to ensure data is saved
    private func saveHoleData() {
        // Force binding update
        let _ = hole
    }
    
    // Function to update wind from weather API
    private func updateWindFromWeatherData() {
        // First check authorization status
        if locationManager.authorizationStatus != .authorizedWhenInUse &&
           locationManager.authorizationStatus != .authorizedAlways {
            locationManager.requestLocationPermission()
            weatherError = "Please allow location access"
            return
        }
        
        // Then check for location
        guard let location = locationManager.location else {
            weatherError = locationManager.lastError ?? "Location not available"
            return
        }
        
        isLoadingWeather = true
        weatherError = nil
        
        Task {
            do {
                let weatherService = WeatherService()
                let windData = try await weatherService.getWindData(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                
                await MainActor.run {
                    hole.windSpeed = windData.speed
                    hole.windDirection = Int(windData.direction)
                    isLoadingWeather = false
                }
            } catch {
                await MainActor.run {
                    weatherError = "Weather data error: \(error.localizedDescription)"
                    isLoadingWeather = false
                }
            }
        }
    }
    }
    
    // Helper function to get score options based on par
    private func getScoreOptions(for par: Int) -> [Int] {
        switch par {
        case 3:
            return [2, 3, 4, 5, 6]
        case 4:
            return [3, 4, 5, 6, 7]
        case 5:
            return [3, 4, 5, 6, 7]
        default:
            return [par - 1, par, par + 1, par + 2, par + 3]
        }
    }
    
    // Helper function to show score in golf terms
    private func scoreString(for score: Int, par: Int) -> String {
        let diff = score - par
        
        if diff == -2 {
            return "Eagle"
        } else if diff == -1 {
            return "Birdie"
        } else if diff == 0 {
            return "Par"
        } else if diff == 1 {
            return "Bogey"
        } else if diff == 2 {
            return "Dbl"
        } else {
            return "\(score)"
        }
    }
    
    // Helper function to color score buttons
    private func scoreColor(for score: Int, par: Int) -> Color {
        let diff = score - par
        
        if diff <= -2 {
            return Color.purple   // Eagle or better
        } else if diff == -1 {
            return Color.red      // Birdie
        } else if diff == 0 {
            return Color.green    // Par
        } else if diff == 1 {
            return Color.blue     // Bogey
        } else {
            return Color.gray     // Double bogey or worse
        }
    }


// Wind settings sheet
struct WindSettingsView: View {
    @Binding var windSpeed: Double
    @Binding var windDirection: Int
    let approachDistance: Int?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Wind Settings")
                .font(.headline)
            
            // Wind direction picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Wind Direction:")
                    .font(.subheadline)
                
                Picker("Direction", selection: $windDirection) {
                    Text("N").tag(0)
                    Text("NE").tag(45)
                    Text("E").tag(90)
                    Text("SE").tag(135)
                    Text("S").tag(180)
                    Text("SW").tag(225)
                    Text("W").tag(270)
                    Text("NW").tag(315)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // Wind speed slider
            VStack(alignment: .leading, spacing: 8) {
                Text("Wind Speed: \(Int(windSpeed)) m/s")
                    .font(.subheadline)
                
                Slider(value: $windSpeed, in: 0...20, step: 1)
            }
            
            // Wind direction visualization
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    .frame(width: 100, height: 100)
                
                // Direction arrow
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 2, height: 40)
                    .offset(y: -20)
                    .rotationEffect(.degrees(Double(windDirection)))
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
            }
            
            // Impact preview
            if let distance = approachDistance {
                let impact = calculateWindImpact(
                    distance: distance,
                    windSpeed: windSpeed,
                    windDirection: Double(windDirection)
                )
                
                VStack(spacing: 4) {
                    Text("Estimated Impact")
                        .font(.subheadline)
                    
                    Text("\(distance) meters →  \(distance + impact) meters")
                        .font(.headline)
                        .foregroundColor(impact > 0 ? .green : (impact < 0 ? .red : .primary))
                    
                    Text(impact > 0 ? "Wind helping" : (impact < 0 ? "Wind hurting" : "No effect"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            Button("Done") {
                dismiss()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
    
    // Wind impact calculation
    private func calculateWindImpact(distance: Int, windSpeed: Double, windDirection: Double) -> Int {
        // Convert degrees to radians for calculation
        let radians = (windDirection * .pi) / 180.0
        
        // Calculate headwind/tailwind component
        let headwindComponent = cos(radians) * windSpeed
        
        // Calculate crosswind component
        let crosswindComponent = sin(radians) * windSpeed
        
        // Headwind generally reduces distance more than crosswind
        let headwindImpact = -headwindComponent * 2.5  // 2.5 meters per m/s headwind
        let crosswindImpact = abs(crosswindComponent) * 0.8  // 0.8 meters per m/s crosswind
        
        // Total impact (negative = shorter, positive = longer)
        let totalImpact = Int(headwindImpact - crosswindImpact)
        
        return totalImpact
    }
}

// Improved GreenTargetView with correct coloring
struct ImprovedGreenTargetView: View {
    @Binding var selectedLocation: GreenHitLocation
    
    // Grid layout: 3x3 grid of locations
    let locations: [[GreenHitLocation]] = [
        [.longLeft, .long, .longRight],
        [.left, .center, .right],
        [.shortLeft, .short, .shortRight]
    ]
    
    var body: some View {
        VStack(spacing: 2) {
            VStack(spacing: 2) {
                ForEach(0..<3) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<3) { col in
                            let location = locations[row][col]
                            Button(action: {
                                selectedLocation = location
                            }) {
                                ZStack {
                                    Rectangle()
                                        .fill(getLocationColor(location))
                                        .frame(width: 52, height: 52)
                                    
                                    if location == .center {
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                            .frame(width: 32, height: 32)
                                    }
                                    
                                    Text(getDirectionText(for: location))
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .fontWeight(selectedLocation == location ? .bold : .regular)
                                }
                            }
                        }
                    }
                }
            }
            .background(Color.black.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    // Get color based on location - green for GIR, light red for misses
    private func getLocationColor(_ location: GreenHitLocation) -> Color {
        if location == selectedLocation {
            return location == .center ? Color.green : Color.red.opacity(0.7)
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private func getDirectionText(for location: GreenHitLocation) -> String {
        switch location {
        case .center: return "GIR"
        case .longLeft: return "L/L"
        case .long: return "Long"
        case .longRight: return "L/R"
        case .left: return "Left"
        case .right: return "Right"
        case .shortLeft: return "S/L"
        case .short: return "Short"
        case .shortRight: return "S/R"
        }
    }
}
