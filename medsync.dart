import 'dart:io';

// ==================== MODELS ====================

class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
  });

  @override
  String toString() {
    return 'ID: $id | Name: $name | Age: $age | Gender: $gender';
  }
}

class InventoryItem {
  final String id;
  final String name;
  int quantity;
  final double unitPrice;

  InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  @override
  String toString() {
    return 'ID: $id | Name: $name | Qty: $quantity | Price: NLE ${unitPrice.toStringAsFixed(2)}';
  }
}

class Prescription {
  final String id;
  final String patientId;
  final String itemId;
  final int quantity;
  bool isDispensed;

  Prescription({
    required this.id,
    required this.patientId,
    required this.itemId,
    required this.quantity,
    this.isDispensed = false,
  });

  @override
  String toString() {
    return 'Rx ID: $id | Patient ID: $patientId | Item ID: $itemId | Qty: $quantity | Status: ${isDispensed ? "Dispensed" : "Pending"}';
  }
}

// ==================== SYSTEM CONTROLLER ====================

class MedSyncSystem {
  final List<Patient> _patients = [];
  final List<InventoryItem> _inventory = [];
  final List<Prescription> _prescriptions = [];

  MedSyncSystem() {
    _seedInitialData();
  }

  void _seedInitialData() {
    // Initial inventory data
    _inventory.add(InventoryItem(id: 'INV01', name: 'Paracetamol 500mg', quantity: 100, unitPrice: 5.0));
    _inventory.add(InventoryItem(id: 'INV02', name: 'Amoxicillin 250mg', quantity: 50, unitPrice: 15.0));
    _inventory.add(InventoryItem(id: 'INV03', name: 'Artemether/Lumefantrine', quantity: 40, unitPrice: 25.0));
  }

  void registerPatient() {
    print('\n--- REGISTER NEW PATIENT ---');
    stdout.write('Enter Patient Name: ');
    String? name = stdin.readLineSync();
    
    stdout.write('Enter Patient Age: ');
    int? age = int.tryParse(stdin.readLineSync() ?? '');

    stdout.write('Enter Patient Gender (M/F): ');
    String? gender = stdin.readLineSync();

    if (name != null && name.isNotEmpty && age != null && gender != null) {
      String id = 'P${(_patients.length + 1).toString().padLeft(3, '0')}';
      Patient newPatient = Patient(id: id, name: name, age: age, gender: gender);
      _patients.add(newPatient);
      print('>>> Success: Patient registered with ID: $id');
    } else {
      print('>>> Error: Invalid input details. Registration failed.');
    }
  }

  void viewPatients() {
    print('\n--- REGISTERED PATIENTS ---');
    if (_patients.isEmpty) {
      print('No patients registered yet.');
      return;
    }
    for (var p in _patients) {
      print(p);
    }
  }

  void viewInventory() {
    print('\n--- PHARMACY INVENTORY ---');
    if (_inventory.isEmpty) {
      print('Inventory is empty.');
      return;
    }
    for (var item in _inventory) {
      print(item);
    }
  }

  void createPrescription() {
    print('\n--- CREATE PRESCRIPTION ---');
    if (_patients.isEmpty) {
      print('>>> Error: No registered patients found. Register a patient first.');
      return;
    }

    viewPatients();
    stdout.write('Enter Patient ID: ');
    String? pId = stdin.readLineSync();

    Patient? patient;
    try {
      patient = _patients.firstWhere((p) => p.id.toUpperCase() == pId?.trim().toUpperCase());
    } catch (_) {
      patient = null;
    }

    if (patient == null) {
      print('>>> Error: Patient not found.');
      return;
    }

    viewInventory();
    stdout.write('Enter Drug Item ID: ');
    String? itemId = stdin.readLineSync();

    InventoryItem? item;
    try {
      item = _inventory.firstWhere((i) => i.id.toUpperCase() == itemId?.trim().toUpperCase());
    } catch (_) {
      item = null;
    }

    if (item == null) {
      print('>>> Error: Inventory item not found.');
      return;
    }

    stdout.write('Enter Quantity: ');
    int? qty = int.tryParse(stdin.readLineSync() ?? '');

    if (qty == null || qty <= 0) {
      print('>>> Error: Invalid quantity.');
      return;
    }

    if (qty > item.quantity) {
      print('>>> Error: Insufficient stock available. Current stock: ${item.quantity}');
      return;
    }

    String rxId = 'RX${(_prescriptions.length + 1).toString().padLeft(3, '0')}';
    Prescription rx = Prescription(
      id: rxId,
      patientId: patient.id,
      itemId: item.id,
      quantity: qty,
    );

    _prescriptions.add(rx);
    print('>>> Success: Prescription created with ID: $rxId');
  }

  void dispenseMedication() {
    print('\n--- DISPENSE MEDICATION ---');
    if (_prescriptions.isEmpty) {
      print('No active prescriptions found.');
      return;
    }

    print('Pending Prescriptions:');
    var pendingRx = _prescriptions.where((rx) => !rx.isDispensed).toList();
    if (pendingRx.isEmpty) {
      print('No pending prescriptions to dispense.');
      return;
    }

    for (var rx in pendingRx) {
      print(rx);
    }

    stdout.write('Enter Prescription ID to Dispense: ');
    String? rxId = stdin.readLineSync();

    Prescription? rx;
    try {
      rx = pendingRx.firstWhere((r) => r.id.toUpperCase() == rxId?.trim().toUpperCase());
    } catch (_) {
      rx = null;
    }

    if (rx == null) {
      print('>>> Error: Prescription ID not found.');
      return;
    }

    InventoryItem item = _inventory.firstWhere((i) => i.id == rx!.itemId);

    if (item.quantity >= rx.quantity) {
      item.quantity -= rx.quantity;
      rx.isDispensed = true;
      print('>>> Success: Medication dispensed for Prescription ${rx.id}. Remaining ${item.name} stock: ${item.quantity}');
    } else {
      print('>>> Error: Insufficient inventory to satisfy prescription.');
    }
  }

  void viewSummary() {
    print('\n===========================================');
    print('          MEDSYNC SL SYSTEM SUMMARY         ');
    print('===========================================');
    print('Total Registered Patients : ${_patients.length}');
    print('Total Inventory Items     : ${_inventory.length}');
    print('Total Prescriptions       : ${_prescriptions.length}');
    print('Dispensed Prescriptions   : ${_prescriptions.where((rx) => rx.isDispensed).length}');
    print('Pending Prescriptions     : ${_prescriptions.where((rx) => !rx.isDispensed).length}');
    print('===========================================\n');
  }
}

// ==================== MAIN ENTRY POINT ====================

void main() {
  MedSyncSystem system = MedSyncSystem();
  bool running = true;

  print('**************************************************');
  print('    WELCOME TO MEDSYNC SL - CONNAUGHT HOSPITAL    ');
  print('**************************************************');

  while (running) {
    print('\nMAIN MENU:');
    print('1. Register Patient');
    print('2. View All Patients');
    print('3. View Pharmacy Inventory');
    print('4. Create Prescription');
    print('5. Dispense Medication');
    print('6. View System Summary');
    print('7. Exit');
    stdout.write('Select an option (1-7): ');

    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        system.registerPatient();
        break;
      case '2':
        system.viewPatients();
        break;
      case '3':
        system.viewInventory();
        break;
      case '4':
        system.createPrescription();
        break;
      case '5':
        system.dispenseMedication();
        break;
      case '6':
        system.viewSummary();
        break;
      case '7':
        print('\nExiting MedSync SL. Program terminated successfully.');
        running = false;
        break;
      default:
        print('>>> Invalid selection. Please choose an option from 1 to 7.');
    }
  }
}