import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/widgets/cyvesta_scaffold.dart';

class StepPhotosPage extends StatefulWidget {
  const StepPhotosPage({super.key});

  @override
  State<StepPhotosPage> createState() => _StepPhotosPageState();
}

class _StepPhotosPageState extends State<StepPhotosPage> {
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    // Ellenőrizzük, hogy elérték-e már a 10 darabos limitet
    if (_selectedImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 10 db fotó tölthető fel!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    
    if (pickedFiles.isNotEmpty) {
      setState(() {
        for (var file in pickedFiles) {
          if (_selectedImages.length < 10) {
            _selectedImages.add(File(file.path));
          }
        }
      });

      if (_selectedImages.length >= 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Elérte a maximum 10 db-os fotókorlátot.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CyvestaScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fényképek feltöltése (Max. 10 db)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kiválasztva: ${_selectedImages.length} / 10',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Képek rács nézete
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _selectedImages.length + (_selectedImages.length < 10 ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
                      // Hozzáadás gomb csempe
                      return GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF093753),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF99FF99), width: 1.5),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: Color(0xFFFF9F1C), size: 30),
                              SizedBox(height: 4),
                              Text('Hozzáadás', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    }

                    // Feltöltött kép előnézete törlés gombbal
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(_selectedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Tovább gomb
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fotók mentve, továbblépés...'), backgroundColor: Colors.green),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9F1C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Következő lépés',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}