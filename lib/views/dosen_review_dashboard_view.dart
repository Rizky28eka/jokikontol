import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/review_controller.dart';
import '../services/logger_service.dart';

class DosenReviewDashboardView extends StatelessWidget {
  const DosenReviewDashboardView({super.key});

  Future<void> _refreshReviews(ReviewController controller) async {
    LoggerService().debug('Refreshing reviews in DosenReviewDashboard');
    await controller.fetchSubmittedForms();
  }

  @override
  Widget build(BuildContext context) {
    final ReviewController reviewController = Get.put(ReviewController());
    LoggerService().info('Dosen Review Dashboard loaded');

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
                    LoggerService().debug('Loading forms in DosenReviewDashboard');
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (reviewController.errorMessage.isNotEmpty) {
                    LoggerService().error('Error loading forms in DosenReviewDashboard', context: {'error': reviewController.errorMessage});
                    return Center(
                      child: Text('Error: ${reviewController.errorMessage}'),
                    );
                  }

                  if (reviewController.submittedForms.isEmpty) {
                    LoggerService().info('No forms to review in DosenReviewDashboard');
                    return const Center(
                      child: Text('Tidak ada form menunggu review'),
                    );
                  }

                  LoggerService().info('Displaying forms in DosenReviewDashboard', context: {'formCount': reviewController.submittedForms.length});
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
                            LoggerService().userInteraction('Form selected for review', page: 'DosenReviewDashboard', data: {
                              'formId': form.id,
                              'formType': form.type,
                              'patientName': form.patient?.name,
                              'studentName': form.user?.name,
                            });
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
