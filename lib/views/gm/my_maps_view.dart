import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/maps_provider.dart';
import 'package:ttrpg_manager/providers/language_manager.dart';
import 'package:ttrpg_manager/providers/user_role_provider.dart';

class MyMapsView extends StatefulWidget {
  const MyMapsView({super.key});

  @override
  State<MyMapsView> createState() => _MyMapsViewState();
}

class _MyMapsViewState extends State<MyMapsView> {

// 1. initState Kısmı:
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // YENİ: Giriş yapmış kullanıcının ID'sini alıp sadece ona ait olanları çekiyoruz
      final userId = context.read<UserRoleProvider>().userId;
      if (userId != null) {
        context.read<MapsProvider>().fetchAllMaps(userId);
      }
    });
  }

  void _showAddMapDialog() {
    final titleController = TextEditingController();
    final urlController = TextEditingController();

    int selectedMode = 0; // 0: Galeri, 1: URL
    String? localImagePath;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {

            Future<void> pickImage() async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setModalState(() { localImagePath = image.path; });
              }
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  left: 20, right: 20, top: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('Add New Map'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                          labelText: context.tr('Map Name'),
                          border: const OutlineInputBorder()
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: Text(context.tr('Pick from gallery')),
                          selected: selectedMode == 0,
                          selectedColor: Theme.of(context).primaryColor,
                          onSelected: (val) => setModalState(() { selectedMode = 0; localImagePath = null; urlController.clear(); }),
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: Text(context.tr('Enter URL')),
                          selected: selectedMode == 1,
                          selectedColor: Theme.of(context).primaryColor,
                          onSelected: (val) => setModalState(() { selectedMode = 1; localImagePath = null; urlController.clear(); }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (selectedMode == 0)
                      Center(
                        child: GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            height: 150, width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(12),
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              image: localImagePath != null
                                  ? DecorationImage(image: FileImage(File(localImagePath!)), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: localImagePath == null
                                ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 40, color: Theme.of(context).primaryColorLight),
                                const SizedBox(height: 8),
                                Text(context.tr('Open gallery'), style: TextStyle(color: Theme.of(context).primaryColorLight)),
                              ],
                            )
                                : null,
                          ),
                        ),
                      ),

                    if (selectedMode == 1)
                      TextField(
                        controller: urlController,
                        decoration: InputDecoration(
                            labelText: context.tr('Image URL'),
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.link)
                        ),
                        onChanged: (val) => setModalState(() {}),
                      ),

                    if (selectedMode == 1 && urlController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Container(
                          height: 150, width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(image: NetworkImage(urlController.text), fit: BoxFit.cover),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: isSaving
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                        onPressed: () async {
                          if (titleController.text.isEmpty) return;

                          final String finalImageSource = selectedMode == 0
                              ? (localImagePath ?? '')
                              : urlController.text;

                          if (finalImageSource.isEmpty) return;

                          final currentUserId = context.read<UserRoleProvider>().userId; // EKLENEN

                          setModalState(() => isSaving = true);
                          final success = await context.read<MapsProvider>().createMap(
                              titleController.text,
                              finalImageSource,
                              currentUserId! // <--- YENİ: ID'yi de gönderiyoruz
                          );

                          if (success && context.mounted) {
                            Navigator.pop(context); // Modalı kapat
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('Harita başarıyla veritabanına eklendi!'))));
                          } else {
                            setModalState(() => isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('Hata oluştu!')), backgroundColor: Colors.red));
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: Text(context.tr('Add map to pool')),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Map Pool'))),

      // Consumer ile gerçek verileri dinliyoruz
      body: Consumer<MapsProvider>(
        builder: (context, mapsProvider, child) {
          if (mapsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (mapsProvider.allMaps.isEmpty) {
            return Center(
                child: Text(
                    context.tr('No maps have been added yet.'),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))
                )
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: mapsProvider.allMaps.length,
            itemBuilder: (context, index) {
              final map = mapsProvider.allMaps[index];
              final isNetworkImage = map.imageUrl.startsWith('http') || map.imageUrl.startsWith('https');

              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.all(10),
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: isNetworkImage
                              ? Image.network(map.imageUrl, fit: BoxFit.contain)
                              : Image.file(File(map.imageUrl), fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                    image: DecorationImage(
                      image: isNetworkImage
                          ? NetworkImage(map.imageUrl) as ImageProvider
                          : FileImage(File(map.imageUrl)),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      map.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMapDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}