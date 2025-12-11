import 'package:flutter/material.dart';
import '../models/ruta.dart';
import '../services/api_service.dart';

class TestConnectionScreen extends StatefulWidget {
  const TestConnectionScreen({super.key});

  @override
  State<TestConnectionScreen> createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  late Future<List<Ruta>> futureRutas;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    futureRutas = apiService.fetchRutas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Conexión'),
      ),
      body: Center(
        child: FutureBuilder<List<Ruta>>(
          future: futureRutas,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Ruta ruta = snapshot.data![index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: ruta.urlImagenPortada != null
                          ? Image.network(ruta.urlImagenPortada!, width: 50, height: 50, fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error))
                          : const Icon(Icons.map),
                      title: Text(ruta.nombre),
                      subtitle: Text(ruta.descripcion),
                      trailing: Text('${ruta.distanciaEstimadaKm} km'),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    const Text('Asegúrate de que el servidor Django esté corriendo en el puerto 8000.'),
                  ],
                ),
              );
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
