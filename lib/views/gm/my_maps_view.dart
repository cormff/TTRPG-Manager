import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ttrpg_manager/l10n/app_localizations.dart';
import '../../providers/maps_provider.dart';

class MyMapsView extends StatefulWidget {
  const MyMapsView({super.key});

  @override
  State<MyMapsView> createState() => _MyMapsViewState();
}

class _MyMapsViewState extends State<MyMapsView> {

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında veritabanındaki tüm haritaları çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapsProvider>().fetchAllMaps();
    });
  }

  void _showAddMapDialog() {
    final l10n = AppLocalizations.of(context)!;
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
                    Text(l10n.addNewMap, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: l10n.mapName, border: const OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: Text(l10n.pickFromGallery),
                          selected: selectedMode == 0,
                          selectedColor: Theme.of(context).primaryColor,
                          onSelected: (val) => setModalState(() { selectedMode = 0; localImagePath = null; urlController.clear(); }),
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: Text(l10n.enterUrl),
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
                                Text(l10n.openGallery, style: TextStyle(color: Theme.of(context).primaryColorLight)),
                              ],
                            )
                                : null,
                          ),
                        ),
                      ),

                    if (selectedMode == 1)
                      TextField(
                        controller: urlController,
                        decoration: InputDecoration(labelText: l10n.imageUrl, border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.link)),
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

                          setModalState(() => isSaving = true);

                          // DUMMY LİSTE YERİNE BACKEND'E (PROVIDER'A) GÖNDERİYORUZ
                          final success = await context.read<MapsProvider>().createMap(
                              titleController.text,
                              finalImageSource
                          );

                          if (success && context.mounted) {
                            Navigator.pop(context); // Modalı kapat
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.mapAddedSuccess)));
                          } else {
                            setModalState(() => isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorOccurred), backgroundColor: Colors.red));
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: Text(l10n.addMapToPool),
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.mapPool)),

      // Consumer ile gerçek verileri dinliyoruz
      body: Consumer<MapsProvider>(
        builder: (context, mapsProvider, child) {
          if (mapsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (mapsProvider.allMaps.isEmpty) {
            return Center(child: Text(l10n.noMapsAdded, style: const TextStyle(color: Colors.grey)));
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
              // Resim HTTP ile başlıyorsa Network, yoksa cihazdaki File olarak kabul et
              final isNetworkImage = map.imageUrl.startsWith('http') || map.imageUrl.startsWith('https');

              return GestureDetector(
                onTap: () {
                  // Haritaya tıklanınca tam ekran Dialog (Pop-up) açılır
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.all(10), // Kenarlardan hafif boşluk
                      child: InteractiveViewer(
                        panEnabled: true, // Kaydırmaya izin ver
                        minScale: 0.5,
                        maxScale: 4.0, // 4 katına kadar yakınlaştırma (Zoom)
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
