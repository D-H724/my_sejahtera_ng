import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/core/theme/app_theme.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';

class VaccineScreen extends StatelessWidget {
  const VaccineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Digital Certificate"),
        leading: const BackButton(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF003B70), Color(0xFF001A33)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildVaccineCard(
                dose: "Dose 1",
                date: "01 May 2021",
                vaccineName: "Pfizer",
                location: "PPV OFFSITE KSL",
                batch: "EL1234",
              ),
              const SizedBox(height: 15),
              _buildVaccineCard(
                dose: "Dose 2",
                date: "22 May 2021",
                vaccineName: "Pfizer",
                location: "BILIK MESYUARAT EKSEKUTIF PERPUSTAKAAN RAJA ZARITH SOFIAH UTM",
                batch: "FA4567",
              ),
              const SizedBox(height: 15),
              _buildVaccineCard(
                dose: "Booster 1",
                date: "10 Jan 2022",
                vaccineName: "Pfizer",
                location: "BILIK MESYUARAT EKSEKUTIF PERPUSTAKAAN RAJA ZARITH SOFIAH UTM",
                batch: "GH7890",
                isBooster: true,
              ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                   width: double.infinity,
                   child: ElevatedButton.icon(
                     onPressed: () {}, 
                     icon: const Icon(LucideIcons.download),
                     label: const Text("Generate PDF Certificate"),
                   ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVaccineCard({
    required String dose,
    required String date,
    required String vaccineName,
    required String location,
    required String batch,
    bool isBooster = false,
  }) {
    return GlassContainer(
      width: double.infinity,
      color: isBooster ? AppTheme.accentTeal.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dose, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const Icon(LucideIcons.shieldCheck, color: Colors.greenAccent),
            ],
          ),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          _buildRow("Date", date),
          _buildRow("Vaccine", vaccineName),
          _buildRow("Batch", batch),
          _buildRow("Location", location),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.white60))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
