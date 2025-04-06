// --- START OF FILE GolfTracker.swiftpm/Sources/Controllers/WeatherService.swift ---

import Foundation

class WeatherService {
    // --- UPDATED: Use the key from Secrets.swift ---
    private let apiKey = Secrets.weatherAPIKey // No hardcoded key here anymore

    func getWindData(latitude: Double, longitude: Double) async throws -> (speed: Double, direction: Double) {
        // --- Ensure API Key isn't empty ---
        guard !apiKey.isEmpty, apiKey != "YOUR_API_KEY_HERE" else {
            print("ERROR: Weather API Key not set in Secrets.swift")
            // You could throw a specific error here if desired
            throw URLError(.userAuthenticationRequired) // Or a custom error
        }

        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        // --- Check HTTP Response ---
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            // Attempt to decode potential error message from OpenWeatherMap
            if let errorDetails = try? JSONDecoder().decode(OpenWeatherMapError.self, from: data) {
                 print("OpenWeatherMap API Error (\(httpResponse.statusCode)): \(errorDetails.message)")
                 throw NSError(domain: "WeatherService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorDetails.message])
            } else {
                 print("OpenWeatherMap API Error (\(httpResponse.statusCode)): Unknown error structure.")
                 throw URLError(.init(rawValue: httpResponse.statusCode)) // Throw generic URLError based on status code
            }
        }


        let weatherData = try JSONDecoder().decode(WeatherResponse.self, from: data)

        return (
            speed: weatherData.wind.speed, // meters per second
            direction: weatherData.wind.deg // degrees
        )
    }
}

// --- Model for decoding the API response ---
struct WeatherResponse: Decodable {
    let wind: Wind

    struct Wind: Decodable {
        let speed: Double  // Wind speed in m/s
        let deg: Double    // Wind direction in degrees (meteorological)
    }
}

// --- Model for decoding potential OpenWeatherMap error messages ---
struct OpenWeatherMapError: Decodable {
    let cod: Int // Sometimes the code is a String, handle potential mismatch if needed
    let message: String
}
// --- END OF FILE GolfTracker.swiftpm/Sources/Controllers/WeatherService.swift ---
