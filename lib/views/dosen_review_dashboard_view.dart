import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/review_controller.dart';

class DosenReviewDashboardView extends StatelessWidget {
  const DosenReviewDashboardView({super.key});

  Future<void> _refreshReviews(ReviewController controller) async {
    await controller.fetchSubmittedForms();
  }

  @override
  Widget build(BuildContext context) {
    final ReviewController reviewController = Get.put(ReviewController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Revisi Form'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshReviews(reviewController),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daftar Form Menunggu Review',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Submitted forms list
              Expanded(
                child: Obx(() {
                  if (reviewController.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (reviewController.errorMessage.isNotEmpty) {
                    return Center(
                      child: Text('Error: ${reviewController.errorMessage}'),
                    );
                  }

                  if (reviewController.submittedForms.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada form menunggu review'),
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: reviewController.submittedForms.length,
                    itemBuilder: (context, index) {
                      final form = reviewController.submittedForms[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            '${form.type} - ${form.patient?.name ?? 'Unknown Patient'}',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mahasiswa: ${form.user?.name ?? 'Unknown'}',
                              ),
                              Text(
                                'Tanggal: ${form.createdAt.toString().split(' ')[0]}',
                              ),
                            ],
                          ),
                          trailing: Text(
                            form.status.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          onTap: () {
                            // Navigate to form review page
                            Get.toNamed('/form-review/${form.id}');
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
