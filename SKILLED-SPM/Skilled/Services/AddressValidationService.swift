import Foundation
import CoreLocation

class AddressValidationService {
    
    private let geocoder = CLGeocoder()
    
    // Validate a complete address
    func validateAddress(street: String, city: String, state: String, zipCode: String, completion: @escaping (Bool, CLLocation?, String?) -> Void) {
        // Create a complete address string
        let addressString = "\(street), \(city), \(state) \(zipCode)"
        
        // Use geocoder to validate the address
        geocoder.geocodeAddressString(addressString) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(false, nil, "Unable to validate address: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                completion(false, nil, "Address not found")
                return
            }
            
            // Address is valid
            completion(true, location, nil)
        }
    }
    
    // Validate zip code format
    func isValidZipCode(_ zipCode: String) -> Bool {
        // US zip code format: 5 digits or 5 digits + dash + 4 digits
        let zipRegex = "^\\d{5}(-\\d{4})?$"
        let zipPredicate = NSPredicate(format: "SELF MATCHES %@", zipRegex)
        return zipPredicate.evaluate(with: zipCode)
    }
    
    // Validate state format (2-letter code)
    func isValidState(_ state: String) -> Bool {
        // US state code format: 2 uppercase letters
        let stateRegex = "^[A-Z]{2}$"
        let statePredicate = NSPredicate(format: "SELF MATCHES %@", stateRegex)
        return statePredicate.evaluate(with: state)
    }
    
    // Get state code from state name
    func getStateCode(from stateName: String) -> String? {
        let states = [
            "alabama": "AL", "alaska": "AK", "arizona": "AZ", "arkansas": "AR", "california": "CA",
            "colorado": "CO", "connecticut": "CT", "delaware": "DE", "florida": "FL", "georgia": "GA",
            "hawaii": "HI", "idaho": "ID", "illinois": "IL", "indiana": "IN", "iowa": "IA",
            "kansas": "KS", "kentucky": "KY", "louisiana": "LA", "maine": "ME", "maryland": "MD",
            "massachusetts": "MA", "michigan": "MI", "minnesota": "MN", "mississippi": "MS", "missouri": "MO",
            "montana": "MT", "nebraska": "NE", "nevada": "NV", "new hampshire": "NH", "new jersey": "NJ",
            "new mexico": "NM", "new york": "NY", "north carolina": "NC", "north dakota": "ND", "ohio": "OH",
            "oklahoma": "OK", "oregon": "OR", "pennsylvania": "PA", "rhode island": "RI", "south carolina": "SC",
            "south dakota": "SD", "tennessee": "TN", "texas": "TX", "utah": "UT", "vermont": "VT",
            "virginia": "VA", "washington": "WA", "west virginia": "WV", "wisconsin": "WI", "wyoming": "WY",
            "district of columbia": "DC"
        ]
        
        return states[stateName.lowercased()]
    }
}