import 'package:flutter/material.dart';
import 'package:appointmentbook/models/service_model.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServiceHeader(context),
              const SizedBox(height: 28),

              _buildSectionTitle(context, 'Service Information'),
              const SizedBox(height: 12),

              _buildInformationCards(context),

              const SizedBox(height: 28),

              _buildSectionTitle(context, 'About This Service'),
              const SizedBox(height: 12),

              _buildDescription(context),

              const SizedBox(height: 28),

              _buildSectionTitle(context, 'What You Get'),
              const SizedBox(height: 12),

              _buildFeatureItem(
                context,
                'Professional service from qualified staff',
              ),
              _buildFeatureItem(
                context,
                'Personalized attention based on your needs',
              ),
              _buildFeatureItem(
                context,
                'Clear information about your appointment',
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.medical_services_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 6),

                Text(
                  'Professional healthcare service',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            context,
            icon: Icons.access_time_rounded,
            title: 'Duration',
            value: '${service.durationMinutes} min',
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildInfoCard(
            context,
            icon: Icons.payments_outlined,
            title: 'Price',
            value: '${service.price.toStringAsFixed(2)} USD',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),

          const SizedBox(height: 12),

          Text(title, style: Theme.of(context).textTheme.bodySmall),

          const SizedBox(height: 4),

          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }

  Widget _buildDescription(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(
        service.description ?? 'No description available.',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 22,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
