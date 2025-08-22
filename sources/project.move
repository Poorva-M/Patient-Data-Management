module MyModule::PatientDataManagement {
    use aptos_framework::signer;
    use std::string::String;
    
    /// Struct representing patient medical data.
    struct PatientData has store, key {
        patient_id: u64,           // Unique patient identifier
        name: String,              // Patient's name
        age: u64,                  // Patient's age
        medical_condition: String, // Current medical condition
        doctor_address: address,   // Address of the attending doctor
        last_updated: u64,         // Timestamp of last update
    }
    
    /// Error codes
    const E_PATIENT_DATA_NOT_EXISTS: u64 = 1;
    const E_UNAUTHORIZED_ACCESS: u64 = 2;
    
    /// Function to register a new patient with their medical data.
    public fun register_patient(
        doctor: &signer,
        patient_id: u64,
        name: String,
        age: u64,
        medical_condition: String,
        timestamp: u64
    ) {
        let doctor_addr = signer::address_of(doctor);
        
        let patient_data = PatientData {
            patient_id,
            name,
            age,
            medical_condition,
            doctor_address: doctor_addr,
            last_updated: timestamp,
        };
        
        move_to(doctor, patient_data);
    }
    
    /// Function to update existing patient's medical condition (only by the same doctor).
    public fun update_patient_condition(
        doctor: &signer,
        new_condition: String,
        timestamp: u64
    ) acquires PatientData {
        let doctor_addr = signer::address_of(doctor);
        
        // Check if patient data exists
        assert!(exists<PatientData>(doctor_addr), E_PATIENT_DATA_NOT_EXISTS);
        
        let patient_data = borrow_global_mut<PatientData>(doctor_addr);
        
        // Only the original doctor can update the patient data
        assert!(patient_data.doctor_address == doctor_addr, E_UNAUTHORIZED_ACCESS);
        
        // Update the medical condition and timestamp
        patient_data.medical_condition = new_condition;
        patient_data.last_updated = timestamp;
    }
}
