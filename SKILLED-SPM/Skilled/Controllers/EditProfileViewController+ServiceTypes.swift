import UIKit

extension EditProfileViewController {
    
    @objc func roleChanged(_ sender: UISegmentedControl) {
        // Show/hide service type selection based on role
        let isProvider = sender.selectedSegmentIndex == 1
        serviceTypeStackView.isHidden = !isProvider
        
        // Update layout
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func serviceTypeToggled(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        // Update selected services
        if let title = sender.title(for: .normal)?.replacingOccurrences(of: "□ ", with: "").replacingOccurrences(of: "✓ ", with: "") {
            if sender.isSelected {
                if !selectedServices.contains(title) {
                    selectedServices.append(title)
                    print("Added service: \(title)")
                }
            } else if let index = selectedServices.firstIndex(of: title) {
                selectedServices.remove(at: index)
                print("Removed service: \(title)")
            }
        }
        
        print("Current selected services: \(selectedServices)")
    }
    
    // In EditProfileViewController.swift, find the updateServiceTypeCheckboxes method
    @objc func updateServiceTypeCheckboxes() {
        // Reset all checkboxes and clear selected services
        for button in serviceTypeCheckboxes {
            button.isSelected = false
        }
        selectedServices.removeAll()
        
        // Set selected checkboxes based on user's services
        if let services = user?.servicesOffered {
            print("User services: \(services)")
            for service in services {
                for (index, option) in serviceTypeOptions.enumerated() {
                    if service == option && index < serviceTypeCheckboxes.count {
                        serviceTypeCheckboxes[index].isSelected = true
                        selectedServices.append(service)
                        print("Selected service: \(service) at index \(index)")
                    }
                }
            }
        } else {
            print("No services found for user")
        }
        
        print("Total selected services: \(selectedServices.count)")
    }

}