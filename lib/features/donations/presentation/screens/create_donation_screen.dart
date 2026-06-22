import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../core/services/groq_ai_service.dart';
import '../providers/donation_provider.dart';

class CreateDonationScreen extends ConsumerStatefulWidget {
  const CreateDonationScreen({super.key});

  @override
  ConsumerState<CreateDonationScreen> createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends ConsumerState<CreateDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _servingsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  
  final List<File> _selectedImages = [];
  bool _isLoading = false;
  bool _isGettingLocation = false;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(limit: 3);
    
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      } 

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _addressController.text = "Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)} (Mock Address for Demo)";
      });
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image of the food.'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(createDonationProvider.notifier).createDonation(
            foodName: _foodNameController.text.trim(),
            estimatedServings: int.tryParse(_servingsController.text),
            description: _descriptionController.text.trim(),
            pickupAddress: _addressController.text.trim(),
            images: _selectedImages,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation Created Successfully!'), backgroundColor: AppColors.success),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Share Surplus Food'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'List your surplus food',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Every meal you share brings hope to someone in need.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSizes.p32),
              
              // Image Upload Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Photos of the Food', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  if (_selectedImages.isNotEmpty)
                    TextButton.icon(
                      onPressed: () async {
                        // Prompt user for raw description
                        final rawDescController = TextEditingController();
                        final result = await showDialog<String>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Describe your donation'),
                            content: TextField(
                              controller: rawDescController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'e.g. I have 3 boxes of leftover pizza and 2 bags of chips from a party...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, rawDescController.text),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                                child: const Text('Analyze'),
                              ),
                            ],
                          ),
                        );

                        if (result == null || result.trim().isEmpty) return;
                        if (!context.mounted) return;

                        final navigator = Navigator.of(context);
                        final scaffoldMessenger = ScaffoldMessenger.of(context);

                        // Show loading
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (c) => const AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('✨ AI Analyzing via Groq...'),
                              ],
                            ),
                          ),
                        );

                        try {
                          final data = await GroqAIService.analyzeFoodDonation(result);
                          if (!context.mounted) return;
                          navigator.pop(); // Close loading

                          setState(() {
                            _foodNameController.text = data['foodName']?.toString() ?? '';
                            _servingsController.text = data['estimatedServings']?.toString() ?? '';
                            _descriptionController.text = data['description']?.toString() ?? '';
                            // Optionally handle category if you have a dropdown
                          });

                          scaffoldMessenger.showSnackBar(
                            const SnackBar(content: Text('✨ AI extracted structured data!'), backgroundColor: AppColors.primary),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          navigator.pop(); // Close loading
                          scaffoldMessenger.showSnackBar(
                            SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
                          );
                        }
                      },
                      icon: const Icon(Icons.auto_awesome, color: Colors.purple),
                      label: const Text('Analyze with AI', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
                      return GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2, style: BorderStyle.solid),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: AppColors.primary),
                              SizedBox(height: 4),
                              Text('Add Photo', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      );
                    }
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: FileImage(_selectedImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedImages.removeAt(index));
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSizes.p24),

              CustomTextField(
                label: 'Food Name',
                hint: 'e.g., Rice and Curry, 50 Sandwiches',
                controller: _foodNameController,
                validator: (val) => val != null && val.isNotEmpty ? null : 'Required field',
              ),
              const SizedBox(height: AppSizes.p16),
              CustomTextField(
                label: 'Estimated Servings',
                hint: 'e.g., 20',
                keyboardType: TextInputType.number,
                controller: _servingsController,
              ),
              const SizedBox(height: AppSizes.p16),
              CustomTextField(
                label: 'Description',
                hint: 'Additional details about the food',
                controller: _descriptionController,
              ),
              const SizedBox(height: AppSizes.p16),
              
              // Location Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Pickup Address',
                      hint: 'Enter or fetch location',
                      controller: _addressController,
                      validator: (val) => val != null && val.isNotEmpty ? null : 'Required field',
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: _isGettingLocation ? null : _getCurrentLocation,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 56, // Matches text field height approx
                      width: 56,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
                      ),
                      child: _isGettingLocation
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location, color: AppColors.secondary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.p32),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Publish Donation',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
