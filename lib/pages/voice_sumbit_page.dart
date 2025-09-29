import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/voice_submit_data.dart';

class VoiceSubmitPage extends StatefulWidget {
  const VoiceSubmitPage({super.key});

  @override
  State<VoiceSubmitPage> createState() => _VoiceSubmitPageState();
}

class _VoiceSubmitPageState extends State<VoiceSubmitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _ageController = TextEditingController();
  final _hobbyController = TextEditingController();
  
  String _selectedGender = '';
  String _selectedVoiceType = '';
  String? _photoPath;
  bool _isSubmitted = false;
  final ImagePicker _picker = ImagePicker();

  final List<String> _genderOptions = ['Male', 'Female'];
  final List<String> _voiceTypeOptions = ['Healing', 'Girl', 'Boy', 'Child', 'Mature'];

  @override
  void initState() {
    super.initState();
    _checkSubmissionStatus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idNumberController.dispose();
    _ageController.dispose();
    _hobbyController.dispose();
    super.dispose();
  }

  Future<void> _checkSubmissionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isSubmitted = prefs.getBool('voice_submit_submitted') ?? false;
      setState(() {
        _isSubmitted = isSubmitted;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveSubmissionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('voice_submit_submitted', true);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _photoPath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to select image: $e')),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select gender')),
        );
        return;
      }
      if (_selectedVoiceType.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select voice type')),
        );
        return;
      }
      if (_photoPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload your photo')),
        );
        return;
      }

      final data = VoiceSubmitData(
        name: _nameController.text.trim(),
        idNumber: _idNumberController.text.trim(),
        gender: _selectedGender,
        age: int.parse(_ageController.text.trim()),
        hobby: _hobbyController.text.trim(),
        photoPath: _photoPath,
        voiceType: _selectedVoiceType,
      );

      // Save submission status
      _saveSubmissionStatus();
      setState(() {
        _isSubmitted = true;
      });
      
      // Here you can add server submission logic
      _showSuccessDialog(data);
    }
  }

  void _showSuccessDialog(VoiceSubmitData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submission Successful'),
        content: const Text('Your information has been successfully submitted. We will review it and contact you soon.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Voice Submission',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF80FED6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                _isSubmitted ? 'Submission Completed' : 'Please fill in your details',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isSubmitted 
                    ? 'Your information has been submitted successfully. We will contact you soon.'
                    : 'We will match you with a suitable voice based on your information',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 30),

              // Name
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                hint: 'Enter your real name',
                enabled: !_isSubmitted,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              // ID Number
              _buildTextField(
                controller: _idNumberController,
                label: 'ID Number',
                hint: 'Enter your ID number',
                keyboardType: TextInputType.text,
                enabled: !_isSubmitted,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your ID number';
                  }
                  if (value.trim().length != 18) {
                    return 'ID number format is incorrect';
                  }
                  return null;
                },
              ),

              // Gender Selection
              _buildGenderSelector(),

              // Age
              _buildTextField(
                controller: _ageController,
                label: 'Age',
                hint: 'Enter your age',
                keyboardType: TextInputType.number,
                enabled: !_isSubmitted,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your age';
                  }
                  final age = int.tryParse(value.trim());
                  if (age == null || age < 1 || age > 120) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),

              // Hobby
              _buildTextField(
                controller: _hobbyController,
                label: 'Hobby',
                hint: 'Describe your hobbies and interests',
                maxLines: 3,
                enabled: !_isSubmitted,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe your hobbies';
                  }
                  return null;
                },
              ),

              // Photo Upload
              _buildPhotoUpload(),

              // Voice Type Selection
              _buildVoiceTypeSelector(),

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitted ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSubmitted ? Colors.grey[400] : const Color(0xFF80FED6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isSubmitted ? 'Already Submitted' : 'Submit Information',
                    style: TextStyle(
                      color: _isSubmitted ? Colors.grey[600] : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF999999)),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF80FED6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: _genderOptions.map((gender) {
            return Expanded(
              child: GestureDetector(
                onTap: _isSubmitted ? null : () {
                  setState(() {
                    _selectedGender = gender;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedGender == gender ? const Color(0xFF80FED6) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedGender == gender ? const Color(0xFF80FED6) : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Text(
                    gender,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedGender == gender ? Colors.black : const Color(0xFF333333),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPhotoUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isSubmitted ? null : _pickImage,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                style: BorderStyle.solid,
              ),
            ),
            child: _photoPath == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isSubmitted ? 'Photo uploaded' : 'Tap to upload photo',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_photoPath!),
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildVoiceTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What does your voice sound like',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _voiceTypeOptions.map((voiceType) {
            final isSelected = _selectedVoiceType == voiceType;
            return GestureDetector(
              onTap: _isSubmitted ? null : () {
                setState(() {
                  _selectedVoiceType = voiceType;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF80FED6) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF80FED6) : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Text(
                  voiceType,
                  style: TextStyle(
                    color: isSelected ? Colors.black : const Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}