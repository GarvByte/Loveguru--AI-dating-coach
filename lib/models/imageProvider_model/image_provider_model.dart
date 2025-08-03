import 'package:loveguru/models/supabaseProvider_model/supabase_provider_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageProviderModel extends Notifier<List<XFile>> {

  @override
  List<XFile> build() {
    return [];
  }

  Future<void> getImageFromUser(WidgetRef ref) async {
    final ImagePicker picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isEmpty) {
      print("Images are empty");
    } else {
      print("succcessfully got the image");
      print("images = ${state.length}");
      state = images;
      ref.read(supabaseprovider.notifier).getAndUploadtoSupabase(state, ref);
    }
  }
}

final imageprovider = NotifierProvider<ImageProviderModel, List<XFile>>(() {
  return ImageProviderModel();
});
