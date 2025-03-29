import Foundation

class WeatherService {
    let apiKey = "3562c99bf5f6848f4373b7f5840c56be"
    
    func getWindData(latitude: Double, longitude: Double) async throws -> (speed: Double, direction: Double) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let weatherData = try JSONDecoder().decode(WeatherResponse.self, from: data)
        
        return (
            speed: weatherData.wind.speed,
            direction: weatherData.wind.deg
        )
    }
}

// Model for decoding the API response
struct WeatherResponse: Decodable {
    let wind: Wind
    
    struct Wind: Decodable {
        let speed: Double  // Wind speed in m/s
        let deg: Double    // Wind direction in degrees (meteorological)
    }
}
