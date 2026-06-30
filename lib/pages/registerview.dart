import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import '../controller/registercontroller.dart';

 class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'School Registration',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 37, 80, 76),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color.fromARGB(255, 37, 80, 76), Color.fromARGB(255, 45, 100, 95)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.school_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Register Your School',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fill in the details below to get started',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Form Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // School Name Field

                      _buildTextField(
                      controller: controller.contactpersonname,
                      label: 'Contact Person Name',
                      hint: 'Enter contact person name',
                      icon: Icons.person_rounded,
                      keyboardType: TextInputType.text,
                    ),
                     const SizedBox(height: 20),
                    _buildTextField(
                      controller: controller.schoolNameController,
                      label: 'School Name',
                      hint: 'Enter your school name',
                      icon: Icons.apartment_rounded,
                    ),
                    const SizedBox(height: 20),

                    // School Address Field
                    _buildTextField(
                      controller: controller.schoolAddressController,
                      label: 'School Address',
                      hint: 'Enter complete address',
                      icon: Icons.location_on_rounded,
                      maxLines: 3,
                    ),

                    // // Add Pincode Field
                    // _buildTextField(
                    //   controller: controller.pincodeController,
                    //   label: 'Pincode',
                    //   hint: 'Enter Pincode',
                    //   icon: Icons.pin_drop,
                    //   keyboardType: TextInputType.number,
                    // ),
                    const SizedBox(height: 20),
                     _buildTextField(
                      controller: controller.citycontroller,
                      label: 'City',
                      hint: 'Enter City',
                      icon: Icons.location_city,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 20),
                     _buildTextField(
                      controller: controller.statecontroller,
                      label: 'State',
                      hint: 'Enter State',
                      icon: Icons.location_history_sharp,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 20),
                     _buildTextField(
                      controller: controller.districtcontroller,
                      label: 'District',
                      hint: 'Enter District',
                      icon: Icons.local_attraction_outlined,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 20),

                    // School Contact Number Field
                    _buildTextField(
                      readOnly: true,
                      controller: controller.schoolContactController,
                      label: 'Contact Number',
                      hint: 'Enter contact number',
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 20),

                    // School Email Field
                    _buildTextField(
                      controller: controller.schoolEmailController,
                      label: 'School Email',
                      hint: 'Enter email address',
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color.fromARGB(255, 37, 80, 76), Color.fromARGB(255, 45, 100, 95)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 37, 80, 76).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    controller.register(
                      schoolName: controller.schoolNameController.text,
                      schoolAddress: controller.schoolAddressController.text,
                      schoolContact: controller.schoolContactController.text,
                      schoolEmail: controller.schoolEmailController.text,
                      contactPersonName: controller.contactpersonname.text,
                      city: controller.citycontroller.text,
                      state: controller.statecontroller.text,
                      district: controller.districtcontroller.text,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Register School',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool? readOnly,

    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 37, 80, 76),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          readOnly: readOnly ?? false,
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(icon, color: const Color.fromARGB(255, 37, 80, 76)),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color.fromARGB(255, 37, 80, 76), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
