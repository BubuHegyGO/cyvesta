import 'package:flutter/material.dart';

class StepPhotos extends StatefulWidget {
  final List<String> photoPaths;
  final VoidCallback onAddPhotoPressed;
  final Function(int) onDeletePhotoPressed;

  const StepPhotos({
    super.key,
    required this.photoPaths,
    required this.onAddPhotoPressed,
    required this.onDeletePhotoPressed,
  });

  @override
  State<StepPhotos> createState() => _StepPhotosState();
}

class _StepPhotosState extends State<StepPhotos> {
  static const Color accent = Color(0xFF8BC541);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Szálláshely fotói',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Tölts fel legalább 3-5 jó minőségű képet! A jó fotók jelentősen növelik a foglalások számát.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Képfeltöltő Zóna (Gomb)
          InkWell(
            onTap: widget.onAddPhotoPressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accent,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.add_a_photo_rounded,
                      color: accent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Kattints a fotók hozzáadásához',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG (max. 10MB / kép)',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kiválasztott képek',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${widget.photoPaths.length} db',
                style: const TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Fotók Rácsa (Grid)
          if (widget.photoPaths.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'Még nem töltöttél fel egyetlen fotót sem.',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: widget.photoPaths.length,
              itemBuilder: (context, index) {
                final isCover = index == 0;
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCover ? accent : Colors.white12,
                          width: isCover ? 2 : 1,
                        ),
                        image: DecorationImage(
                          image: AssetImage(widget.photoPaths[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (isCover)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Borítókép',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: () => widget.onDeletePhotoPressed(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.7),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}